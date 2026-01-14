
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nextlevel/l10n/app_localizations.dart';

class EmailVerificationLandingPage extends StatefulWidget {
  final String oobCode;

  const EmailVerificationLandingPage({super.key, required this.oobCode});

  @override
  State<EmailVerificationLandingPage> createState() =>
      _EmailVerificationLandingPageState();
}

class _EmailVerificationLandingPageState extends State<EmailVerificationLandingPage> {
  bool _isVerifying = false;
  bool _isSuccess = false;

  Future<void> _verifyEmail() async {
    setState(() {
      _isVerifying = true;
    });

    try {
      await FirebaseAuth.instance.applyActionCode(widget.oobCode);
      if (!mounted) return;
      setState(() {
        _isSuccess = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.authenticationSuccess),
          backgroundColor: Colors.green,
        ),
      );
      // Optional: Navigate away after a delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? AppLocalizations.of(context)!.authenticationFailed),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if(mounted){
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.verifyYourEmail),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isSuccess)
                Column(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.authenticationSuccess, // Assuming you have this
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    const Icon(Icons.email_outlined, size: 80),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.pressButtonToVerify, // Use a new, simple localization string
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    _isVerifying
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: _verifyEmail,
                              child: Text(AppLocalizations.of(context)!.verify),
                            ),
                          ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
