import 'package:flutter/material.dart';
import '../../services/lpn_service.dart'; // Import the LPN Service
import '../../models/lpn.dart';
import 'AddLpnScreen.dart'; // Import the LPN model

class LpnManagerScreen extends StatefulWidget {
  const LpnManagerScreen({Key? key}) : super(key: key);

  @override
  _LpnManagerScreenState createState() => _LpnManagerScreenState();
}

class _LpnManagerScreenState extends State<LpnManagerScreen> {
  final LpnService _lpnService = LpnService(); // Instantiate the service

  List<Lpn> allLpns = []; // State to store all fetched LPNs
  bool _loading = false; // State for showing a loading indicator
  final ScrollController _scrollController = ScrollController(); // For optional scrolling, if list is large

  @override
  void initState() {
    super.initState();
    _fetchAllLpns(); // Fetch all LPNs when the screen loads
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Clean up the ScrollController
    super.dispose();
  }

  /// Fetch all LPNs from the backend
  Future<void> _fetchAllLpns() async {
    setState(() {
      _loading = true; // Show loading indicator
    });

    try {
      final fetchedAllLpns = await _lpnService.fetchAllLpns(); // Fetch from the backend
      setState(() {
        allLpns = fetchedAllLpns; // Update the list of LPNs
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching LPNs: $e')),
      );
    } finally {
      setState(() {
        _loading = false; // Hide loading indicator
      });
    }
  }

  /// Handle refreshing the LPN list
  Future<void> _refreshLpns() async {
    await _fetchAllLpns(); // Refetch all LPNs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LPN Manager',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepOrangeAccent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white), // "+" Button
            onPressed: () {
              // Navigate to AddLpnScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddLpnScreen(allLpns: allLpns)),
              ).then((value) {
                // Optionally refresh the LPN list when returning from AddLpnScreen
                if (value == true) {
                  _fetchAllLpns();
                }
              });
            },
          ),
        ],

      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(), // Show loading spinner
      )
          : RefreshIndicator(
        onRefresh: _refreshLpns, // Pull-to-refresh to reload data
        child: ListView.builder(
          controller: _scrollController,
          itemCount: allLpns.length,
          itemBuilder: (context, index) {
            final lpn = allLpns[index];
            return ListTile(
              title: Text(
                lpn.tagID,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14
              ),
              ),
              subtitle: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style, // Use the default style
                  children: [
                    const TextSpan(
                      text: 'SKU: ', // Regular text
                    ),
                    TextSpan(
                      text: lpn.sku, // Bold SKU
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const TextSpan(
                      text: '  |  Qty: ', // Divider with label for Quantity
                    ),
                    TextSpan(
                      text: '${lpn.quantity}', // Dynamic quantity value
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const TextSpan(
                      text: '  |  Bay: ', // Divider with label for Bay
                    ),
                    TextSpan(
                      text: lpn.bayCode, // Dynamic bay value
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}