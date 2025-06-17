import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'user_management_event.dart';
import 'user_management_state.dart';

class UserManagementBloc
    extends Bloc<UserManagementEvent, UserManagementState> {
  final AuthRepository repository;

  UserManagementBloc(this.repository) : super(UserManagementInitial()) {
    on<LoadUsers>((event, emit) async {
      emit(UserManagementLoading());
      try {
        final users = await repository.fetchAllUsers();
        emit(UserManagementLoaded(users));
      } catch (e) {
        emit(UserManagementFailure(e.toString()));
      }
    });

    on<DeleteUser>((event, emit) async {
      emit(UserManagementLoading());
      try {
        await repository.deleteUserAndDetails(event.uid);
        emit(UserDeleted(event.email));
        // Reload users after deletion
        final users = await repository.fetchAllUsers();
        emit(UserManagementLoaded(users));
      } catch (e) {
        emit(UserManagementFailure(e.toString()));
      }
    });
  }
}
