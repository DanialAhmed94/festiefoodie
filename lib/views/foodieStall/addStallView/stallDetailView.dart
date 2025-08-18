import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/appConstants.dart';
import '../../../models/menuItemModel.dart';
import '../../../providers/eventProvider.dart';
import '../../../providers/festivalProvider.dart';
import '../../../utilities/scaffoldBackground.dart';

class StallDetailView extends StatefulWidget {
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



  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              title: const Text(
                "Stall Detail",
                style: TextStyle(
                  fontFamily: "inter-semibold",
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: SvgPicture.asset(AppConstants.backIcon, height: 50),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow("Festival:", widget.festivalName ?? "Loading..."),
                    _buildDetailRow("Event:", widget.eventName ?? "Not specified"),
                    _buildDetailRow("Stall Name:", widget.stallName),
                    const SizedBox(height: 20),
                    _buildImageSection(),
                    const SizedBox(height: 20),
                    _buildDetailRow("Latitude:", widget.latitude),
                    _buildDetailRow("Longitude:", widget.longitude),




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
                          vertical: MediaQuery.of(context).size.height * 0.015,
                          horizontal: MediaQuery.of(context).size.width * 0.05,
                        ),
                      ),
                      onPressed: () async {
                         String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=${widget.latitude},${widget.longitude}'; // Replace with actual coordinates
                        final Uri uri = Uri.parse(googleMapsUrl);

                        try {
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Google Maps not installed. Please install Google Maps to use navigation',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.red.shade600, // Error color
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                margin: const EdgeInsets.all(16),
                                duration: const Duration(seconds: 3),
                                action: SnackBarAction(
                                  label: 'OK',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  },
                                ),
                              ),
                            );

                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Error opening navigation: ${e.toString()}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.red.shade600, // Error color
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 3),
                              action: SnackBarAction(
                                label: 'OK',
                                textColor: Colors.white,
                                onPressed: () {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
                            "Navigation",
                            style: TextStyle(
                              fontFamily: "inter-semibold",
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                          const Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

                    const SizedBox(height: 20),
                    _buildDateSection(),
                    const SizedBox(height: 20),
                    _buildTimeSection(),
                    const SizedBox(height: 20),
                   // _buildMenuItemsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
              maxLines: 1,
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
          "Stall Image",
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
            child: widget.imageUrl.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: widget.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFF96222),
                ),
              ),
              errorWidget: (context, url, error) => Center(
                child: Icon(Icons.error_outline_sharp,color:const Color(0xFFF96222)),
              ),
            )
                : Center(
              child: Icon(Icons.error_outline_sharp,color:const Color(0xFFF96222),)
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Row(
      children: [
        Expanded(
          child: _buildDateTile("From Date", widget.startDate),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildDateTile("To Date", widget.endDate),
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
      )),
     SizedBox(height: 5),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildTimeTile("Opening Time", widget.openingTime)),
        
        Expanded(child: _buildTimeTile("Closing Time", widget.closingTime)),
      ],
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
  Widget _buildMenuItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Menu Items",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        // ...widget.menuItems.map((item) => _buildMenuItemCard(item)).toList(),
      ],
    );
  }

  Widget _buildMenuItemCard(MenuItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.dishNameController.text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 20),
          Text(
            "\$${item.priceController.text}",
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF96222)),
          ),
        ],
      ),
    );
  }
}