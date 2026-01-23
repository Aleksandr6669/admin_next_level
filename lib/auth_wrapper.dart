import 'package:cloud_firestore/cloud_firestore.dart';
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
      stream: auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final auth.User? user = authSnapshot.data;
        
        if (user == null) {
          // Пользователь не авторизован
          return AuthPage(changeLanguage: changeLanguage);
        }

        // Пользователь авторизован, обновляем время последнего входа в коллекции 'users'
        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'lastLoginDate': Timestamp.now()
        }, SetOptions(merge: true));

        // Проверяем подтверждение почты
        if (user.emailVerified) {
          return HomePage(changeLanguage: changeLanguage);
        } else {
          return const VerifyEmailPage();
        }
      },
    );
  }
}
