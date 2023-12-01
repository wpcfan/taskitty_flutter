import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'blocs/blocs.dart';
import 'constants.dart';
import 'registration_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: Builder(builder: (context) {
        return BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginFailureState) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(state.error)),
                );
            }
          },
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.loginTitle),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.loginEmail,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!
                                .loginEmailRequired;
                          }
                          // use regex to validate email
                          final regExp = RegExp(emailPattern);
                          if (!regExp.hasMatch(value)) {
                            return AppLocalizations.of(context)!
                                .loginEmailInvalid;
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.loginPassword,
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!
                                .loginPasswordRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          formKey.currentState!.save();
                          if (formKey.currentState!.validate()) {
                            // Get the instance of LoginBloc
                            final loginBloc =
                                BlocProvider.of<LoginBloc>(context);
                            // Add LoginStarted event
                            loginBloc.add(LoginStarted(
                              email: emailController.text,
                              password: passwordController.text,
                            ));
                          }
                        },
                        child: Text(AppLocalizations.of(context)!.loginSubmit),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegistrationPage()),
                          );
                        },
                        child: Text(
                            AppLocalizations.of(context)!.loginNotRegistered),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
