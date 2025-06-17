abstract class UserManagementState {}

class UserManagementInitial extends UserManagementState {}

class UserManagementLoading extends UserManagementState {}

class UserManagementLoaded extends UserManagementState {
  final List<Map<String, dynamic>> users;
  UserManagementLoaded(this.users);
}

class UserManagementFailure extends UserManagementState {
  final String message;
  UserManagementFailure(this.message);
}

class UserDeleted extends UserManagementState {
  final String email;
  UserDeleted(this.email);
}
