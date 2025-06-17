abstract class UserManagementEvent {}

class LoadUsers extends UserManagementEvent {}

class DeleteUser extends UserManagementEvent {
  final String uid;
  final String email;
  DeleteUser(this.uid, this.email);
}
