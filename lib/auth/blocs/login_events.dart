// Login Bloc
abstract class LoginEvent {}

class LoginStarted extends LoginEvent {
  final String email;
  final String password;

  LoginStarted({required this.email, required this.password});
}

class LoginWithGoogleStarted extends LoginEvent {}

class LoginWithAppleStarted extends LoginEvent {}

class ForgotPasswordStarted extends LoginEvent {
  final String email;

  ForgotPasswordStarted({required this.email});
}

class LoginLogoutStarted extends LoginEvent {}
