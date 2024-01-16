import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/common.dart';
import 'blocs/blocs.dart';
import 'constants.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
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
      },
      builder: buildChild,
    );
  }

  Widget buildChild(context, state) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    if (state is LoginLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.loginTitle),
      ),
      body: [
        buildEmailField(emailController, context),
        buildPasswordField(passwordController, context),
        const SizedBox(height: 20),
        [
          buildLoginButton(
                  formKey, context, emailController, passwordController)
              .expanded(),
          const SizedBox(width: 20),
          buildForgotPasswordButton(context).expanded(),
        ].toRow(),
        buildNotRegisteredButton(context),
        const SizedBox(height: 20),
        buildLoginWithGoogleButton(context),
        const SizedBox(height: 20),
        buildLoginWithAppleButton(context),
      ]
          .toColumn(
            mainAxisAlignment: MainAxisAlignment.center,
          )
          .form(formKey: formKey)
          .padding(all: 16)
          .scrollable(),
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
          final loginBloc = context.read<LoginBloc>();
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

  Widget buildLoginWithGoogleButton(BuildContext context) {
    return IconButton(
      icon: SvgPicture.asset(
        'assets/images/google/light/web_light_rd_SI.svg',
        height: 32,
      ),
      onPressed: () {
        // Get the instance of LoginBloc
        final loginBloc = context.read<LoginBloc>();
        // Add LoginWithGoogleStarted event
        loginBloc.add(LoginWithGoogleStarted());
      },
    );
  }

  Widget buildLoginWithAppleButton(BuildContext context) {
    return IconButton(
      icon: Image.asset(
        'assets/images/apple/light/web_light_cd_SI.png',
        height: 32,
      ),
      onPressed: () {
        // Get the instance of LoginBloc
        final loginBloc = context.read<LoginBloc>();
        // Add LoginWithAppleStarted event
        loginBloc.add(LoginWithAppleStarted());
      },
    );
  }
}
