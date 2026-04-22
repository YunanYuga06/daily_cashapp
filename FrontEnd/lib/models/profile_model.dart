import 'dart:convert';

ProfileModel profileModelFromJson(String str) => ProfileModel.fromJson(json.decode(str)['data']);

class ProfileModel {
    ProfileModel({
        required this.name,
        required this.email,
        this.imageUrl,
    });

    final String name;
    final String email;
    final String? imageUrl;

    factory ProfileModel.fromJson(Map<String, dynamic> json) {
  return ProfileModel(
    name: json['name']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    // GUNAKAN .toString() atau handle null secara eksplisit
    imageUrl: json['photo']?.toString(), // Ini akan menjadi null (String?) jika di database null
  );
}
}