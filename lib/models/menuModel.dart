
class Menu {
  final int status;
  final List<MenuItemApi> data;
  final String message;

  Menu({
    required this.status,
    required this.data,
    required this.message,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      status: json['status'] ?? 0,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => MenuItemApi.fromJson(e))
          .toList() ??
          [],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}
class MenuItemApi {
  final int id;
  final String stallId;
  final String dishName;
  final String dishPrice;
  final String createdAt;
  final String updatedAt;
  final String stallName;

  MenuItemApi({
    required this.id,
    required this.stallId,
    required this.dishName,
    required this.dishPrice,
    required this.createdAt,
    required this.updatedAt,
    required this.stallName,
  });

  factory MenuItemApi.fromJson(Map<String, dynamic> json) {
    return MenuItemApi(
      id: json['id'] ?? 0,
      stallId: json['stall_id'] ?? '',
      dishName: json['dish_name'] ?? '',
      dishPrice: json['dish_price'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      stallName: json['stall_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stall_id': stallId,
      'dish_name': dishName,
      'dish_price': dishPrice,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'stall_name': stallName,
    };
  }
}
