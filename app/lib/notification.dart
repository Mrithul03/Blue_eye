import 'package:flutter/material.dart';
import 'api.dart';

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
      final api = ApiService();
      final bookings = await api.fetchCustomers();
      final user = await api.fetchUser();

      if (mounted) {
        setState(() {
          _bookings = bookings;
          _user = user;
          _loading = false;
        });
      }

      print("✅ User loaded: ${user?.name} (${user?.userType})");
    } catch (e) {
      print("🔥 Error loading data: $e");
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Notifications"),
        backgroundColor: Colors.blue,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _bookings.isEmpty
              ? const Center(
                child: Text(
                  "No new bookings",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Phone: ${c.mobile}'),
                          Text('Destination: ${c.destination}'),
                          Text('Members: ${c.members}'),
                          Text('Date: ${c.dateFrom} to ${c.dateUpto}'),
                          Text('Package: ${c.packageName}'),
                          Text('Suggestion: ${c.suggestion}'),
                          const SizedBox(height: 12),
                          if (isOwner)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Builder(
                                builder: (context) {
                                  if (c.status.toLowerCase() == 'confirmed') {
                                    // Show green "Accepted" button (disabled)
                                    return ElevatedButton(
                                      onPressed: null, // disabled
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      child: const Text("Accepted"),
                                    );
                                  } else {
                                    // Show action button based on current status
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
                                                                    child: Text(
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
    );
  }
}
