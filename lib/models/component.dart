class Component {
  String sku;
  String upc;
  int? palletCapacity;

  Component({
    required this.sku,
    required this.upc,
    this.palletCapacity
  });

  // Factory method to create an Lpn from JSON
  factory Component.fromJson(Map<String, dynamic> json) {
    return Component(
      sku: json['sku'].toString(),
      upc: json['upc'].toString(),
      palletCapacity: json['palletCapacity'] != null
          ? int.tryParse(json['palletCapacity'].toString())
          : null, // Safely parse or assign null
    );
  }
}