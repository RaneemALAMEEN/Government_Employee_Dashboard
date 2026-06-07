class LoginRequestModel {
  final String userName;
  final String password;

  LoginRequestModel({
    required this.userName,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "userName": userName,
      "password": password,
    };
  }
}