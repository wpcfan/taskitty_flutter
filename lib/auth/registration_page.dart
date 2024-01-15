import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/common.dart';
import '../blocs/blocs.dart';
import 'blocs/blocs.dart';
import 'constants.dart';

class RegistrationPage extends StatelessWidget {
  final FirebaseAuth auth;
  const RegistrationPage({
    super.key,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RegisterBloc>(
          create: (context) => RegisterBloc(auth: auth),
        ),
        BlocProvider<AnalyticsBloc>(
          create: (context) => AnalyticsBloc(
            analytics: context.read<FirebaseAnalytics>(),
          ),
        ),
      ],
      child: Builder(builder: (context) {
        final analyticsBloc = context.read<AnalyticsBloc>();
        analyticsBloc.add(AnalyticsEventPageView(
          screenName: 'RegistrationPage',
          screenClassOverride: 'RegistrationPage',
        ));
        return BlocConsumer<RegisterBloc, RegisterState>(
          listener: listenStateChange,
          builder: buildChild,
        );
      }),
    );
  }

  Widget buildChild(context, state) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.registerTitle),
      ),
      body: [
        buildEmailField(emailController, context),
        buildPasswordField(passwordController, context),
        buildConfirmPasswordField(
            confirmPasswordController, context, passwordController),
        const SizedBox(height: 20),
        buildRegisterButton(
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
    if (state is RegisterFailureState) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(state.error)),
        );
    }
    if (state is RegisterSuccessState) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  ElevatedButton buildRegisterButton(
      GlobalKey<FormState> formKey,
      BuildContext context,
      TextEditingController emailController,
      TextEditingController passwordController) {
    return ElevatedButton(
      onPressed: () {
        formKey.currentState!.save();
        if (formKey.currentState!.validate()) {
          // Get the instance of RegisterBloc
          final registerBloc = context.read<RegisterBloc>();
          // Add RegisterStarted event
          registerBloc.add(RegisterStarted(
            email: emailController.text,
            password: passwordController.text,
          ));
        }
      },
      child: Text(AppLocalizations.of(context)!.registerSubmit),
    );
  }

  TextFormField buildConfirmPasswordField(
      TextEditingController confirmPasswordController,
      BuildContext context,
      TextEditingController passwordController) {
    return TextFormField(
      controller: confirmPasswordController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.registerPasswordConfirm,
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.registerPasswordConfirmRequired;
        }
        if (value != passwordController.text) {
          return AppLocalizations.of(context)!.registerPasswordConfirmNotMatch;
        }
        return null;
      },
    );
  }

  TextFormField buildPasswordField(
      TextEditingController passwordController, BuildContext context) {
    return TextFormField(
      controller: passwordController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.registerPassword,
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.registerPasswordRequired;
        }
        if (value.length < 6) {
          return AppLocalizations.of(context)!.registerPasswordTooShort;
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
        labelText: AppLocalizations.of(context)!.registerEmail,
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.registerEmailRequired;
        }
        // use regex to validate email
        final regExp = RegExp(emailPattern);
        if (!regExp.hasMatch(value)) {
          return AppLocalizations.of(context)!.registerEmailInvalid;
        }
        return null;
      },
    );
  }
}
