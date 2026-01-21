import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:nextlevel/home_page.dart';
import 'package:nextlevel/auth_page.dart';
import 'package:nextlevel/verify_email_page.dart';
import 'l10n/app_localizations.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key, required this.changeLanguage});

  final void Function(Locale locale) changeLanguage;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<auth.User?>(
      // Этот стрим слушает события входа/выхода из системы
      stream: auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Показываем индикатор загрузки при подключении к Firebase Auth
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final auth.User? user = authSnapshot.data;
        // Если пользователь не вошел в систему, показываем страницу входа.
        if (user == null) {
          return AuthPage(changeLanguage: changeLanguage);
        }

        // --- КЛЮЧЕВАЯ ЧАСТЬ ---
        // Пользователь вошел. Теперь мы используем StreamBuilder, чтобы слушать
        // его документ в коллекции 'admins' В РЕАЛЬНОМ ВРЕМЕНИ.
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('admins').doc(user.uid).snapshots(),
          builder: (context, adminDocSnapshot) {
            // Показываем индикатор загрузки при первой проверке статуса администратора
            if (adminDocSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            // Если документ в 'admins' существует, у пользователя есть права.
            if (adminDocSnapshot.hasData && adminDocSnapshot.data!.exists) {
              
              // Обновляем дату последнего входа в коллекции 'users'.
              FirebaseFirestore.instance.collection('users').doc(user.uid).set({'lastLoginDate': Timestamp.now()}, SetOptions(merge: true));


              // Проверяем, подтверждена ли почта, и показываем соответствующую страницу.
              if (user.emailVerified) {
                return HomePage(changeLanguage: changeLanguage);
              } else {
                return const VerifyEmailPage();
              }

            } else {
              // --- ВЫХОД В РЕАЛЬНОМ ВРЕМЕНИ ---
              // Этот блок выполняется, если:
              // 1. Документа никогда не существовало (пользователь не администратор).
              // 2. Документ был только что удален (права администратора отозваны).
              final l10n = AppLocalizations.of(context)!;
              final errorMessage = l10n.accessDeniedNotAdmin;
              
              
              
              // Показываем страницу входа с сообщением об ошибке.
              if (user.emailVerified) {
                // Используем WidgetsBinding, чтобы избежать ошибок при изменении состояния во время сборки.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  auth.FirebaseAuth.instance.signOut();
                });
                return AuthPage(
                  changeLanguage: changeLanguage,
                  initialErrorMessage: errorMessage,
                );
              } else {
                return const VerifyEmailPage();
              }
            }
          },
        );
      },
    );
  }
}
