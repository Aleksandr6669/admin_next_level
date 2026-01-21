import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'l10n/app_localizations.dart';
import 'models/language.dart';
import 'styles.dart';
import 'language_selector.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.changeLanguage, this.initialErrorMessage});

  final void Function(Locale locale) changeLanguage;
  final String? initialErrorMessage;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _isForgotPassword = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialErrorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showErrorSnackBar(context, widget.initialErrorMessage!);
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleFormType() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
    });
  }

  void _toggleForgotPassword() {
    setState(() {
      _isForgotPassword = !_isForgotPassword;
       _formKey.currentState?.reset();
    });
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleAuthAction() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_isLogin) {
          final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

          // Check for admin privileges in the 'admins' collection
          // final adminDoc = await FirebaseFirestore.instance.collection('admins').doc(userCredential.user!.uid).get();
          
          // if (!adminDoc.exists) {
          //   // If not an admin, sign out and throw an error
          //   // await FirebaseAuth.instance.signOut();
          //   throw FirebaseAuthException(code: 'admin-only-access');
          // } else {
          //   // If user is an admin, update their last login date in the 'users' collection
          //    await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).update({
          //     'lastLoginDate': Timestamp.now(),
          //   });
          // }
          // If user is an admin, update their last login date in the 'users' collection
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
              'lastLoginDate': Timestamp.now(),
            },SetOptions(merge: true));
        } else {
          // Registration: Create user
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
          final now = Timestamp.now();
          // Create a user document in the 'users' collection (NOT 'admins')
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
            'email': _emailController.text,
            'createdAt': now,
            'registrationDate': now,
            'lastLoginDate': now,
            'nicName': '',
            'name': '',
            'surname': '',
            'phoneNumber': '',
            'gender': '',
            'birthDate': '',
            'role': 'User', // Default role is User, not Admin
            'position': '',
            'about': '',
            'organization': '',
          });
          // Send verification email
          await userCredential.user?.sendEmailVerification();
        }
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        final context = _formKey.currentContext!;
        final l10n = AppLocalizations.of(context)!;
        String errorMessage;
        switch (e.code) {
          case 'admin-only-access':
            errorMessage = l10n.accessDeniedNotAdmin;
            break;
          case 'user-not-found':
            errorMessage = l10n.userNotFound;
            break;
          case 'wrong-password':
            errorMessage = l10n.wrongPassword;
            break;
          case 'email-already-in-use':
            errorMessage = l10n.emailAlreadyInUse;
            break;
          case 'user-disabled':
            errorMessage = l10n.userDisabled;
            break;
          case 'invalid-email':
            errorMessage = l10n.invalidEmail;
            break;
          case 'weak-password':
            errorMessage = l10n.weakPassword;
            break;
          case 'too-many-requests':
            errorMessage = l10n.tooManyRequests;
            break;
          default:
            errorMessage = l10n.authenticationFailed;
        }
        _showErrorSnackBar(context, errorMessage);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _handleForgotPasswordAction() async {
    if (_emailController.text.isEmpty) {
       final context = _formKey.currentContext!;
       final l10n = AppLocalizations.of(context)!;
      _showErrorSnackBar(context, l10n.pleaseEnterYourEmail);
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
      if(!mounted) return;
      final context = _formKey.currentContext!;
      final l10n = AppLocalizations.of(context)!;
      _showSuccessSnackBar(context, l10n.resetPasswordLinkSent( _emailController.text));
      _toggleForgotPassword(); // Go back to login view on success
    } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        final context = _formKey.currentContext!;
        final l10n = AppLocalizations.of(context)!;
       String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = l10n.userNotFound;
            break;
          case 'invalid-email':
            errorMessage = l10n.invalidEmail;
            break;
           case 'too-many-requests':
            errorMessage = l10n.tooManyRequests;
            break;
          default:
            errorMessage = l10n.authenticationFailed;
        }
        _showErrorSnackBar(context, errorMessage);
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: GlassmorphicAuthForm(
              formKey: _formKey,
              emailController: _emailController,
              passwordController: _passwordController,
              confirmPasswordController: _confirmPasswordController,
              changeLanguage: widget.changeLanguage,
              isLogin: _isLogin,
              isForgotPassword: _isForgotPassword,
              isLoading: _isLoading,
              onToggleFormType: _toggleFormType,
              onToggleForgotPassword: _toggleForgotPassword,
              handleAuthAction: _handleAuthAction,
              handleForgotPasswordAction: _handleForgotPasswordAction,
            ),
          ),
        ),
      ),
    );
  }
}

