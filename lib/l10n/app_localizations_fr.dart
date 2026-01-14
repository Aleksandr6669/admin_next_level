// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get joinUsToStartYourJourney =>
      'Rejoignez-nous pour commencer votre voyage';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get confirmPassword => 'Confirmez le mot de passe';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get alreadyHaveAnAccount => 'Vous avez déjà un compte ? ';

  @override
  String get login => 'Connexion';

  @override
  String get welcomeBack => 'Content de vous revoir !';

  @override
  String get dontHaveAnAccount => 'Vous n\'avez pas de compte ? ';

  @override
  String get pleaseEnterYourEmail => 'Veuillez entrer votre e-mail';

  @override
  String get pleaseEnterYourPassword => 'Veuillez entrer votre mot de passe';

  @override
  String get pleaseConfirmYourPassword =>
      'Veuillez confirmer votre mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get language => 'Langue';

  @override
  String get appTitle => 'Démo Aurora';

  @override
  String get feedTitle => 'Fil';

  @override
  String get profileTitle => 'Profil';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get bottomNavFeed => 'Fil';

  @override
  String get bottomNavSettings => 'Paramètres';

  @override
  String get bottomNavCourses => 'Cours';

  @override
  String get bottomNavTests => 'Tests';

  @override
  String get bottomNavProgress => 'Progrès';

  @override
  String get enterVerificationCode => 'Entrez le code de vérification';

  @override
  String get verificationCodeSent =>
      'Un code de vérification a été envoyé à votre adresse e-mail.';

  @override
  String get verificationCode => 'Code de vérification';

  @override
  String get pleaseEnterTheCode => 'Veuillez entrer le code à 6 chiffres.';

  @override
  String get verify => 'Vérifier';

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String get invalidCode => 'Code de vérification invalide.';

  @override
  String get userNotFound =>
      'Utilisateur non trouvé pour cet e-mail. Veuillez vous inscrire.';

  @override
  String get wrongPassword => 'Mot de passe incorrect. Veuillez réessayer.';

  @override
  String get emailAlreadyInUse =>
      'Cet e-mail est déjà utilisé. Veuillez vous connecter.';

  @override
  String get authenticationFailed =>
      'L\'authentification a échoué. Veuillez réessayer.';

  @override
  String get authenticationSuccess => 'Authentification réussie !';

  @override
  String get userDisabled =>
      'Cet utilisateur a été désactivé. Veuillez contacter le support.';

  @override
  String get invalidEmail => 'Adresse e-mail invalide.';

  @override
  String get weakPassword => 'Le mot de passe est trop faible.';

  @override
  String get tooManyRequests =>
      'Trop de demandes. Veuillez réessayer plus tard.';

  @override
  String get verifyYourEmail => 'Vérifiez votre e-mail';

  @override
  String verificationLinkSent(String email) {
    return 'Un lien de vérification a été envoyé à $email. Veuillez vérifier votre boîte de réception et suivre les instructions pour finaliser l\'inscription.';
  }

  @override
  String get pressButtonToVerify =>
      'Appuyez sur le bouton ci-dessous pour terminer la vérification de votre e-mail.';

  @override
  String get resendEmail => 'Renvoyer l\'e-mail';

  @override
  String get cancel => 'Annuler';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmNewPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get passwordResetSuccess =>
      'Le mot de passe a été réinitialisé avec succès. Vous pouvez maintenant vous connecter avec votre nouveau mot de passe.';

  @override
  String get passwordResetFailed =>
      'La réinitialisation du mot de passe a échoué. Le lien peut être invalide ou avoir expiré.';

  @override
  String resetPasswordLinkSent(String email) {
    return 'Un lien de réinitialisation de mot de passe a été envoyé à $email. Veuillez vérifier votre boîte de réception.';
  }

  @override
  String get resetPasswordInstructions =>
      'Saisissez votre adresse électronique et nous vous enverrons un lien pour vous reconnecter à votre compte.';

  @override
  String get sendResetLink => 'Envoyer le lien de réinitialisation';

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String get profileSaved => 'Profil enregistré avec succès';

  @override
  String get editProfileButton => 'Modifier le profil';

  @override
  String get firstName => 'Prénom';

  @override
  String get pleaseEnterFirstName => 'Veuillez entrer votre prénom';

  @override
  String get lastName => 'Nom de famille';

  @override
  String get pleaseEnterLastName => 'Veuillez entrer votre nom de famille';

  @override
  String get role => 'Rôle';

  @override
  String get dateOfBirth => 'Date de naissance';

  @override
  String get specialty => 'Spécialité';

  @override
  String get aboutMe => 'À propos de moi';

  @override
  String get skillsHint => 'Compétences (séparées par des virgules)';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get gender => 'Gender';

  @override
  String get position => 'Position';

  @override
  String get organization => 'Organisation';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get changePhotoButton => 'Changer de photo';

  @override
  String get showStories => 'Afficher les stories';

  @override
  String get profileLocked =>
      'Le profil est en cours de modification sur un autre appareil.';

  @override
  String get noInternetConnection => 'Pas de connexion Internet';

  @override
  String get adminPanel => 'Panneau d\'administration';

  @override
  String get searchHint => 'Rechercher...';
}
