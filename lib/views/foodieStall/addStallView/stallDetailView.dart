import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../annim/transiton.dart';
import '../../../apis/stallManagment/deleteStall_api.dart';
import '../../../apis/stallManagment/updateStall_api.dart';
import '../../../constants/appConstants.dart';
import '../../../providers/stallProvider.dart';
import '../../../utilities/imagePickerUtility.dart';
import '../../../utilities/scaffoldBackground.dart';
import '../mapViews/LocationMap.dart';

class StallDetailView extends StatefulWidget {
  final int stallId;
  final String festivalId;
  final String eventId;
  final String stallName;
  final String imageUrl;
  final String festivalName;
  final String? eventName;
  final String latitude;
  final String longitude;
  final String startDate;
  final String endDate;
  final String openingTime;
  final String closingTime;

  const StallDetailView({
    super.key,
    required this.stallId,
    required this.festivalId,
    required this.eventId,
    required this.stallName,
    required this.imageUrl,
    required this.festivalName,
    this.eventName,
    required this.latitude,
    required this.longitude,
    required this.startDate,
    required this.endDate,
    required this.openingTime,
    required this.closingTime,
  });

  @override
  State<StallDetailView> createState() => _StallDetailViewState();
}

class _StallDetailViewState extends State<StallDetailView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _stallNameController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late final TextEditingController _openingTimeController;
  late final TextEditingController _closingTimeController;

  bool _isEditMode = false;
  bool _isSubmitting = false;
  bool _isDeleting = false;
  XFile? _newStallImage;
  /// Shown after a successful update with a new image (URL may not refresh until list reload).
  String? _postUpdateLocalImagePath;

  @override
  void initState() {
    super.initState();
    _stallNameController = TextEditingController(text: widget.stallName);
    _latitudeController = TextEditingController(text: widget.latitude);
    _longitudeController = TextEditingController(text: widget.longitude);
    _startDateController = TextEditingController(text: widget.startDate);
    _endDateController = TextEditingController(text: widget.endDate);
    _openingTimeController = TextEditingController(text: widget.openingTime);
    _closingTimeController = TextEditingController(text: widget.closingTime);
  }

  @override
  void dispose() {
    _stallNameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = true;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
      _newStallImage = null;
      _postUpdateLocalImagePath = null;
      _stallNameController.text = widget.stallName;
      _latitudeController.text = widget.latitude;
      _longitudeController.text = widget.longitude;
      _startDateController.text = widget.startDate;
      _endDateController.text = widget.endDate;
      _openingTimeController.text = widget.openingTime;
      _closingTimeController.text = widget.closingTime;
    });
  }

  DateTime _initialDateFor(String raw) {
    final t = raw.trim();
    if (t.length >= 10) {
      final d = DateTime.tryParse(t.substring(0, 10));
      if (d != null) return d;
    }
    return DateTime.now();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _initialDateFor(_startDateController.text),
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() {
        _startDateController.text = picked.toString().substring(0, 11);
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _initialDateFor(_endDateController.text),
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() {
        _endDateController.text = picked.toString().substring(0, 11);
      });
    }
  }

  Future<void> _pickOpeningTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _openingTimeController.text = picked.format(context);
      });
    }
  }

  Future<void> _pickClosingTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _closingTimeController.text = picked.format(context);
      });
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<dynamic>(
      context,
      FadePageRouteBuilder(
        widget: GoogleMapView(isFromFestival: false),
      ),
    );
    if (!mounted || result == null) return;
    if (result is! Map) return;
    final map = Map<dynamic, dynamic>.from(result);
    setState(() {
      final lat = map['latitude']?.toString();
      final lng = map['longitude']?.toString();
      if (lat != null && lat.isNotEmpty) {
        _latitudeController.text = lat;
      }
      if (lng != null && lng.isNotEmpty) {
        _longitudeController.text = lng;
      }
    });
  }

  Future<void> _pickStallImage() async {
    final XFile? image = await ImagePickerUtility.showImageSourceModal(
      context,
      title: 'Select Stall Image',
    );
    if (image != null) {
      setState(() => _newStallImage = image);
    }
  }

  void _snackLockedField() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Festival and event cannot be changed here.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static const Color _toolbarEditBg = Color(0xFF455A64);
  static const Color _toolbarDeleteBg = Color(0xFFB71C1C);

  Widget _toolbarActionChip({
    required String label,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: backgroundColor,
      elevation: 2,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'inter-semibold',
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteStall() async {
    if (_isDeleting) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete stall'),
        content: Text(
          'Are you sure you want to delete "${widget.stallName}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    var ok = false;
    try {
      ok = await deleteStallApi(context, widget.stallId);
      if (!mounted) return;
      if (!ok) return;

      final stallProvider = Provider.of<StallProvider>(context, listen: false);
      await stallProvider.fetchStallsCollection(context, forceRefresh: true);
      await stallProvider.fetchStallsByFestival(
        context,
        widget.festivalId,
        isfromReviewSection: false,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<void> _handleUpdate() async {
    debugPrint('[StallDetail] ─── Update tapped ───');
    debugPrint(
      '[StallDetail] stallId=${widget.stallId} festivalId=${widget.festivalId} eventId=${widget.eventId}',
    );
    debugPrint(
      '[StallDetail] stallName(raw)=|${_stallNameController.text}| len=${_stallNameController.text.length}',
    );
    debugPrint(
      '[StallDetail] latitude(raw)=|${_latitudeController.text}| len=${_latitudeController.text.length}',
    );
    debugPrint(
      '[StallDetail] longitude(raw)=|${_longitudeController.text}| len=${_longitudeController.text.length}',
    );
    debugPrint(
      '[StallDetail] fromDate(raw)=|${_startDateController.text}| len=${_startDateController.text.length}',
    );
    debugPrint(
      '[StallDetail] toDate(raw)=|${_endDateController.text}| len=${_endDateController.text.length}',
    );
    debugPrint(
      '[StallDetail] openingTime(raw)=|${_openingTimeController.text}| len=${_openingTimeController.text.length}',
    );
    debugPrint(
      '[StallDetail] closingTime(raw)=|${_closingTimeController.text}| len=${_closingTimeController.text.length}',
    );
    debugPrint(
      '[StallDetail] newStallImage=${_newStallImage != null ? _newStallImage!.path : null}',
    );

    final formState = _formKey.currentState;
    if (formState == null) {
      debugPrint('[StallDetail] ERROR: _formKey.currentState is null');
      return;
    }
    final formOk = formState.validate();
    debugPrint('[StallDetail] form.validate() => $formOk');
    if (!formOk) {
      debugPrint(
        '[StallDetail] Form validation failed — check red error text on fields (often empty date/time after map).',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final ok = await updateStallApi(
        context,
        stallId: widget.stallId.toString(),
        festivalId: widget.festivalId,
        eventId: widget.eventId,
        stallName: _stallNameController.text.trim(),
        latitude: _latitudeController.text.trim(),
        longitude: _longitudeController.text.trim(),
        fromDate: _startDateController.text.trim(),
        toDate: _endDateController.text.trim(),
        openingTime: _openingTimeController.text.trim(),
        closingTime: _closingTimeController.text.trim(),
        image: _newStallImage,
        existingImageUrl: widget.imageUrl.trim().isEmpty
            ? null
            : widget.imageUrl.trim(),
      );
      debugPrint('[StallDetail] updateStallApi returned ok=$ok');
      if (!mounted) return;
      if (ok) {
        final uploadedPath = _newStallImage?.path;
        setState(() {
          _isEditMode = false;
          _newStallImage = null;
          if (uploadedPath != null) {
            _postUpdateLocalImagePath = uploadedPath;
          }
        });
        final stallProvider =
            Provider.of<StallProvider>(context, listen: false);
        await stallProvider.fetchStallsCollection(context, forceRefresh: true);
        await stallProvider.fetchStallsByFestival(
          context,
          widget.festivalId,
          isfromReviewSection: false,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _festivalDisplay() =>
      widget.festivalName.isNotEmpty ? widget.festivalName : 'Loading...';

  String _eventDisplay() => widget.eventName ?? 'Not specified';

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
            AppBar(
              backgroundColor: Colors.transparent,
              title: const Text(
                'Stall Detail',
                style: TextStyle(
                  fontFamily: 'inter-semibold',
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
              centerTitle: false,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: SvgPicture.asset(AppConstants.backIcon, height: 50),
              ),
              actions: [
                if (!_isEditMode) ...[
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, bottom: 10, right: 6),
                    child: _toolbarActionChip(
                      label: 'Edit',
                      backgroundColor: _toolbarEditBg,
                      onPressed: _toggleEditMode,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, bottom: 10, right: 12),
                    child: _toolbarActionChip(
                      label: 'Delete',
                      backgroundColor: _toolbarDeleteBg,
                      onPressed: _confirmDeleteStall,
                    ),
                  ),
                ],
              ],
            ),
            if (_isEditMode)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'You are in edit mode. Festival and event cannot be changed.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFF8F8F8),
                ),
                child: Form(
                  key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      _buildLockedAssociationRows(),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _stallNameController,
                        readOnly: !_isEditMode,
                        decoration: _inputDecoration('Stall name'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            debugPrint(
                              '[StallDetail] validator FAIL: stallName empty or null (v=$v)',
                            );
                            return 'Enter stall name';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 20),
                    _buildImageSection(),
                    const SizedBox(height: 20),
                      if (_isEditMode) ...[
                        Row(
                          children: [
                            const Spacer(),
                            const Text(
                              'Open Map',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: _openMapPicker,
                              child: Image.asset(AppConstants.mapPreview),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Stall Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      TextFormField(
                        controller: _latitudeController,
                        readOnly: !_isEditMode,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: _inputDecoration('Latitude'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            debugPrint(
                              '[StallDetail] validator FAIL: latitude empty (v=$v)',
                            );
                            return 'Enter latitude';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _longitudeController,
                        readOnly: !_isEditMode,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: _inputDecoration('Longitude'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            debugPrint(
                              '[StallDetail] validator FAIL: longitude empty (v=$v)',
                            );
                            return 'Enter longitude';
                          }
                          return null;
                        },
                      ),
                      if (!_isEditMode)
              Row(
              mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            0.015,
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.05,
                        ),
                      ),
                      onPressed: () async {
                                  final lat = _latitudeController.text.trim();
                                  final lng = _longitudeController.text.trim();
                                  final googleMapsUrl =
                                      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
                        final Uri uri = Uri.parse(googleMapsUrl);

                        try {
                          if (await canLaunchUrl(uri)) {
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                          } else {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                              SnackBar(
                                          content: const Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                              SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Google Maps not installed. Please install Google Maps to use navigation',
                                                  style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                          backgroundColor: Colors.red.shade600,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                ),
                                margin: const EdgeInsets.all(16),
                                duration: const Duration(seconds: 3),
                                action: SnackBarAction(
                                  label: 'OK',
                                  textColor: Colors.white,
                                  onPressed: () {
                                              ScaffoldMessenger.of(context)
                                                  .hideCurrentSnackBar();
                                  },
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                                    if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                            const Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                                'Error opening navigation: $e',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                                        backgroundColor: Colors.red.shade600,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                              ),
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 3),
                              action: SnackBarAction(
                                label: 'OK',
                                textColor: Colors.white,
                                onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .hideCurrentSnackBar();
                                },
                              ),
                            ),
                          );
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                                      'Navigation',
                            style: TextStyle(
                                        fontFamily: 'inter-semibold',
                              color: Colors.white,
                            ),
                          ),
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                              0.02,
                                    ),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                    ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
                      SizedBox(height: _isEditMode ? 8 : 12),
                    _buildDateSection(),
                    const SizedBox(height: 20),
                    _buildTimeSection(),
                      if (_isEditMode) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed:
                                    _isSubmitting ? null : _cancelEdit,
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF96222),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: _isSubmitting ? null : _handleUpdate,
                                child: _isSubmitting
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Update',
                                        style: TextStyle(
                                          fontFamily: 'inter-semibold',
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
              ],
            ),
          ),
          if (_isDeleting)
            Positioned.fill(
              child: AbsorbPointer(
                child: ColoredBox(
                  color: Colors.black38,
                  child: Center(
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 22,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Color(0xFFF96222),
                              ),
                            ),
                            SizedBox(height: 14),
                            Text(
                              'Deleting stall…',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildLockedAssociationRows() {
    final festival = _festivalDisplay();
    final event = _eventDisplay();

    if (!_isEditMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Festival:', festival),
          _buildDetailRow('Event:', event),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Festival',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF96222),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: _snackLockedField,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
            child: Text(
              festival,
              style: const TextStyle(fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Event',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF96222),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: _snackLockedField,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
            child: Text(
              event,
              style: const TextStyle(fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF96222),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stall Image',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _newStallImage != null
                ? Image.file(
                    File(_newStallImage!.path),
                    fit: BoxFit.cover,
                  )
                : _postUpdateLocalImagePath != null
                    ? Image.file(
                        File(_postUpdateLocalImagePath!),
                        fit: BoxFit.cover,
                      )
                : widget.imageUrl.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: widget.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFF96222),
                ),
              ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.error_outline_sharp,
                            color: Color(0xFFF96222),
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.error_outline_sharp,
                          color: Color(0xFFF96222),
                        ),
            ),
          ),
        ),
        if (_isEditMode) ...[
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _pickStallImage,
            icon: const Icon(Icons.photo_library_outlined,
                color: Color(0xFFF96222)),
            label: const Text(
              'Change photo',
              style: TextStyle(color: Color(0xFFF96222)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateSection() {
    if (!_isEditMode) {
      return Row(
        children: [
          Expanded(
            child: _buildDateTile('From Date', _startDateController.text),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildDateTile('To Date', _endDateController.text),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _editableDateTile(
            'From Date',
            _startDateController,
            _pickStartDate,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _editableDateTile(
            'To Date',
            _endDateController,
            _pickEndDate,
          ),
        ),
      ],
    );
  }

  Widget _editableDateTile(
    String title,
    TextEditingController controller,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF96222),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  debugPrint(
                    '[StallDetail] validator FAIL: $title (date) empty (v=$v)',
                  );
                  return 'Required';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTile(String title, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFFF96222),
          ),
        ),
        const SizedBox(height: 5),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          date,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      ],
    );
  }

  Widget _buildTimeSection() {
    if (!_isEditMode) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildTimeTile('Opening Time', _openingTimeController.text),
          ),
          Expanded(
            child: _buildTimeTile('Closing Time', _closingTimeController.text),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _editableTimeTile(
            'Opening Time',
            _openingTimeController,
            _pickOpeningTime,
          ),
        ),
        Expanded(
          child: _editableTimeTile(
            'Closing Time',
            _closingTimeController,
            _pickClosingTime,
          ),
        ),
      ],
    );
  }

  Widget _editableTimeTile(
    String title,
    TextEditingController controller,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF96222),
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onTap,
            child: AbsorbPointer(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon:
                      const Icon(Icons.access_time, size: 20, color: Colors.orange),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    debugPrint(
                      '[StallDetail] validator FAIL: $title (time) empty (v=$v)',
                    );
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile(String title, String time) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF96222),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

}
