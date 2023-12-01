abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccessState extends RegisterState {
  final String uid;

  RegisterSuccessState({required this.uid});
}

class RegisterFailureState extends RegisterState {
  final String error;

  RegisterFailureState({required this.error});
}
