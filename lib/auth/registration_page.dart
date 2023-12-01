import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'blocs/blocs.dart';
import 'constants.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return BlocProvider(
      create: (context) => RegisterBloc(),
      child: Builder(builder: (context) {
        return BlocConsumer<RegisterBloc, RegisterState>(
          listener: (context, state) {
            if (state is RegisterFailureState) {
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
                title: Text(AppLocalizations.of(context)!.registerTitle),
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
                          labelText:
                              AppLocalizations.of(context)!.registerEmail,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!
                                .registerEmailRequired;
                          }
                          // use regex to validate email
                          final regExp = RegExp(emailPattern);
                          if (!regExp.hasMatch(value)) {
                            return AppLocalizations.of(context)!
                                .registerEmailInvalid;
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.registerPassword,
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!
                                .registerPasswordRequired;
                          }
                          if (value.length < 6) {
                            return AppLocalizations.of(context)!
                                .registerPasswordTooShort;
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!
                              .registerPasswordConfirm,
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!
                                .registerPasswordConfirmRequired;
                          }
                          if (value != passwordController.text) {
                            return AppLocalizations.of(context)!
                                .registerPasswordConfirmNotMatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          formKey.currentState!.save();
                          if (formKey.currentState!.validate()) {
                            // Get the instance of RegisterBloc
                            final registerBloc =
                                BlocProvider.of<RegisterBloc>(context);
                            // Add RegisterStarted event
                            registerBloc.add(RegisterStarted(
                              email: emailController.text,
                              password: passwordController.text,
                            ));
                          }
                        },
                        child:
                            Text(AppLocalizations.of(context)!.registerSubmit),
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
