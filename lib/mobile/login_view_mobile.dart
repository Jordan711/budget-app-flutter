import 'package:budget_app_starting/components.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginViewMobile extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double deviceHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
              child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: deviceHeight / 5.5),
          Image.asset("assets/logo.png", fit: BoxFit.contain, width: 210.0),
          SizedBox(height: 30.0),
          // Email
          EmailAndPasswordFields(),

          SizedBox(height: 30.0),
          // Using a row widget spreads til the end of the screen
          // Since it is inside column, the entire width of the column
          // also expands as it takes the size of the row, changing the
          // center of the column
          RegisterAndLogin(),
          SizedBox(height: 30.0),
          GoogleSignInButton(),
        ],
      ))),
    );
  }
}
