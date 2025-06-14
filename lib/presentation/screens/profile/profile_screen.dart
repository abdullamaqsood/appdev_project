import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';

// User Profile Screen
// Requires: firebase_auth in pubspec.yaml
// TODO: Add profile editing and more user info in the future.

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text('No user logged in'))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? const Icon(Icons.person, size: 48)
                        : null,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    user.displayName ?? 'No Name',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email ?? 'No Email',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(user.email ?? '-'),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
