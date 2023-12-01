import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_events.dart';
import 'login_states.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginStarted>((event, emit) => _mapLoginEventToState(event, emit));
  }

  void _mapLoginEventToState(
      LoginStarted event, Emitter<LoginState> emit) async {
    // use Firebase Auth to login
    emit(LoginLoading());
    try {
      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(LoginSuccessState(uid: result.user!.uid));
    } on FirebaseAuthException catch (e) {
      emit(LoginFailureState(error: e.message!));
    } catch (e) {
      emit(LoginFailureState(error: e.toString()));
    }
  }
}
