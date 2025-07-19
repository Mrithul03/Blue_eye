import 'package:flutter/material.dart';
import 'api.dart'; // import your ApiService and Customer model

class PendingCustomersPage extends StatefulWidget {
  const PendingCustomersPage({super.key});

  @override
  State<PendingCustomersPage> createState() => _PendingCustomersPageState();
}

class _PendingCustomersPageState extends State<PendingCustomersPage> {
  late Future<List<Customer>> _pendingCustomers;

  @override
  void initState() {
    super.initState();
    _pendingCustomers = _loadPendingCustomers();
  }

  Future<List<Customer>> _loadPendingCustomers() async {
    final api = ApiService();
    final customers = await api.fetchCustomers();

    // Filter only pending bookings
    return customers
        .where((c) => c.status.toLowerCase() == "pending")
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Customers')),
      // backgroundColor: const Color.fromARGB(255, 5, 87, 155),
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
      FutureBuilder<List<Customer>>(
        future: _pendingCustomers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('❌ Error loading data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No pending bookings found.'));
          }

          final pendingList = snapshot.data!;

          return ListView.builder(
            itemCount: pendingList.length,
            itemBuilder: (context, index) {
              final customer = pendingList[index];
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
                  trailing: const Icon(Icons.hourglass_top, color: Colors.orange),
                ),
              );
            },
          );
        },
      ),
        ]
      )
    );
  }
}