class GlassmorphicAuthForm extends StatelessWidget {
  const GlassmorphicAuthForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLogin,
    required this.isForgotPassword,
    required this.isLoading,
    required this.onToggleFormType,
    required this.onToggleForgotPassword,
    required this.changeLanguage,
    required this.handleAuthAction,
    required this.handleForgotPasswordAction,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLogin;
  final bool isForgotPassword;
  final bool isLoading;
  final VoidCallback onToggleFormType;
  final VoidCallback onToggleForgotPassword;
  final void Function(Locale locale) changeLanguage;
  final VoidCallback handleAuthAction;
  final VoidCallback handleForgotPasswordAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final selectedLanguage = supportedLanguages.firstWhere(
      (lang) => lang.code == locale.languageCode,
      orElse: () => supportedLanguages.first,
    );

    final double loginHeight = 600;
    final double registrationHeight = 640;
    final double forgotPasswordHeight = 480;

    final double targetHeight = isForgotPassword
        ? forgotPasswordHeight
        : isLogin
            ? loginHeight
            : registrationHeight;
    
    final bool isActionLoginOrRegister = !isForgotPassword;


    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      height: targetHeight,
      child: GlassmorphicContainer(
            width: MediaQuery.of(context).size.width * 0.9,
            height: targetHeight,
            borderRadius: 20,
            blur: 10,
            alignment: Alignment.center,
            border: 0,
            linearGradient: kGlassmorphicGradient,
            borderGradient: kGlassmorphicBorderGradient,
            child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  isForgotPassword ? l10n.forgotPassword : isLogin ? l10n.login : l10n.createAccount,
                  key: ValueKey(isForgotPassword ? 'forgot' : (isLogin ? 'login' : 'signup')),
                  textAlign: TextAlign.center,
                  style: kTitleTextStyle,
                ),
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  isForgotPassword ? l10n.resetPasswordInstructions : isLogin
                      ? l10n.welcomeBack
                      : l10n.joinUsToStartYourJourney,
                  key: ValueKey(isForgotPassword ? 'forgot_subtitle' : (isLogin ? 'login_subtitle' : 'signup_subtitle')),
                  textAlign: TextAlign.center,
                  style: kSubtitleTextStyle,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: emailController,
                style: const TextStyle(color: Color.fromARGB(255, 204, 207, 220)),
                decoration:
                    kInputDecoration(l10n.email, Icons.email_outlined),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !value.contains('@')) {
                    return l10n.pleaseEnterYourEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              AnimatedSize(
                 duration: const Duration(milliseconds: 400),
                 curve: Curves.easeInOut,
                child: isActionLoginOrRegister ? Column(
                  children: [
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration:
                          kInputDecoration(l10n.password, Icons.lock_outline),
                      validator: (value) {
                        if (isLogin) return null;
                        if (value == null || value.isEmpty) {
                          return l10n.pleaseEnterYourPassword;
                        }
                        return null;
                      },
                    ),
                  ],
                ) : const SizedBox.shrink(),
              ),
              
              if (isLogin && !isForgotPassword)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onToggleForgotPassword,
                    child: Text(
                      l10n.forgotPassword,
                      style: kTextLinkStyle,
                    ),
                  ),
                ),
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: !isLogin && isActionLoginOrRegister
                    ? Column(
                        children: [
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: kInputDecoration(
                                l10n.confirmPassword, Icons.lock_reset),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.pleaseConfirmYourPassword;
                              }
                              if (value != passwordController.text) {
                                return l10n.passwordsDoNotMatch;
                              }
                              return null;
                            },
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),
              if(isActionLoginOrRegister)
              LanguageSelector(
                selectedLanguage: selectedLanguage,
                onLanguageChange: (Language? newLanguage) {
                  if (newLanguage != null) {
                    changeLanguage(Locale(newLanguage.code));
                  }
                },
              ),
              const SizedBox(height: 20),
              Container(
                decoration: kButtonBoxDecoration,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () {
                    if (isForgotPassword) {
                       handleForgotPasswordAction();
                    } else {
                       handleAuthAction();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18), // Reverted padding
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            isForgotPassword ? l10n.sendResetLink : isLogin ? l10n.login : l10n.signUp,
                             key: ValueKey(isForgotPassword ? 'forgot_button' : (isLogin ? 'login_button' : 'signup_button')),
                            style: kButtonTextStyle,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
               AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isForgotPassword ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       GestureDetector(
                        onTap: onToggleForgotPassword,
                        child: Text(
                            l10n.backToLogin,
                            style: kTextLinkStyle,
                        ),
                      ),
                    ]
                  ) :
                   Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      isLogin
                          ? l10n.dontHaveAnAccount
                          : l10n.alreadyHaveAnAccount,
                      key: ValueKey(isLogin),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  GestureDetector(
                    onTap: onToggleFormType,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        isLogin ? ' ${l10n.signUp}' : ' ${l10n.login}',
                        key: ValueKey(isLogin),
                        style: kTextLinkStyle,
                      ),
                    ),
                  ),
                ],
              ),
              )
            ],
          ),
        ),
      ),
          ),
    );
  }
}
