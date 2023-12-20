import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'blocs/blocs.dart';
import 'constants.dart';

class ForgotPasswordPage extends StatelessWidget {
  final FirebaseAuth auth;
  const ForgotPasswordPage({
    super.key,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return BlocProvider(
      create: (context) => LoginBloc(auth: auth),
      child: Builder(builder: (context) {
        return BlocConsumer<LoginBloc, LoginState>(
          listener: listenStateChange,
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.forgotPasswordTitle),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        buildEmailField(emailController, context),
                        const SizedBox(height: 20),
                        buildResetPasswordHint(context),
                        const SizedBox(height: 20),
                        buildResetPasswordButton(formKey, context,
                            emailController, passwordController),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void listenStateChange(context, state) {
    if (state is ForgotPasswordFailureState) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(state.error)),
        );
    }
    if (state is ForgotPasswordSuccessState) {
      Navigator.of(context).pop();
    }
  }

  Widget buildEmailField(
      TextEditingController emailController, BuildContext context) {
    return TextFormField(
      controller: emailController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.forgotPasswordEmail,
        hintText: AppLocalizations.of(context)!.forgotPasswordEmailHint,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.forgotPasswordEmailRequired;
        }
        final regExp = RegExp(emailPattern);
        if (!regExp.hasMatch(value)) {
          return AppLocalizations.of(context)!.forgotPasswordEmailInvalid;
        }
        return null;
      },
    );
  }

  ElevatedButton buildResetPasswordButton(
      GlobalKey<FormState> formKey,
      BuildContext context,
      TextEditingController emailController,
      TextEditingController passwordController) {
    return ElevatedButton(
      onPressed: () {
        if (formKey.currentState!.validate()) {
          context.read<LoginBloc>().add(ForgotPasswordStarted(
                email: emailController.text,
              ));
        }
      },
      child: Text(AppLocalizations.of(context)!.forgotPasswordSubmit),
    );
  }

  Text buildResetPasswordHint(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.forgotPasswordHint,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
