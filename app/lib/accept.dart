import 'package:flutter/material.dart';
import 'api.dart'; // import your ApiService and Customer model

class AcceptedCustomersPage extends StatefulWidget {
  const AcceptedCustomersPage({super.key});

  @override
  State<AcceptedCustomersPage> createState() => _AcceptedCustomersPageState();
}

class _AcceptedCustomersPageState extends State<AcceptedCustomersPage> {
  late Future<List<Customer>> _acceptedCustomers;

  @override
  void initState() {
    super.initState();
    _acceptedCustomers = _loadAcceptedCustomers();
  }

  Future<List<Customer>> _loadAcceptedCustomers() async {
    final api = ApiService();
    final customers = await api.fetchCustomers();

    // Filter for confirmed customers only
    return customers
        .where((c) => c.status.toLowerCase() == "confirmed")
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accepted Customers')),
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
            future: _acceptedCustomers,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('❌ Error loading data'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No accepted bookings found.'));
              }

              final acceptedList = snapshot.data!;

              return ListView.builder(
                itemCount: acceptedList.length,
                itemBuilder: (context, index) {
                  final customer = acceptedList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(customer.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📞 ${customer.mobile}'),
                          Text('📍 ${customer.destination}'),
                          Text('👥 ${customer.members} members'),
                          Text(
                            '🗓️ ${customer.dateFrom} - ${customer.dateUpto}',
                          ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
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
