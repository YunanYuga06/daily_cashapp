class AssetModel {
    AssetModel({
        required this.id,
        required this.assetName,
    });

    final int id;
    final String assetName;

    factory AssetModel.fromJson(Map<String, dynamic> json) => AssetModel(
        id: json["id"],
        assetName: json["asset_name"],
    );
}