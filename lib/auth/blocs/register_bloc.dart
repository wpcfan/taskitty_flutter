import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'register_events.dart';
import 'register_states.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final FirebaseAuth auth;
  final FirebaseAnalytics analytics;

  RegisterBloc({
    required this.auth,
    required this.analytics,
  }) : super(RegisterInitial()) {
    on<RegisterStarted>((event, emit) => _mapRegisterEventToState(event, emit));
  }

  void _mapRegisterEventToState(
      RegisterStarted event, Emitter<RegisterState> emit) async {
    // use Firebase Auth to register
    emit(RegisterLoading());
    try {
      final result = await auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      analytics.logSignUp(signUpMethod: 'email');
      analytics.setUserId(id: result.user!.uid);
      emit(RegisterSuccessState(uid: result.user!.uid));
    } on FirebaseAuthException catch (e) {
      emit(RegisterFailureState(error: e.message!));
    } catch (e) {
      emit(RegisterFailureState(error: e.toString()));
    }
  }
}
