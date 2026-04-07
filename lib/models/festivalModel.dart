class FestivalResponse {
  final String message;
  final List<FestivalResource> data;
  final int currentPage;
  final int lastPage;

  FestivalResponse({
    required this.message,
    required this.data,
    this.currentPage = 1,
    this.lastPage = 1,
  });

  factory FestivalResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<FestivalResource> list = [];
    int currentPage = 1;
    int lastPage = 1;
    if (rawData is Map<String, dynamic>) {
      currentPage = (rawData['current_page'] is int)
          ? rawData['current_page'] as int
          : (int.tryParse(rawData['current_page']?.toString() ?? '1') ?? 1);
      lastPage = (rawData['last_page'] is int)
          ? rawData['last_page'] as int
          : (int.tryParse(rawData['last_page']?.toString() ?? '') ?? currentPage);
      final innerList = rawData['data'];
      if (innerList is List) {
        list = innerList
            .map((item) => FestivalResource.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } else if (rawData is List) {
      list = rawData
          .map((item) => FestivalResource.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return FestivalResponse(
      message: json['message'] as String? ?? '',
      data: list,
      currentPage: currentPage,
      lastPage: lastPage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class FestivalResource {
  final int id;
  final String description;
  final String? descriptionOrganizer;
  final String? nameOrganizer;
  final String image;
  final String latitude;
  final String longitude;
  final String startingDate;
  final String endingDate;
  final String? time;
  final String? price;
  final String? innerImage;
  final String createdAt;
  final String updatedAt;

  FestivalResource({
    required this.id,
    required this.description,
    this.descriptionOrganizer,
    this.nameOrganizer,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.startingDate,
    required this.endingDate,
    this.time,
    this.price,
    this.innerImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FestivalResource.fromJson(Map<String, dynamic> json) {
    return FestivalResource(
      id: json['id'] as int,
      description: json['description']?.toString() ?? '',
      descriptionOrganizer: json['description_organizer']?.toString(),
      nameOrganizer: json['name_organizer']?.toString(),
      image: json['image']?.toString() ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      startingDate: json['starting_date']?.toString() ?? '',
      endingDate: json['ending_date']?.toString() ?? '',
      time: json['time']?.toString(),
      price: json['price']?.toString(),
      innerImage: json['inner_image']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'description_organizer': descriptionOrganizer,
      'name_organizer': nameOrganizer,
      'image': image,
      'latitude': latitude,
      'longitude': longitude,
      'starting_date': startingDate,
      'ending_date': endingDate,
      'time': time,
      'price': price,
      'inner_image': innerImage,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
