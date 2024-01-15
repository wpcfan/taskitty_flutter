import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'login_events.dart';
import 'login_states.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth auth;

  LoginBloc({required this.auth}) : super(LoginInitial()) {
    on<LoginStarted>((event, emit) => _mapLoginEventToState(event, emit));
    on<LoginWithGoogleStarted>(
        (event, emit) => _mapLoginWithGoogleEventToState(event, emit));
    on<LoginWithAppleStarted>(
        (event, emit) => _mapLoginWithAppleEventToState(event, emit));
    on<ForgotPasswordStarted>(
        (event, emit) => _mapForgotPasswordEventToState(event, emit));
    on<LoginLogoutStarted>((event, emit) async {
      await auth.signOut();
      emit(LoginInitial());
    });
  }

  void _mapLoginEventToState(
      LoginStarted event, Emitter<LoginState> emit) async {
    // use Firebase Auth to login
    emit(LoginLoading());
    try {
      final result = await auth.signInWithEmailAndPassword(
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

  void _mapLoginWithGoogleEventToState(
      LoginWithGoogleStarted event, Emitter<LoginState> emit) async {
    // use Firebase Auth to login
    emit(LoginLoading());
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final result = await auth.signInWithCredential(credential);
      emit(LoginSuccessState(uid: result.user!.uid));
    } on FirebaseAuthException catch (e) {
      emit(LoginFailureState(error: e.message!));
    } catch (e) {
      emit(LoginFailureState(error: e.toString()));
    }
  }

  void _mapLoginWithAppleEventToState(
      LoginWithAppleStarted event, Emitter<LoginState> emit) async {
    // use Firebase Auth to login
    emit(LoginLoading());
    try {
      final appleProvider = AppleAuthProvider();
      if (kIsWeb) {
        final result = await auth.signInWithPopup(appleProvider);
        emit(LoginSuccessState(uid: result.user!.uid));
      } else {
        final result = await auth.signInWithProvider(appleProvider);
        emit(LoginSuccessState(uid: result.user!.uid));
      }
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
