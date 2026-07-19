import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.userName,
    required super.email,
    required super.phoneNumber,
    super.organizationId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      organizationId: _organizationId(json),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'phone_number': phoneNumber,
      'organization_id': organizationId,
    };
  }

  static int _organizationId(Map<String, dynamic> json) {
    final value = json['organization_id'] ??
        json['organizationId'] ??
        (json['organization'] is Map
            ? (json['organization'] as Map)['id']
            : null);
    return value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
