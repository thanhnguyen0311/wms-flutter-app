class Lpn {
  String tagID;
  String sku;
  int quantity;
  String containerNumber;
  String bayCode;
  String zone;
  String status;
  DateTime date;

  Lpn({
    required this.tagID,
    required this.sku,
    required this.quantity,
    required this.containerNumber,
    required this.bayCode,
    required this.zone,
    required this.status,
    required this.date,
  });

  // Factory method to create an Lpn from JSON
  factory Lpn.fromJson(Map<String, dynamic> json) {
    return Lpn(
      tagID: json['tagID'].toString(),
      sku: json['sku'].toString(),
      quantity: json['quantity'] is int ? json['quantity'] : int.parse(json['quantity'].toString()),
      containerNumber: json['containerNumber'].toString(),
      bayCode: json['bayCode'].toString(),
      zone: json['zone'].toString(),
      status: json['status'].toString(),
      date: DateTime.parse(json['date'].toString()),
    );
  }

  // Method to convert an Lpn instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'tagID': tagID,
      'sku': sku,
      'quantity': quantity,
      'containerNumber': containerNumber,
      'bayCode': bayCode,
      'zone': zone,
      'status': status,
      'date': date.toIso8601String(), // Serialize DateTime to ISO string
    };
  }

  // Method to convert an Lpn instance to JSON
  Map<String, dynamic> toLPNRequestDtoJson() {
    return {
      'tagID': tagID,
      'sku': sku,
      'quantity': quantity,
      'containerNumber': containerNumber,
      'bayCode': bayCode,
      'date': date.toIso8601String(), // Serialize DateTime to ISO string
    };
  }
}