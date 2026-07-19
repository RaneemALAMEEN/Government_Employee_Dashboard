class User {
  final int id;
  final String userName;
  final String email;
  final String phoneNumber;
  final int organizationId;

  User({
    required this.id,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    this.organizationId = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'phoneNumber': phoneNumber,
      'organization_id': organizationId,
    };
  }
}
