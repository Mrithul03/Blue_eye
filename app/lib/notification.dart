import 'package:flutter/material.dart';
import 'api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Customer> _bookings = [];
  UserModel? _user;
  bool _loading = true;

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
          _bookings = bookings;
          _user = user;
          _loading = false;
        });
      }

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

  Future<void> _submitStatus(
    int customerId,
    String status,
    String driverName,
  ) async {
    try {
      final api = ApiService();
      await api.updateCustomerStatus(customerId, status, driverName);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Status updated: $status')));
      _loadInitialData();
    } catch (e) {
      print("❌ Failed to update status: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update status')));
    }
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
    return Stack(
      children: [
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
        Scaffold(
          backgroundColor:
              Colors.transparent, // ✅ Transparent to show the image
          appBar: AppBar(
            title: const Text("Booking Notifications"),
            backgroundColor: const Color.fromARGB(
              255,
              170,
              165,
              165,
            ).withOpacity(0.15), // Optional overlay
            elevation: 0,
          ),
          body:
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _bookings.isEmpty
                  ? const Center(
                    child: Text(
                      "No new bookings",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  )
                  : ListView.builder(
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final c = _bookings[index];
                      final isOwner = _user?.userType.toLowerCase() == "owner";

                      return Card(
                        margin: const EdgeInsets.all(10),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name: ${c.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Phone: ${c.mobile}'),
                              Text('Destination: ${c.destination}'),
                              Text('Members: ${c.members}'),
                              Text('Date: ${c.dateFrom} to ${c.dateUpto}'),
                              Text('Package: ${c.packageName}'),
                              Text('Suggestion: ${c.suggestion}'),
                              const SizedBox(height: 12),
                              if (isOwner)
                                ElevatedButton.icon(
                                  onPressed: () => _launchDialer(c.mobile),
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

                              Align(
                                alignment: Alignment.centerRight,
                                child: Builder(
                                  builder: (context) {
                                    if (c.status.toLowerCase() == 'confirmed') {
                                      return ElevatedButton(
                                        onPressed: null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                        child: const Text("Accepted"),
                                      );
                                    } else {
                                      final isDeclined =
                                          c.status.toLowerCase() == 'declined';
                                      final buttonLabel =
                                          isDeclined ? 'Declined' : 'Accept';
                                      final buttonColor =
                                          isDeclined ? Colors.red : Colors.blue;

                                      return ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              String driverName = '';
                                              String status =
                                                  isDeclined
                                                      ? 'Declined'
                                                      : 'Confirmed';

                                              return StatefulBuilder(
                                                builder: (context, setState) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                      'Assign Driver & Set Status',
                                                    ),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        TextField(
                                                          decoration:
                                                              const InputDecoration(
                                                                labelText:
                                                                    'Driver Name',
                                                              ),
                                                          onChanged:
                                                              (value) =>
                                                                  driverName =
                                                                      value,
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        DropdownButtonFormField<
                                                          String
                                                        >(
                                                          value: status,
                                                          decoration:
                                                              const InputDecoration(
                                                                labelText:
                                                                    'Status',
                                                              ),
                                                          items:
                                                              [
                                                                    'Confirmed',
                                                                    'Declined',
                                                                  ]
                                                                  .map(
                                                                    (
                                                                      s,
                                                                    ) => DropdownMenuItem(
                                                                      value: s,
                                                                      child:
                                                                          Text(
                                                                            s,
                                                                          ),
                                                                    ),
                                                                  )
                                                                  .toList(),
                                                          onChanged: (value) {
                                                            if (value != null) {
                                                              setState(
                                                                () =>
                                                                    status =
                                                                        value,
                                                              );
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () =>
                                                                Navigator.of(
                                                                  context,
                                                                ).pop(),
                                                        child: const Text(
                                                          'Cancel',
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                          _submitStatus(
                                                            c.id,
                                                            status,
                                                            driverName,
                                                          );
                                                        },
                                                        child: const Text(
                                                          'Submit',
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: buttonColor,
                                        ),
                                        child: Text(buttonLabel),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
