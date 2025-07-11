import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getStartScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('device_token');
    if (token != null && token.isNotEmpty) {
      return const HomePage(); // or pass token if needed
    } else {
      return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blue Eye Login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: _getStartScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData) {
            return snapshot.data!;
          } else {
            return const Scaffold(
              body: Center(child: Text("Error loading app")),
            );
          }
        },
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _userType = 'Driver';
  String _errorMessage = '';
  bool _loading = false;

  Future<void> _handleLogin() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    try {
      final token = await login(
        name: name,
        phone: phone,
        password: password,
        userType: _userType, // uses the correct class-level value
      );

      if (token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('device_token', token);

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid phone or password.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login to Blue Eye'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _userType,
              items: const [
                DropdownMenuItem(value: 'Driver', child: Text('Driver')),
                DropdownMenuItem(value: 'Owner', child: Text('Owner')),
              ],
              onChanged: (value) {
                setState(() {
                  _userType = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'User Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            if (_loading) const CircularProgressIndicator(),
            if (!_loading)
              ElevatedButton(
                onPressed: _handleLogin,
                child: const Text('Login'),
              ),
            const SizedBox(height: 10),
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
