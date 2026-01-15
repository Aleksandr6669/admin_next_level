// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinUsToStartYourJourney => 'Join us to start your journey';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get signUp => 'Sign Up';

  @override
  String get alreadyHaveAnAccount => 'Already have an account? ';

  @override
  String get login => 'Login';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get dontHaveAnAccount => 'Don\'t have an account? ';

  @override
  String get pleaseEnterYourEmail => 'Please enter your email';

  @override
  String get pleaseEnterYourPassword => 'Please enter your password';

  @override
  String get pleaseConfirmYourPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get language => 'Language';

  @override
  String get appTitle => 'Aurora Demo';

  @override
  String get feedTitle => 'Feed';

  @override
  String get profileTitle => 'Profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get bottomNavFeed => 'Feed';

  @override
  String get bottomNavSettings => 'Settings';

  @override
  String get bottomNavCourses => 'Courses';

  @override
  String get bottomNavTests => 'Tests';

  @override
  String get bottomNavProgress => 'Progress';

  @override
  String get logout => 'Logout';

  @override
  String get enterVerificationCode => 'Enter Verification Code';

  @override
  String get verificationCodeSent =>
      'A verification code has been sent to your email.';

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get pleaseEnterTheCode => 'Please enter the 6-digit code.';

  @override
  String get verify => 'Verify';

  @override
  String get resendCode => 'Resend Code';

  @override
  String get invalidCode => 'Invalid verification code.';

  @override
  String get userNotFound => 'No user found for that email. Please sign up.';

  @override
  String get wrongPassword => 'Wrong password provided for that user.';

  @override
  String get emailAlreadyInUse =>
      'The email address is already in use by another account.';

  @override
  String get authenticationFailed => 'Authentication failed. Please try again.';

  @override
  String get authenticationSuccess => 'Authentication successful!';

  @override
  String get userDisabled =>
      'This user has been disabled. Please contact support.';

  @override
  String get invalidEmail => 'The email address is badly formatted.';

  @override
  String get weakPassword => 'The password is too weak.';

  @override
  String get tooManyRequests => 'Too many requests. Please try again later.';

  @override
  String get verifyYourEmail => 'Verify Your Email';

  @override
  String verificationLinkSent(String email) {
    return 'A verification link has been sent to $email. Please check your inbox and follow the instructions to complete your registration.';
  }

  @override
  String get pressButtonToVerify =>
      'Press the button below to complete the email verification.';

  @override
  String get resendEmail => 'Resend Email';

  @override
  String get cancel => 'Cancel';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get passwordResetSuccess =>
      'Your password has been reset successfully. You can now log in with your new password.';

  @override
  String get passwordResetFailed =>
      'Failed to reset password. The link may be invalid or expired.';

  @override
  String resetPasswordLinkSent(String email) {
    return 'A password reset link has been sent to $email. Please check your inbox.';
  }

  @override
  String get resetPasswordInstructions =>
      'Enter your email address and we will send you a link to reset your password.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get profileSaved => 'Profile saved successfully';

  @override
  String get editProfileButton => 'Edit Profile';

  @override
  String get firstName => 'First Name';

  @override
  String get pleaseEnterFirstName => 'Please enter your first name';

  @override
  String get lastName => 'Last Name';

  @override
  String get pleaseEnterLastName => 'Please enter your last name';

  @override
  String get role => 'Role';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get specialty => 'Specialty';

  @override
  String get aboutMe => 'About Me';

  @override
  String get skillsHint => 'Skills (comma-separated)';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get gender => 'Gender';

  @override
  String get position => 'Position';

  @override
  String get organization => 'Organization';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePhotoButton => 'Change Photo';

  @override
  String get showStories => 'Show Stories';

  @override
  String get profileLocked => 'Profile is being edited on another device.';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get searchHint => 'Search...';

  @override
  String get schoolProfile => 'School Profile';

  @override
  String get users => 'Users';

  @override
  String get tooltipCollapse => 'Collapse';

  @override
  String get tooltipExpand => 'Expand';

  @override
  String get accessDeniedNotAdmin => 'Access denied. Only admins can log in.';
}
