import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_events.dart';
import 'login_states.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginStarted>((event, emit) => _mapLoginEventToState(event, emit));
    on<ForgotPasswordStarted>(
        (event, emit) => _mapForgotPasswordEventToState(event, emit));
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

  void _mapForgotPasswordEventToState(
      ForgotPasswordStarted event, Emitter<LoginState> emit) async {
    // use Firebase Auth to send password reset email
    emit(LoginLoading());
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: event.email);
      emit(ForgotPasswordSuccessState());
    } on FirebaseAuthException catch (e) {
      emit(ForgotPasswordFailureState(error: e.message!));
    } catch (e) {
      emit(ForgotPasswordFailureState(error: e.toString()));
    }
  }
}
