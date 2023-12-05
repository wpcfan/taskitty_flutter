import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'blocs/blocs.dart';
import 'constants.dart';

class LoginPage extends StatelessWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  const LoginPage({
    super.key,
    required this.analytics,
    required this.observer,
  });

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: Builder(builder: (context) {
        return BlocConsumer<LoginBloc, LoginState>(
          listener: listenStateChange,
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
                      buildEmailField(emailController, context),
                      buildPasswordField(passwordController, context),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: buildLoginButton(formKey, context,
                                emailController, passwordController),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: buildForgotPasswordButton(context),
                          ),
                        ],
                      ),
                      buildNotRegisteredButton(context),
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

  TextButton buildForgotPasswordButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/forgot_password');
      },
      child: Text(AppLocalizations.of(context)!.loginForgotPassword),
    );
  }

  TextButton buildNotRegisteredButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/register');
      },
      child: Text(AppLocalizations.of(context)!.loginNotRegistered),
    );
  }

  ElevatedButton buildLoginButton(
      GlobalKey<FormState> formKey,
      BuildContext context,
      TextEditingController emailController,
      TextEditingController passwordController) {
    return ElevatedButton(
      onPressed: () {
        formKey.currentState!.save();
        if (formKey.currentState!.validate()) {
          // Get the instance of LoginBloc
          final loginBloc = BlocProvider.of<LoginBloc>(context);
          // Add LoginStarted event
          loginBloc.add(LoginStarted(
            email: emailController.text,
            password: passwordController.text,
          ));
        }
      },
      child: Text(AppLocalizations.of(context)!.loginSubmit),
    );
  }

  TextFormField buildPasswordField(
      TextEditingController passwordController, BuildContext context) {
    return TextFormField(
      controller: passwordController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.loginPassword,
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.loginPasswordRequired;
        }
        return null;
      },
    );
  }

  TextFormField buildEmailField(
      TextEditingController emailController, BuildContext context) {
    return TextFormField(
      controller: emailController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.loginEmail,
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.loginEmailRequired;
        }
        // use regex to validate email
        final regExp = RegExp(emailPattern);
        if (!regExp.hasMatch(value)) {
          return AppLocalizations.of(context)!.loginEmailInvalid;
        }
        return null;
      },
    );
  }

  void listenStateChange(context, state) {
    if (state is LoginFailureState) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(state.error)),
        );
    }
    if (state is LoginSuccessState) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}
