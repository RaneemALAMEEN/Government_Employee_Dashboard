class User {
  final int id;
  final String userName;
  final String email;
  final String phoneNumber;

  User({
    required this.id,
    required this.userName,
    required this.email,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}