abstract class RegisterEvent {}

class RegisterStarted extends RegisterEvent {
  final String email;
  final String password;

  RegisterStarted({required this.email, required this.password});
}
