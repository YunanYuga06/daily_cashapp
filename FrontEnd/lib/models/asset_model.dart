// lib/models/asset_model.dart

class AssetModel {
  AssetModel({
    required this.id,
    required this.assetName,
    required this.assetType,
    required this.first_amount,
  });

  final int id;
  final String assetName;
  final String assetType;
  final int first_amount;

  factory AssetModel.fromJson(Map<String, dynamic> json) => AssetModel(
    id: json["id"],
    assetName: json["asset_name"],
    assetType: json["asset_type"],
    first_amount: json["first_amount"],
  );
}
