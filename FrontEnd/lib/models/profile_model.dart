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

    factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        name: json["name"],
        email: json["email"],
        imageUrl: json["image_url"],
    );
}