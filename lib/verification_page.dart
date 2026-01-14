
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:nextlevel/l10n/app_localizations.dart';
import 'home_page.dart';
import 'package:pinput/pinput.dart'; // Import Pinput
import 'styles.dart';

class VerificationPage extends StatefulWidget {
  final String email;
  final String verificationCode;
  final Function(Locale) changeLanguage;

  const VerificationPage({
    super.key,
    required this.email,
    required this.verificationCode,
    required this.changeLanguage,
  });

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  String? _errorMessage;
  bool _isResending = false;
  late String _currentCode;

  @override
  void initState() {
    super.initState();
    _currentCode = widget.verificationCode;
    // --- AUTO-FILL THE CODE FOR DEBUGGING ---
    _codeController.text = _currentCode;
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _verifyCode() {
    if (_codeController.text == _currentCode) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(changeLanguage: widget.changeLanguage),
        ),
        (Route<dynamic> route) => false, // Remove all previous routes
      );
    } else {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.invalidCode;
      });
    }
  }

  void _resendCode() {
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    // Simulate network delay
    Future.delayed(const Duration(seconds: 1), () {
      final random = Random();
      final newCode = (100000 + random.nextInt(900000)).toString();

      // ignore: avoid_print
      print('New Verification Code: $newCode'); // For debugging

      if (mounted) {
        setState(() {
          _currentCode = newCode;
          // For debugging, update the controller with the new code
          _codeController.text = newCode;
          _isResending = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.verificationCodeSent)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 22, color: Colors.white),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withAlpha(51)),
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: GlassmorphicContainer(
                width: 400,
                height: 550,
                borderRadius: 20,
                blur: 26,
                alignment: Alignment.center,
                border: 0,
                linearGradient: kGlassmorphicGradient,
                borderGradient: kGlassmorphicBorderGradient,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.enterVerificationCode, textAlign: TextAlign.center, style: kTitleTextStyle),
                        const SizedBox(height: 15),
                        Text(l10n.verificationCodeSent, textAlign: TextAlign.center, style: kSubtitleTextStyle),
                        Text(widget.email, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 40),
                        Pinput(
                          controller: _codeController,
                          length: 6,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              border: Border.all(color: Colors.white.withAlpha(128)),
                            ),
                          ),
                          errorPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              border: Border.all(color: Colors.redAccent),
                            ),
                          ),
                          onCompleted: (pin) => _verifyCode(),
                           validator: (s) {
                            if (s == _currentCode) {
                              setState(() { _errorMessage = null; });
                              return null;
                            } else {
                               setState(() { _errorMessage = l10n.invalidCode; });
                               return l10n.invalidCode;
                            }
                          },
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 14), textAlign: TextAlign.center),
                          ),
                        const SizedBox(height: 40),
                        Container(
                          decoration: kButtonBoxDecoration,
                          child: ElevatedButton(
                            onPressed: _verifyCode,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            child: Text(l10n.verify, style: kButtonTextStyle),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _isResending
                            ? const Center(child: CircularProgressIndicator(color: Colors.white))
                            : TextButton(
                                onPressed: _resendCode,
                                child: Text(l10n.resendCode, style: kTextLinkStyle),
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
