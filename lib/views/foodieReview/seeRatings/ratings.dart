import 'package:festiefoodie/views/foodieReview/seeRatings/reviewDetail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../annim/transiton.dart';
import '../../../constants/appConstants.dart';
import '../../../utilities/reviewsScaffoldBackground.dart';
import '../../../providers/ratingsProvider.dart'; // Make sure this path is correct

class Ratings extends StatelessWidget {
  final String dishId;

  const Ratings({super.key, required this.dishId});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
      create: (_) => RatingsProvider()..fetchInitialRatings(context, dishId),
      child: Consumer<RatingsProvider>(
        builder: (context, provider, _) {
          return ReviewsScaffold(
            customAppbar: AppBar(
              backgroundColor: const Color(0xFFF9F9F9),
              centerTitle: true,
              title: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Ratings",
                  style: TextStyle(
                    fontFamily: "inter-semibold",
                    fontSize: screenWidth * 0.06,
                    color: Colors.black,
                  ),
                ),
              ),
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: SvgPicture.asset(AppConstants.backIcon),
              ),
              leadingWidth: 40,
            ),
            child: provider.isFetching
                ? const Center(child: CircularProgressIndicator())
                : provider.reviews.isEmpty
                    ? const Center(child: Text("No reviews found."))
                    : Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05),
                        child: ListView.builder(
                          itemCount: provider.reviews.length + 1,
                          itemBuilder: (context, index) {
                            if (index == provider.reviews.length) {
                              return _buildLoadMoreSection(context, provider);
                            }

                            final rating = provider.reviews[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.015,
                                horizontal: screenWidth * 0.04,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: buildRichText("Dish Name: ", rating.dishName, screenWidth),
                                      ),
                                      SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 10,
                                          ),
                                        ),
                                        onPressed: () {
                                          final imageUrls = [
                                            rating.picture1Url,
                                            rating.picture2Url,
                                          ].whereType<String>() // Removes nulls
                                              .where((url) => url.isNotEmpty) // Removes empty strings
                                              .toList();

                                          Navigator.push(
                                            context,
                                            FadePageRouteBuilder(
                                              widget: RatingDetail(
                                                name: rating.dishName,
                                                reviewer: rating.customerName,
                                                reviewDate: rating.reviewDate,
                                                score: rating.totalScore,
                                                imageUrls:imageUrls,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              "OPEN",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontFamily: "inter-semibold",
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            const Icon(Icons.arrow_forward, color: Colors.white),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.005),
                                  buildRichText("Date: ", rating.reviewDate, screenWidth),
                                  SizedBox(height: screenHeight * 0.005),
                                  buildRichText("Reviewer Name: ", rating.customerName, screenWidth),
                                  SizedBox(height: screenHeight * 0.01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildRichText(
                                        "Score: ",
                                        "${rating.totalScore} / 100.0",
                                        screenWidth,
                                      ),
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(12),
                                        ),
                                        child: Container(
                                          height: screenHeight * 0.05,
                                          color: Colors.orange,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Center(
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  "${rating.totalScore} / 100.0",
                                                  style: TextStyle(
                                                    fontSize: screenWidth * 0.035,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                            ;
                          },
                        ),
                      ),
          );
        },
      ),
    );
  }

  Widget buildRichText(String title, String value, double screenWidth) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreSection(BuildContext context, RatingsProvider provider) {
    if (!provider.hasMorePages) {
      return const SizedBox.shrink(); // No more pages
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: provider.isFetchingMore
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () {
                  provider.fetchMoreRatings(context, dishId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Load More",
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }
}


