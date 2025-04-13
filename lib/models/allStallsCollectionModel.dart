import 'package:flutter/material.dart';

class StallCollectionResponse {
  final int status;
  final StallCollectionData data;
  final String message;

  StallCollectionResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory StallCollectionResponse.fromJson(Map<String, dynamic> json) {
    final dataField = json['data'];

    // Check if data is a List — fallback format
    if (dataField is List) {
      return StallCollectionResponse(
        status: json['status'] as int,
        data: StallCollectionData(
          currentPage: 1,
          stalls: dataField.map((e) => Stall.fromJson(e)).toList(),
          firstPageUrl: '',
          from: 1,
          lastPage: 1,
          lastPageUrl: '',
          links: [],
          nextPageUrl: null,
          path: '',
          perPage: dataField.length,
          prevPageUrl: null,
          to: dataField.length,
          total: dataField.length,
        ),
        message: json['message'] as String,
      );
    }

    // Normal case
    return StallCollectionResponse(
      status: json['status'] as int,
      data: StallCollectionData.fromJson(dataField as Map<String, dynamic>),
      message: json['message'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
      'message': message,
    };
  }
}

class StallCollectionData {
  final int currentPage;
  final List<Stall> stalls;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<Link> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  StallCollectionData({
    required this.currentPage,
    required this.stalls,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory StallCollectionData.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing StallCollectionData');
    debugPrint('Inner data type (should be List): ${json['data'].runtimeType}');
    return StallCollectionData(
      currentPage: json['current_page'] as int,
      stalls: (json['data'] as List<dynamic>)
          .map((e) => Stall.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstPageUrl: json['first_page_url'] as String,
      from: json['from'] as int,
      lastPage: json['last_page'] as int,
      lastPageUrl: json['last_page_url'] as String,
      links: (json['links'] as List<dynamic>)
          .map((e) => Link.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextPageUrl: json['next_page_url'] as String?,
      path: json['path'] as String,
      perPage: json['per_page'] is int
          ? json['per_page'] as int
          : int.parse(json['per_page'].toString()),
      prevPageUrl: json['prev_page_url'] as String?,
      to: json['to'] as int,
      total: json['total'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data': stalls.map((e) => e.toJson()).toList(),
      'first_page_url': firstPageUrl,
      'from': from,
      'last_page': lastPage,
      'last_page_url': lastPageUrl,
      'links': links.map((e) => e.toJson()).toList(),
      'next_page_url': nextPageUrl,
      'path': path,
      'per_page': perPage,
      'prev_page_url': prevPageUrl,
      'to': to,
      'total': total,
    };
  }
}

class Stall {
  final int id;
  final int userId;
  final String festivalId;
  final String eventId;
  final String stallName;
  final String image;
  final String latitude;
  final String longitude;
  final String fromDate;
  final String toDate;
  final String openingTime;
  final String closingTime;
  final String createdAt;
  final String updatedAt;
  final dynamic festivalName; // Could be String or null.
  final dynamic eventName; // Could be String or null.

  Stall({
    required this.id,
    required this.userId,
    required this.festivalId,
    required this.eventId,
    required this.stallName,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.fromDate,
    required this.toDate,
    required this.openingTime,
    required this.closingTime,
    required this.createdAt,
    required this.updatedAt,
    this.festivalName,
    this.eventName,
  });

  factory Stall.fromJson(Map<String, dynamic> json) {
    return Stall(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      festivalId: json['festival_id'] as String,
      eventId: json['event_id'] as String,
      stallName: json['stall_name'] as String,
      image: json['image'] as String,
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      fromDate: json['from_date'] as String,
      toDate: json['to_date'] as String,
      openingTime: json['opening_time'] as String,
      closingTime: json['closing_time'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      festivalName: json['festival_name'],
      eventName: json['event_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'festival_id': festivalId,
      'event_id': eventId,
      'stall_name': stallName,
      'image': image,
      'latitude': latitude,
      'longitude': longitude,
      'from_date': fromDate,
      'to_date': toDate,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'festival_name': festivalName,
      'event_name': eventName,
    };
  }
}

class Link {
  final String? url;
  final String label;
  final bool active;

  Link({
    this.url,
    required this.label,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      url: json['url'] as String?,
      label: json['label'] as String,
      active: json['active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'label': label,
      'active': active,
    };
  }
}
