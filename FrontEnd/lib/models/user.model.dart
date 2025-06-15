class UserModel {
  String email;
  String name;
  String password;

  UserModel({
    required this.email,
    required this.name,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'name': name,
    'password': password,
  };
}
