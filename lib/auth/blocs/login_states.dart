abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccessState extends LoginState {
  final String uid;

  LoginSuccessState({required this.uid});
}

class LoginFailureState extends LoginState {
  final String error;

  LoginFailureState({required this.error});
}
