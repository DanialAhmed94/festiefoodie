import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../constants/appConstants.dart';
import '../../../utilities/reviewsScaffoldBackground.dart';
import '../../../providers/ratingsProvider.dart'; // Make sure this path is correct

class RatingDetail extends StatefulWidget {
  final List<String?> imageUrls; // List of image URLs (nullable)
  final String name;
  final String reviewer;
  final String reviewDate;
  final int score;

  const RatingDetail({
    super.key,
    required this.imageUrls,
    required this.name,
    required this.reviewer,
    required this.reviewDate,
    required this.score,
  });

  @override
  State<RatingDetail> createState() => _RatingDetailState();
}

class _RatingDetailState extends State<RatingDetail> {
  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final images = widget.imageUrls;
        return ReviewsScaffold(
          customAppbar: AppBar(
            backgroundColor: const Color(0xFFF9F9F9),
            centerTitle: true,
            title: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Rating's Detail",
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
          child:Column(
            children: [
              const SizedBox(height: 20),
              images.isNotEmpty
                  ? Column(
                children: [
                  carousel.CarouselSlider.builder(
                    itemCount: images.length,
                    itemBuilder: (context, index, realIndex) {
                      final imageUrl = images[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imageUrl != null && imageUrl.isNotEmpty
                              ?
                          CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              color: Colors.orange,
                            ),
                          ),
                          errorWidget: (context, url, error) => _noImageWidget(),
                        )

                          : _noImageWidget(),
                        ),
                      );
                    },
                    options: carousel.CarouselOptions(
                      height: 220,
                      //autoPlay: true,
                       enableInfiniteScroll:false,
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          activeIndex = index;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (images.length >= 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: DotsIndicator(
                        dotsCount: images.length,
                        position: activeIndex.toDouble(),
                        decorator: DotsDecorator(
                          color: Colors.black,
                          activeColor: Colors.orange,
                          size: const Size.square(9.0),
                          activeSize: const Size(12.0, 6.0),
                          activeShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                    ),

                ],
              )
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange, width: 4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _noImageWidget(),
                  ),
                ),
              ),


              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),),
                  color: Colors.white,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow("Name:", widget.name),
                        _infoRow("Reviewer:", widget.reviewer),
                        _infoRow("Review Date:", widget.reviewDate),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Score: ${widget.score}/100",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        );
  }
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title ",
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noImageWidget() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Text(
        "No Image Available",
        style: TextStyle(color: Colors.black54, fontSize: 16),
      ),
    );
  }
}


