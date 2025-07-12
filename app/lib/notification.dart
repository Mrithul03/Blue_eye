import 'package:flutter/material.dart';
import 'api.dart'; 

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<Customer>> customerFuture;

  @override
  void initState() {
    super.initState();
    customerFuture = ApiService().fetchCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Notifications"),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Customer>>(
        future: customerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    customerFuture = ApiService().fetchCustomers();
                  });
                },
                child: const Text(
                  "🔔 No new notifications\nTap to refresh",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            );
          }

          final customers = snapshot.data!;
          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final c = customers[index];

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${c.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Phone: ${c.mobile}'),
                      Text('Destination: ${c.destination}'),
                      Text('Members: ${c.members}'),
                      Text('Date: ${c.dateFrom} to ${c.dateUpto}'),
                      Text('Package: ${c.packageName}'),
                      Text('Suggestion: ${c.suggestion}'),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            // Dummy action for now
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Accepted booking for ${c.name}')),
                            );
                          },
                          child: const Text("Accept"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
