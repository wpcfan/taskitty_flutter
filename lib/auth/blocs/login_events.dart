// Login Bloc
abstract class LoginEvent {}

class LoginStarted extends LoginEvent {
  final String email;
  final String password;

  LoginStarted({required this.email, required this.password});
}
