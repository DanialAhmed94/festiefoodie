class DishReviewResponse {
  final Reviews? reviews; // For paginated response
  final List<ReviewData>? flatData; // For fallback empty response
  final int status;
  final String message;

  DishReviewResponse({
    this.reviews,
    this.flatData,
    required this.status,
    required this.message,
  });

  factory DishReviewResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('reviews') && json['reviews'] != null) {
      return DishReviewResponse(
        reviews: Reviews.fromJson(json['reviews']),
        status: json['status'],
        message: json['message'],
      );
    } else {
      final data = json['data'] ?? json['flat_data'];
      return DishReviewResponse(
        flatData: data != null && data is List
            ? data.map<ReviewData>((e) => ReviewData.fromJson(e)).toList()
            : [],
        status: json['status'],
        message: json['message'],
      );
    }
  }
}

class Reviews {
  final int currentPage;
  final List<ReviewData> data;
  final String firstPageUrl;
  final int? from;
  final int lastPage;
  final String lastPageUrl;
  final List<ReviewLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int? to;
  final int total;

  Reviews({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    this.to,
    required this.total,
  });

  factory Reviews.fromJson(Map<String, dynamic> json) {
    return Reviews(
      currentPage: json['current_page'],
      data: List<ReviewData>.from(
          json['data'].map((x) => ReviewData.fromJson(x))),
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      links: List<ReviewLink>.from(
          json['links'].map((x) => ReviewLink.fromJson(x))),
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'],
    );
  }
}

class ReviewData {
  final String reviewDate;
  final String customerName;
  final int totalScore;
  final String dishName;
  final String? picture1Url; // New field
  final String? picture2Url; // New fiel
  ReviewData({
    required this.reviewDate,
    required this.customerName,
    required this.totalScore,
    required this.dishName,
    this.picture1Url,
    this.picture2Url,
  });

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
      reviewDate: json['review_date'],
      customerName: json['customer_name'],
      totalScore: json['total_score'],
      dishName: json['dish_name'],
      picture1Url: json['picture1_url'],
      picture2Url: json['picture2_url'],
    );
  }
}

class ReviewLink {
  final String? url;
  final String label;
  final bool active;

  ReviewLink({
    required this.url,
    required this.label,
    required this.active,
  });

  factory ReviewLink.fromJson(Map<String, dynamic> json) {
    return ReviewLink(
      url: json['url'],
      label: json['label'],
      active: json['active'],
    );
  }
}
