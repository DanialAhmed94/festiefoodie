import 'package:festiefoodie/views/foodieReview/seeRatings/stallsByFestival.dart';
import 'package:festiefoodie/views/foodieStall/addStallView/StallsbyFestival.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../annim/transiton.dart';
import '../../../constants/appConstants.dart';
import '../../../providers/festivalProvider.dart';
import '../../../utilities/reviewsScaffoldBackground.dart';
import '../../../utilities/scaffoldBackground.dart';

class SeeAllFestivals extends StatefulWidget {
  const SeeAllFestivals({super.key});

  @override
  State<SeeAllFestivals> createState() => _ViewAllFestivalsState();
}

class _ViewAllFestivalsState extends State<SeeAllFestivals> {
  @override
  void initState() {
    super.initState();
    // Fetch festivals once the widget is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FestivalProvider>(context, listen: false).fetchFestivals(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ReviewsScaffold(
      customAppbar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        centerTitle: true,
        title: Text(
          "Festivals",
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
      child: Consumer<FestivalProvider>(
        builder: (context, festivalProvider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [

                const SizedBox(height: 10),
                if (festivalProvider.isFetching && festivalProvider.festivals.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (festivalProvider.festivals.isEmpty)
                  const Center(child: Text("No festivals available."))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: festivalProvider.festivals.length,
                    itemBuilder: (context, index) {
                      final festival = festivalProvider.festivals[index];
                      // Assuming your FestivalResource model has a property called 'festivalName'
                      final title =   festival.nameOrganizer ??
                          festival.description;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            FadePageRouteBuilder(widget:  StallsByFestival(festivalId: festival.id.toString())),
                          ),
                          child: _buildFestivalCard(
                            context,
                            MediaQuery.of(context).size.width * 0.95,
                            title,
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFestivalCard(BuildContext context, double width, String title) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth;
        // Define left border width as a fraction of the card width (e.g., 20%)
        final double leftBorderWidth = cardWidth * 0.2;
        return Stack(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              child: Container(
                width: cardWidth,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Reserve space for the left border using computed width.
                    SizedBox(width: leftBorderWidth),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Festival Name:",
                            style: TextStyle(
                              fontFamily: "inter-bold",
                              fontSize: 16,
                              color: Color(0xFFF96222),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: const TextStyle(
                              fontFamily: "inter-semibold",
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 36,
                      child: IconButton(
                        onPressed: null,
                        icon: SvgPicture.asset(AppConstants.forwardIcon),
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
                  width: leftBorderWidth,
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


