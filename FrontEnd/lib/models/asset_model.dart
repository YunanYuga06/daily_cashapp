 class AssetModel {
     AssetModel({
         required this.id,
         required this.assetName,
        this.assetType = '',
        this.currentAmount = 0,
     });

     final int id;
     final String assetName;
    final String assetType;
    final int currentAmount;

     factory AssetModel.fromJson(Map<String, dynamic> json) => AssetModel(
         id: json["id"],
         assetName: json["asset_name"],
        assetType: json["asset_type"] ?? '',
        currentAmount: (json["current_amount"] is int)
            ? json["current_amount"]
            : int.tryParse(json["current_amount"]?.toString() ?? '0') ?? 0,
     );
 }
