import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:budget_app_starting/components.dart';

class LoginViewWeb extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double deviceWidth = MediaQuery.of(context).size.width;

    final double deviceHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
          body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(top: 150.0),
            child:
                Image.asset("assets/login_image.png", width: deviceWidth / 2.6),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: deviceHeight / 5.5),
                Image.asset("assets/logo.png",
                    fit: BoxFit.contain, width: 250.0),

                SizedBox(height: 40.0),
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
            ),
          )
        ],
      )),
    );
  }
}
