import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Events
abstract class RoleEvent {}

class CheckRole extends RoleEvent {}

// States
abstract class RoleState {}

class RoleLoading extends RoleState {}

class RoleAdmin extends RoleState {}

class RoleNormal extends RoleState {}

class RoleError extends RoleState {
  final String message;
  RoleError(this.message);
}

class RoleBloc extends Bloc<RoleEvent, RoleState> {
  final AuthRepository authRepository;
  RoleBloc(this.authRepository) : super(RoleLoading()) {
    on<CheckRole>((event, emit) async {
      emit(RoleLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          final role = doc.data()?['role'] ?? 'normal';
          if (role == 'admin') {
            emit(RoleAdmin());
          } else {
            emit(RoleNormal());
          }
        } else {
          emit(RoleNormal());
        }
      } catch (e) {
        emit(RoleError(e.toString()));
      }
    });
  }
}
