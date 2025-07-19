import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart'; // For LoginPage
import 'api.dart'; // For UserModel
import 'accept.dart';
import 'reject.dart';
import 'pending.dart';

class MenuTab extends StatelessWidget {
  final UserModel? user;

  const MenuTab({super.key, required this.user});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('device_token');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text("⚠️ Unable to load user"));
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('images/logo.jpg'),
            ),
            const SizedBox(height: 20),
            Text(
              user!.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              user!.phone,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(
              "Role: ${user!.userType}",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),

            // 👇 Show only if user is 'owner'
            if (user!.userType.toLowerCase() == "owner") ...[
              const Divider(height: 40),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text("Accepted"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AcceptedCustomersPage(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text("Declined"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RejectedCustomersPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.hourglass_top, color: Colors.orange),
                title: const Text("Pending"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PendingCustomersPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.group_add, color: Colors.blue),
                title: const Text("Add Users"),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Add Users tapped")),
                  );
                },
              ),
            ],

            // 🔒 Always show logout
            const Divider(height: 30),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
