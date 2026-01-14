
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nextlevel/l10n/app_localizations.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'styles.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    // Get user email safely
    userEmail = FirebaseAuth.instance.currentUser?.email;
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          sendVerificationEmail();
        }
      });

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    if (mounted) {
      setState(() {
        isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      });

      if (isEmailVerified) {
        timer?.cancel();
      }
    }
  }

  Future<void> sendVerificationEmail() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      if (mounted) {
        setState(() => canResendEmail = false);
      }
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) {
        setState(() => canResendEmail = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.tooManyRequests)),
        );
        setState(() => canResendEmail = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Fallback if email is not available
    final email = userEmail ?? 'your email';

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: kBackgroundDecoration,
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: GlassmorphicContainer(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 520, // Adjusted height for more text
                  borderRadius: 20,
                  blur: 10,
                  alignment: Alignment.center,
                  border: 0,
                  linearGradient: kGlassmorphicGradient,
                  borderGradient: kGlassmorphicBorderGradient,
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.mark_email_read_outlined,
                          color: Colors.white,
                          size: 80,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.verifyYourEmail,
                          textAlign: TextAlign.center,
                          style: kTitleTextStyle,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          l10n.verificationLinkSent(email),
                          textAlign: TextAlign.center,
                          style: kSubtitleTextStyle.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          decoration: kButtonBoxDecoration,
                          child: ElevatedButton(
                            onPressed: canResendEmail ? sendVerificationEmail : null,
                            style: kElevatedButtonStyle,
                            child: Text(l10n.resendEmail, style: kButtonTextStyle),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            timer?.cancel();
                            FirebaseAuth.instance.signOut();
                          },
                          child: Text(
                            l10n.cancel,
                            style: kTextLinkStyle.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
