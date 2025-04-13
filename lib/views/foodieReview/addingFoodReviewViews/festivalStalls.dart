import 'package:festiefoodie/annim/transiton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants/appConstants.dart';
import '../../../providers/stallProvider.dart';
import '../../../utilities/reviewsScaffoldBackground.dart';
import 'stallMenu.dart';
import 'package:cached_network_image/cached_network_image.dart';
class FestivalStalls extends StatefulWidget {
  const FestivalStalls({required this.festivalId});
  final String festivalId;

  @override
  State<FestivalStalls> createState() => _FestivalStallsState();
}

class _FestivalStallsState extends State<FestivalStalls> {
  late Future<void> _stallFuture;

  @override
  void initState() {
    super.initState();
    _stallFuture = Provider.of<StallProvider>(context, listen: false)
        .fetchStallsByFestival(context, widget.festivalId,isfromReviewSection: true);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ReviewsScaffold(
      customAppbar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        centerTitle: true,
        title: Text(
          "Stalls",
          style: TextStyle(
            fontFamily: "inter-semibold",
            fontSize: screenWidth * 0.08,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(AppConstants.backIcon),
        ),
        leadingWidth: 40,
      ),
      child: FutureBuilder(
        future: _stallFuture,
        builder: (context, snapshot) {
          final stalls = Provider.of<StallProvider>(context).stallsByFestival;
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          if (isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            );
          } else if (stalls.isEmpty) {
            return const Center(
              child: Text(
                "There is nothing to show",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "inter-semibold",
                  color: Colors.black54,
                ),
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: ListView.builder(
              itemCount: stalls.length,
              itemBuilder: (context, index) {
                final stall = stalls[index];

                return Container(
                  margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stall.stallName,
                              style: TextStyle(
                                fontFamily: "inter-bold",
                                fontSize: screenWidth * 0.05,
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Text(
                              "From: ${stall.fromDate}",
                              style: TextStyle(
                                fontFamily: "inter-regular",
                                fontSize: screenWidth * 0.04,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "To: ${stall.toDate}",
                              style: TextStyle(
                                fontFamily: "inter-regular",
                                fontSize: screenWidth * 0.04,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.015,
                                  horizontal: screenWidth * 0.06,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  FadePageRouteBuilder(widget: StallMenu(stallId: stall.id.toString(),)),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "OPEN",
                                    style: TextStyle(
                                      fontFamily: "inter-semibold",
                                      fontSize: screenWidth * 0.04,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  const Icon(Icons.arrow_forward,
                                      color: Colors.white),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: stall.image,
                          width: screenWidth * 0.25,
                          height: screenHeight * 0.12,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: screenWidth * 0.25,
                            height: screenHeight * 0.12,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                              color: Colors.orange,
                              strokeWidth: 2,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


