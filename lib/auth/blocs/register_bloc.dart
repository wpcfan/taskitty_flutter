import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'register_events.dart';
import 'register_states.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterStarted>((event, emit) => _mapRegisterEventToState(event, emit));
  }

  void _mapRegisterEventToState(
      RegisterStarted event, Emitter<RegisterState> emit) async {
    // use Firebase Auth to register
    emit(RegisterLoading());
    try {
      final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(RegisterSuccessState(uid: result.user!.uid));
    } on FirebaseAuthException catch (e) {
      emit(RegisterFailureState(error: e.message!));
    } catch (e) {
      emit(RegisterFailureState(error: e.toString()));
    }
  }
}
