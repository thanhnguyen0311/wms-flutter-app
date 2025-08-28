import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ZebraPrinter {
  BluetoothConnection? _connection;

  /// Generate ZPL code for a simple label
  String generateZPL({
    required String text,
    int x = 50,
    int y = 50,
    int fontSize = 30,
    String fontType = '^A0',
  }) {
    return '''
          ^XA
          ^FO$x,$y
          $fontType,N,$fontSize,$fontSize
          ^FD$text^FS
          ^XZ
          ''';
  }

  /// Generate ZPL code for a barcode label
  String generateBarcodeZPL({
    required String barcodeData,
    required String text,
    int barcodeX = 50,
    int barcodeY = 50,
    int textX = 50,
    int textY = 150,
    String barcodeType = '^BC', // Code 128
    int barcodeHeight = 100,
  }) {
    return '''
          ^XA
          ^FO$barcodeX,$barcodeY
          ${barcodeType}N,$barcodeHeight,Y,N,N
          ^FD$barcodeData^FS
          ^FO$textX,$textY
          ^A0N,30,30
          ^FD$text^FS
          ^XZ
          ''';
  }

  /// Connect to Zebra printer via MAC address
  Future<bool> connectToPrinter(String macAddress) async {
    try {
      // Check if Bluetooth is enabled
      bool? isEnabled = await FlutterBluetoothSerial.instance.isEnabled;
      if (isEnabled != true) {
        print('Bluetooth is not enabled');
        return false;
      }

      // Parse MAC address
      BluetoothDevice device = BluetoothDevice(
        name: 'Zebra Printer',
        address: macAddress,
      );

      // Connect to the device
      _connection = await BluetoothConnection.toAddress(macAddress);
      print('Connected to printer: $macAddress');
      return true;

    } catch (e) {
      print('Error connecting to printer: $e');
      return false;
    }
  }

  /// Send ZPL data to the connected printer
  Future<bool> sendZPL(String zplData) async {
    if (_connection == null || !_connection!.isConnected) {
      print('Printer not connected');
      return false;
    }

    try {
      // Convert ZPL string to bytes
      Uint8List data = Uint8List.fromList(utf8.encode(zplData));

      // Send data to printer
      _connection!.output.add(data);
      await _connection!.output.allSent;

      print('ZPL data sent successfully');
      return true;

    } catch (e) {
      print('Error sending ZPL data: $e');
      return false;
    }
  }

  /// Print a simple text label
  Future<bool> printTextLabel({
    required String macAddress,
    required String text,
    int x = 50,
    int y = 50,
    int fontSize = 30,
  }) async {
    // Generate ZPL
    String zpl = generateZPL(
      text: text,
      x: x,
      y: y,
      fontSize: fontSize,
    );

    // Connect and print
    bool connected = await connectToPrinter(macAddress);
    if (!connected) return false;

    bool sent = await sendZPL(zpl);
    await disconnect();

    return sent;
  }

  /// Print a barcode label
  Future<bool> printBarcodeLabel({
    required String macAddress,
    required String barcodeData,
    required String text,
    int barcodeX = 50,
    int barcodeY = 50,
    int textX = 50,
    int textY = 150,
  }) async {
    // Generate ZPL
    String zpl = generateBarcodeZPL(
      barcodeData: barcodeData,
      text: text,
      barcodeX: barcodeX,
      barcodeY: barcodeY,
      textX: textX,
      textY: textY,
    );

    // Connect and print
    bool connected = await connectToPrinter(macAddress);
    if (!connected) return false;

    bool sent = await sendZPL(zpl);
    await disconnect();

    return sent;
  }

  /// Print multiple labels in batch
  Future<bool> printBatch({
    required String macAddress,
    required List<String> zplCommands,
  }) async {
    bool connected = await connectToPrinter(macAddress);
    if (!connected) return false;

    try {
      for (String zpl in zplCommands) {
        bool sent = await sendZPL(zpl);
        if (!sent) {
          await disconnect();
          return false;
        }
        // Small delay between prints
        await Future.delayed(Duration(milliseconds: 100));
      }

      await disconnect();
      return true;

    } catch (e) {
      print('Error in batch printing: $e');
      await disconnect();
      return false;
    }
  }

  /// Disconnect from printer
  Future<void> disconnect() async {
    if (_connection != null && _connection!.isConnected) {
      await _connection!.close();
      _connection = null;
      print('Disconnected from printer');
    }
  }

  /// Test printer connectivity
  Future<bool> testPrinter(String macAddress) async {
    String testZpl = '''
                      ^XA
                      ^FO50,50
                      ^A0N,30,30
                      ^FDTest Print^FS
                      ^XZ
                      ''';

    bool connected = await connectToPrinter(macAddress);
    if (!connected) return false;

    bool sent = await sendZPL(testZpl);
    await disconnect();

    return sent;
  }

  /// Get available Bluetooth devices
  static Future<List<BluetoothDevice>> getAvailableDevices() async {
    try {
      List<BluetoothDevice> devices =
      await FlutterBluetoothSerial.instance.getBondedDevices();

      // Filter for potential Zebra printers
      List<BluetoothDevice> printers = devices.where((device) {
        String name = device.name?.toLowerCase() ?? '';
        return name.contains('zebra') ||
            name.contains('printer') ||
            name.contains('zp') ||
            name.contains('zm') ||
            name.contains('zt');
      }).toList();

      return printers;
    } catch (e) {
      print('Error getting devices: $e');
      return [];
    }
  }
}