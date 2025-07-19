import 'package:flutter/material.dart';
import 'api.dart'; // import your ApiService and Customer model

class RejectedCustomersPage extends StatefulWidget {
  const RejectedCustomersPage({super.key});

  @override
  State<RejectedCustomersPage> createState() => _RejectedCustomersPageState();
}

class _RejectedCustomersPageState extends State<RejectedCustomersPage> {
  late Future<List<Customer>> _rejectedCustomers;

  @override
  void initState() {
    super.initState();
    _rejectedCustomers = _loadRejectedCustomers();
  }

  Future<List<Customer>> _loadRejectedCustomers() async {
    final api = ApiService();
    final customers = await api.fetchCustomers();

    // Filter only rejected or declined bookings
    return customers
        .where((c) => c.status.toLowerCase() == "rejected" || c.status.toLowerCase() == "declined")
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejected Customers'),
        backgroundColor: const Color.fromARGB(255, 2, 118, 172),
      ),
      body: Stack(
        children: [
          // Background logo image
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'images/logo.jpg',
                height: 30,
                width: 30,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Main content
          FutureBuilder<List<Customer>>(
            future: _rejectedCustomers,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('❌ Error loading data'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No rejected bookings found.'));
              }

              final rejectedList = snapshot.data!;

              return ListView.builder(
                itemCount: rejectedList.length,
                itemBuilder: (context, index) {
                  final customer = rejectedList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(customer.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📞 ${customer.mobile}'),
                          Text('📍 ${customer.destination}'),
                          Text('👥 ${customer.members} members'),
                          Text('🗓️ ${customer.dateFrom} - ${customer.dateUpto}'),
                        ],
                      ),
                      trailing: const Icon(Icons.cancel, color: Colors.red),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
