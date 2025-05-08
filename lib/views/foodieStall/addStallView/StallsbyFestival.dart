import 'package:festiefoodie/annim/transiton.dart';
import 'package:festiefoodie/constants/appConstants.dart';
import 'package:festiefoodie/views/foodieStall/addStallView/stallDetailView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../models/allStallsCollectionModel.dart';
import '../../../providers/stallProvider.dart';
import '../../../utilities/scaffoldBackground.dart';

class ViewAllStallsView extends StatefulWidget {
  final String festivalId;

  const ViewAllStallsView({Key? key, required this.festivalId})
      : super(key: key);

  @override
  State<ViewAllStallsView> createState() => _ViewAllStallsViewState();
}

class _ViewAllStallsViewState extends State<ViewAllStallsView> {
  @override
  void initState() {
    super.initState();
    // Fetch stalls by festival on every visit.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StallProvider>(context, listen: false).fetchStallsByFestival(
          context, widget.festivalId,
          isfromReviewSection: false);
    });
  }

  @override
  @override
  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: Consumer<StallProvider>(
        builder: (context, stallProvider, child) {
          Widget body;

          if (stallProvider.isFetching &&
              stallProvider.stallsByFestival.isEmpty) {
            body = const Center(child: CircularProgressIndicator());
          } else if (stallProvider.errorMessage != null &&
              stallProvider.stallsByFestival.isEmpty) {
            body = Center(
              child: Text(
                stallProvider.errorMessage!,
                style: const TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          } else if (!stallProvider.isFetching &&
              stallProvider.errorMessage == null &&
              stallProvider.stallsByFestival.isEmpty) {
            body = const Center(
              child: Text(
                "No stalls available.",
                style: TextStyle(fontSize: 16),
              ),
            );
          } else {
            body = ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stallProvider.stallsByFestival.length,
              itemBuilder: (context, index) {
                final stall = stallProvider.stallsByFestival[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildStallCard(
                      context,
                      MediaQuery.of(context).size.width * 0.95,
                      stall.stallName,
                      stall),
                );
              },
            );
          }

          return Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                title: const Text(
                  "All Stalls",
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
              const SizedBox(height: 10),
              Expanded(
                child: body,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStallCard(
      BuildContext context, double width, String title, Stall stall) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              child: Container(
                width: width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 90),
                    // Reserved space for left border.
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: "inter-semibold",
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              FadePageRouteBuilder(
                                  widget: StallDetailView(
                                closingTime: stall.closingTime,
                                festivalName: stall.festivalName,
                                endDate: stall.toDate,
                                startDate: stall.fromDate,
                                longitude: stall.longitude,
                                latitude: stall.latitude,imageUrl: stall.image,openingTime: stall.openingTime,stallName: stall.stallName,
                              )));
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(
                          //     content: const Text(
                          //       "This feature is in development phase.",
                          //       style: TextStyle(
                          //         fontFamily: "inter-medium",
                          //         fontSize: 14,
                          //         color: Colors.white,
                          //       ),
                          //     ),
                          //     backgroundColor: Colors.black87,
                          //     behavior: SnackBarBehavior.floating,
                          //     action: SnackBarAction(
                          //       label: "OK",
                          //       textColor: Colors.orange,
                          //       onPressed: () {},
                          //     ),
                          //   ),
                          // );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text(
                          "View Detail",
                          style: TextStyle(
                            fontFamily: "inter-medium",
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Container(
                  width: 90,
                  color: Colors.transparent,
                  child: SvgPicture.asset(
                    AppConstants.stallCardleftborder,
                    height: constraints.maxHeight,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
