import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';
import 'lpn_manager/lpn_manager_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
        iconTheme: const IconThemeData(
          color: Colors.white),
        ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepOrangeAccent,
              ),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.inventory),
              title: Text('Inbound Receiving'),
              onTap: () {
                // Navigate to Inventory Screen
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DummyScreen(title: 'Inbound Receiving')));
              },
            ),
            ListTile(
              leading: Icon(Icons.ballot), // Icon for LPN Manager
              title: Text('LPN Manager'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LpnManagerScreen()), // Navigate to LPN Manager
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Putaway'),
              onTap: () {
                // Navigate to Orders Screen
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DummyScreen(title: 'Putaway')));
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Users'),
              onTap: () {
                // Navigate to Users Screen
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DummyScreen(title: 'Users Screen')));
              },
            ),
            Divider(),
            // Logout Option
            FutureBuilder<String?>(
              future: AuthService.getToken(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink(); // Show nothing while loading
                } else if (snapshot.hasData && snapshot.data != null) {
                  // If token exists, show "Log out" option
                  return ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Log Out'),
                    onTap: () async {
                      final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                      prefs.remove('token'); // Remove token for logout

                      // Navigate back to LoginScreen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                  );
                } else {
                  // Else show nothing
                  return const SizedBox.shrink();
                }
              },
            ),

          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Summary Cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildSummaryCard(
                      title: 'Inventory', count: '150', icon: Icons.inventory),
                  _buildSummaryCard(
                      title: 'Orders', count: '75', icon: Icons.shopping_cart),
                  _buildSummaryCard(
                      title: 'Users', count: '10', icon: Icons.people),
                  _buildSummaryCard(
                      title: 'Revenue',
                      count: '\$12,000',
                      icon: Icons.attach_money),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for Summary Cards
  Widget _buildSummaryCard(
      {required String title, required String count, required IconData icon}) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40.0,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              count,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Temporary Dummy Screen for Navigation
class DummyScreen extends StatelessWidget {
  final String title;

  const DummyScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title,
          style: const TextStyle(
            color: Colors.white,
        )),
        backgroundColor: Colors.deepOrangeAccent,
        iconTheme: const IconThemeData(
            color: Colors.white),
      ),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}