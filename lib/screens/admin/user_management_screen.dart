import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late Future<List<Map<String, dynamic>>> _usersFuture;
  final AuthRepository _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    _usersFuture = _authRepository.fetchAllUsers();
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _usersFuture = _authRepository.fetchAllUsers();
    });
  }

  void _deleteUser(String uid, String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
            'Are you sure you want to delete user "$email" and all their data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _authRepository.deleteUserAndDetails(uid);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User "$email" deleted.')),
      );
      _refreshUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          }
          final users =
              snapshot.data!.where((user) => user['role'] != 'admin').toList();
          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }
          return RefreshIndicator(
            onRefresh: _refreshUsers,
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user['email'] ?? 'No Email'),
                  subtitle: Text('Role: \\${user['role'] ?? 'unknown'}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        _deleteUser(user['uid'], user['email'] ?? ''),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
