import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wms/models/component.dart';
import 'package:wms/models/lpn.dart';
import 'package:wms/services/component_service.dart';

import '../../exception/api_exception.dart';
import '../../services/lpn_service.dart';
import '../../utils/zpl_printer.dart';

class AddLpnScreen extends StatefulWidget {
  final List<Lpn> allLpns;

  const AddLpnScreen({Key? key, required this.allLpns}) : super(key: key);


  @override
  State<AddLpnScreen> createState() => _AddLpnScreenState();
}

class _AddLpnScreenState extends State<AddLpnScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  final ComponentService _componentService = ComponentService(); // Instantiate the service
  final LpnService _lpnService = LpnService();
  List<Component> allComponents = [];
  late List<Lpn> listLpns;
  Timer? _debounce;


  // Input fields
  final TextEditingController _tagIDController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _upcController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _containerNumberController = TextEditingController();
  final TextEditingController _bayCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    listLpns = widget.allLpns;
    _fetchComponents(); // Fetch components when the screen is loaded
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _debounce?.cancel();
    _tagIDController.dispose();
    _upcController.dispose();
    _skuController.dispose();
    _quantityController.dispose();
    _containerNumberController.dispose();
    _bayCodeController.dispose();
    super.dispose();
  }

  Future<void> _fetchComponents() async {
    setState(() {
      _loading = true; // Start loading
    });
    try {
      final List<Component> fetchedComponents = await _componentService.fetchAllComponents();
      setState(() {
        allComponents = fetchedComponents; // Update state with fetched components
      });
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching components: $e')),
      );
    } finally {
      setState(() {
        _loading = false; // Stop loading
      });
    }
  }

  Future<void> _printLabel() async {
    final ZebraPrinter printer = ZebraPrinter();
    String printerMac = "48:A4:93:C1:05:0B"; // Replace with your printer's MAC

    bool success = await printer.printTextLabel(
      macAddress: printerMac,
      text: "Hello World!",
      x: 50,
      y: 50,
      fontSize: 40,
    );

  }

  /// Function to retrieve and set SKU based on entered UPC
  void _onSkuChanged(String upc) {
    // Cancel the previous debounce timer if still active
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    if (upc.isEmpty) {
      setState(() {
        _skuController.text = "";
      });
      return;
    }
    // Start a new debounce timer
    _debounce = Timer(const Duration(seconds: 1), () {
      // Find the SKU based on the entered UPC
      final Component? retrievedComponent =
          _componentService.getSkuByUpc(upc, allComponents);
      // Automatically update the SKU field
      if (retrievedComponent != null) {
        setState(() {
          _skuController.text = retrievedComponent.sku;
          _quantityController.value = TextEditingValue(
            text: (retrievedComponent.palletCapacity ?? 0).toString(),
          );
        });
      }

    });
  }

    /// Function to submit form
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Form is valid, access the values
      final String tagID = _tagIDController.text.trim();
      final String sku = _skuController.text.trim();
      final int quantity = int.parse(_quantityController.text.trim());
      final String containerNumber = _containerNumberController.text.trim();
      final String bayCode = _bayCodeController.text.trim();


      // Create a new LPN object
      final newLpn = Lpn(
        tagID: tagID,
        sku: sku,
        quantity: quantity,
        containerNumber: containerNumber,
        bayCode: bayCode,
        zone: "",
        // For example, you can make this dynamic if needed
        status: "",
        // Default status
        date: DateTime.now(),
      );
      setState(() {
        _loading = true; // Show loading indicator
      });

      try {
        // Send LPN data to backend
        await _lpnService.addNewLpn(newLpn);

        if (!mounted) return;
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('LPN added successfully!')),
        );

        Navigator.pop(context, true); // Pass success to the previous screen
      } catch (e) {
        // Extract and handle error message
        String errorMessage = 'Failed to add LPN';
        if (e is SomeApiException) { // Replace with your specific exception class, e.g., HttpException
          errorMessage = e.message ?? 'Unknown error occurred'; // Extract the error message
        }

        if (!mounted) return;

        // Show the error message in a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );

      } finally {
        setState(() {
          _loading = false; // Hide loading indicator
        });
      }
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Color iconColor = Colors.blue,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool isDropdown = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    validator: validator,
                    onChanged: onChanged,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Create LPN',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.blue,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Form Fields
                    _buildInputField(
                      controller: _tagIDController,
                      label: 'RFID Tag',
                      icon: Icons.nfc,
                      iconColor: Colors.blue,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Tag ID';
                        }
                        if (_lpnService.isLpnExists(value, listLpns)) {
                          return "LPN already exists";
                        }
                        return null;
                      },
                    ),

                    _buildInputField(
                      controller: _upcController,
                      label: 'GTIN/UPC',
                      icon: Icons.qr_code_scanner,
                      iconColor: Colors.orange,
                      onChanged: _onSkuChanged,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter GTIN/UPC';
                        }
                        return null;
                      },
                    ),

                    Container(
                      margin: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SKU',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              _skuController.text.isEmpty
                                  ? ''
                                  : _skuController.text,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildInputField(
                      controller: _quantityController,
                      label: 'Quantity',
                      keyboardType: TextInputType.number,
                      icon: Icons.numbers, // Provide an appropriate icon
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        return null;
                      },
                    ),

                    _buildInputField(
                      controller: _containerNumberController,
                      label: 'Container Number',
                      iconColor: Colors.green,
                      icon: Icons.inventory,
                      keyboardType: TextInputType.text,
                    ),
                    _buildInputField(
                      controller: _bayCodeController,
                      label: 'Bay Location',
                      iconColor: Colors.green,
                      icon: Icons.inventory,
                      keyboardType: TextInputType.text,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Print Label Button
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Button color for Print Label
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _printLabel, // Call `_printLabel` method
                    child: const Text(
                      'Print Label',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16), // Spacing between the buttons
                // Save Button
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Button color for Save
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _submitForm, // Call `_submitForm` method
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Loading Indicator
          if (_loading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}