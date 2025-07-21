import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'main.dart';
import 'notification.dart';
import 'menu.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Customer> _bookings = [];
  int _refreshKey = 0;
  UserModel? _user;
  bool _loading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localToken = prefs.getString('device_token');
      print('localtoken:$localToken');

      if (localToken == null || localToken.isEmpty) {
        print('❌ No local token found.');
        _logout(context);
        return;
      }

      final api = ApiService();
      final user = await api.fetchUser();
      print('user: $user');

      if (user == null) {
        print('❌ User fetch failed — invalid token');
        _logout(context);
        return;
      }

      if (user.deviceToken == null ||
          user.deviceToken.isEmpty ||
          user.deviceToken != localToken) {
        print(
          '❌ Token mismatch or missing: local=$localToken, user=${user.deviceToken}',
        );
        _logout(context);
        return;
      }

      final bookings = await api.fetchCustomers();

      if (mounted) {
        setState(() {
          _refreshKey++;
          _bookings = bookings;
          _user = user;
          _loading = false;
        });
      }
      print("🔁 Home tab rebuilt with refreshKey=$_refreshKey");

      print("✅ User loaded: ${user.name} (${user.userType})");
    } catch (e) {
      print("🔥 Exception during init: $e");
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('device_token');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _launchDialer(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      KeyedSubtree(
        key: ValueKey(_refreshKey), // 🔁 forces rebuild on refresh
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _bookings.isEmpty
                ? const Center(child: Text('No bookings available'))
                : Padding(
                  padding: const EdgeInsets.all(12),
                  child: ListView.builder(
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text('📞 ${booking.mobile}', style: _infoStyle),
                                Text(
                                  '📍 ${booking.destination}',
                                  style: _infoStyle,
                                ),
                                Text(
                                  '👥 ${booking.members} Members',
                                  style: _infoStyle,
                                ),
                                Text(
                                  '🗓️ From: ${booking.dateFrom}',
                                  style: _infoStyle,
                                ),
                                Text(
                                  '🗓️ To: ${booking.dateUpto}',
                                  style: _infoStyle,
                                ),
                                Text(
                                  '🎁 Package: ${booking.packageName ?? "Not Assigned"}',
                                  style: _infoStyle,
                                ),
                                Text(
                                  '💬 Suggestion: ${booking.suggestion ?? "None"}',
                                  style: _infoStyle,
                                ),
                                Text(
                                  '🧑 Driver: ${booking.driver ?? "Not Assigned"}',
                                  style: _infoStyle,
                                ),

                                const SizedBox(height: 8),
                                if (_user != null &&
                                    _user!.userType.toLowerCase() ==
                                        "owner") ...[
                                  // ✅ Call button placed here
                                  ElevatedButton.icon(
                                    onPressed:
                                        () => _launchDialer(booking.mobile),
                                    icon: const Icon(Icons.call, size: 16),
                                    label: const Text(
                                      'Call',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 6),
                                ],

                                // ✅ Status at the bottom
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          booking.status.toLowerCase() ==
                                                  'approved'
                                              ? Colors.green[100]
                                              : Colors.orange[100],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      booking.status,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color:
                                            booking.status.toLowerCase() ==
                                                    'approved'
                                                ? Colors.green[800]
                                                : Colors.orange[800],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ),

      // ✅ Replaced with direct NotificationPage
      const NotificationPage(),

      // Messages tab (optional)
      // const Center(child: Text("💬 Messages will appear here")),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 2, 118, 172),
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'images/logo.jpg',
                height: 30,
                width: 30,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Blue Eyes Holidays'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),

      drawer: Drawer(
        child: MenuTab(user: _user), // ✅ Slide-out menu
      ),
      body: Stack(
        children: [
          // 🔵 Background color layer
          // 🖼️ Background image layer
          Positioned.fill(
            child: Opacity(
              opacity: 0.15, // Soft logo background
              child: Image.asset(
                'images/logo.jpg',
                height: 30,
                width: 30,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 📦 Foreground content
          pages[_currentIndex],
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            if (index == 0) {
              // Always reload when switching *to* Home
              _loadInitialData();
            }
            _currentIndex = index;
          });
        },
        indicatorColor: const Color.fromARGB(255, 52, 156, 241),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          // NavigationDestination(
          //   icon: Icon(Icons.chat_bubble_outline),
          //   selectedIcon: Icon(Icons.chat_bubble),
          //   label: 'Messages',
          // ),
        ],
      ),
    );
  }

  TextStyle get _infoStyle =>
      const TextStyle(fontSize: 19, overflow: TextOverflow.ellipsis);
}
