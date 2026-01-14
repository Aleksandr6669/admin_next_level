import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:nextlevel/home_page.dart';
import 'package:nextlevel/auth_page.dart';
import 'package:nextlevel/verify_email_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key, required this.changeLanguage});

  final void Function(Locale locale) changeLanguage;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<auth.User?>(
      stream: auth.FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final auth.User? user = snapshot.data;
          if (user == null) {
            return AuthPage(changeLanguage: changeLanguage);
          } else if (user.emailVerified) {
            return HomePage(changeLanguage: changeLanguage);
          } else {
            return const VerifyEmailPage();
          }
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
