import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'main.dart';
import 'notification.dart';
import 'menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Customer> _bookings = [];
  UserModel? _user;
  bool _loading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final api = ApiService();
    final bookings = await api.fetchCustomers();
    final user = await api.fetchUser();

    setState(() {
      _bookings = bookings;
      _user = user;
      _loading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    final pages = [
      _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
          ? const Center(child: Text('No bookings available'))
          : Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              itemCount: _bookings.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final booking = _bookings[index];
                return Card(
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
                        Text('📍 ${booking.destination}', style: _infoStyle),
                        Text(
                          '👥 ${booking.members} Members',
                          style: _infoStyle,
                        ),
                        Text('🗓️ ${booking.dateFrom}', style: _infoStyle),
                        Text('🗓️ ${booking.dateUpto}', style: _infoStyle),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                booking.status.toLowerCase() == 'approved'
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
                                  booking.status.toLowerCase() == 'approved'
                                      ? Colors.green[800]
                                      : Colors.orange[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      // ✅ Replaced with direct NotificationPage
      const NotificationPage(),

      // Messages tab (optional)
      const Center(child: Text("💬 Messages will appear here")),
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
            _currentIndex = index;
          });
        },
        // backgroundColor: const Color.fromARGB(255, 5, 87, 155),
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
