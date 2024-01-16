import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/common.dart';
import 'blocs/blocs.dart';
import 'constants.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: listenStateChange,
      builder: buildChild,
    );
  }

  Widget buildChild(context, state) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.forgotPasswordTitle),
      ),
      body: [
        buildEmailField(emailController, context),
        const SizedBox(height: 20),
        buildResetPasswordHint(context),
        const SizedBox(height: 20),
        buildResetPasswordButton(
            formKey, context, emailController, passwordController),
      ]
          .toColumn(
            mainAxisAlignment: MainAxisAlignment.center,
          )
          .form(formKey: formKey)
          .padding(all: 16)
          .scrollable(),
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
