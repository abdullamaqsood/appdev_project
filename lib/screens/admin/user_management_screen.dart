import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../blocs/user_management/user_management_bloc.dart';
import '../../blocs/user_management/user_management_event.dart';
import '../../blocs/user_management/user_management_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  void _deleteUser(BuildContext context, String uid, String email) async {
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
      context.read<UserManagementBloc>().add(DeleteUser(uid, email));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserManagementBloc(AuthRepository())..add(LoadUsers()),
      child: Scaffold(
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
        body: BlocConsumer<UserManagementBloc, UserManagementState>(
          listener: (context, state) {
            if (state is UserDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User "${state.email}" deleted.')),
              );
            } else if (state is UserManagementFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            }
          },
          builder: (context, state) {
            if (state is UserManagementLoading ||
                state is UserManagementInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserManagementFailure) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is UserManagementLoaded) {
              final users =
                  state.users.where((user) => user['role'] != 'admin').toList();
              if (users.isEmpty) {
                return const Center(child: Text('No users found.'));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<UserManagementBloc>().add(LoadUsers());
                },
                child: ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(user['email'] ?? 'No Email'),
                      subtitle: Text('Role: ${user['role'] ?? 'unknown'}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(
                            context, user['uid'], user['email'] ?? ''),
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
