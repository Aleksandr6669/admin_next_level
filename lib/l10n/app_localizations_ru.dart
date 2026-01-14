// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get joinUsToStartYourJourney =>
      'Присоединяйтесь к нам, чтобы начать свое путешествие';

  @override
  String get email => 'Электронная почта';

  @override
  String get password => 'Пароль';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get signUp => 'Зарегистрироваться';

  @override
  String get alreadyHaveAnAccount => 'Уже есть аккаунт? ';

  @override
  String get login => 'Войти';

  @override
  String get welcomeBack => 'С возвращением!';

  @override
  String get dontHaveAnAccount => 'Нет аккаунта? ';

  @override
  String get pleaseEnterYourEmail =>
      'Пожалуйста, введите свою электронную почту';

  @override
  String get pleaseEnterYourPassword => 'Пожалуйста, введите свой пароль';

  @override
  String get pleaseConfirmYourPassword => 'Пожалуйста, подтвердите свой пароль';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get language => 'Язык';

  @override
  String get appTitle => 'Демо Аврора';

  @override
  String get feedTitle => 'Лента';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get bottomNavFeed => 'Лента';

  @override
  String get bottomNavSettings => 'Настройки';

  @override
  String get bottomNavCourses => 'Курсы';

  @override
  String get bottomNavTests => 'Тесты';

  @override
  String get bottomNavProgress => 'Прогресс';

  @override
  String get enterVerificationCode => 'Введите код подтверждения';

  @override
  String get verificationCodeSent =>
      'Код подтверждения отправлен на вашу электронную почту.';

  @override
  String get verificationCode => 'Код подтверждения';

  @override
  String get pleaseEnterTheCode => 'Пожалуйста, введите 6-значный код.';

  @override
  String get verify => 'Подтвердить';

  @override
  String get resendCode => 'Отправить код еще раз';

  @override
  String get invalidCode => 'Неверный код подтверждения.';

  @override
  String get userNotFound =>
      'Пользователь с такой электронной почтой не найден. Пожалуйста, зарегистрируйтесь.';

  @override
  String get wrongPassword =>
      'Неверный пароль. Пожалуйста, попробуйте еще раз.';

  @override
  String get emailAlreadyInUse =>
      'Эта электронная почта уже используется. Пожалуйста, войдите.';

  @override
  String get authenticationFailed =>
      'Ошибка аутентификации. Пожалуйста, попробуйте еще раз.';

  @override
  String get authenticationSuccess => 'Аутентификация прошла успешно!';

  @override
  String get userDisabled =>
      'Этот пользователь был отключен. Пожалуйста, свяжитесь со службой поддержки.';

  @override
  String get invalidEmail => 'Неверный адрес электронной почты.';

  @override
  String get weakPassword => 'Пароль слишком слабый.';

  @override
  String get tooManyRequests =>
      'Слишком много запросов. Пожалуйста, попробуйте еще раз позже.';

  @override
  String get verifyYourEmail => 'Подтвердите свою электронную почту';

  @override
  String verificationLinkSent(String email) {
    return 'Ссылка для подтверждения отправлена на адрес $email. Проверьте свой почтовый ящик и следуйте инструкциям, чтобы завершить регистрацию.';
  }

  @override
  String get pressButtonToVerify =>
      'Нажмите кнопку ниже, чтобы завершить подтверждение электронной почты.';

  @override
  String get resendEmail => 'Отправить электронное письмо повторно';

  @override
  String get cancel => 'Отмена';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get resetPassword => 'Сбросить пароль';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get confirmNewPassword => 'Подтвердите новый пароль';

  @override
  String get passwordResetSuccess =>
      'Пароль успешно сброшен. Теперь вы можете войти с новым паролем.';

  @override
  String get passwordResetFailed =>
      'Не удалось сбросить пароль. Ссылка может быть недействительной или устаревшей.';

  @override
  String resetPasswordLinkSent(String email) {
    return 'Ссылка для сброса пароля отправлена на адрес $email. Пожалуйста, проверьте свой почтовый ящик.';
  }

  @override
  String get resetPasswordInstructions =>
      'Введите свой адрес электронной почты, и мы вышлем вам ссылку для восстановления доступа к вашей учетной записи.';

  @override
  String get sendResetLink => 'Отправить ссылку';

  @override
  String get backToLogin => 'Вернуться ко входу';

  @override
  String get profileSaved => 'Профиль успешно сохранен';

  @override
  String get editProfileButton => 'Редактировать профиль';

  @override
  String get firstName => 'Имя';

  @override
  String get pleaseEnterFirstName => 'Пожалуйста, введите ваше имя';

  @override
  String get lastName => 'Фамилия';

  @override
  String get pleaseEnterLastName => 'Пожалуйста, введите вашу фамилию';

  @override
  String get role => 'Роль';

  @override
  String get dateOfBirth => 'Дата рождения';

  @override
  String get specialty => 'Специальность';

  @override
  String get aboutMe => 'Обо мне';

  @override
  String get skillsHint => 'Навыки (через запятую)';

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get phoneNumber => 'Номер телефона';

  @override
  String get gender => 'Пол';

  @override
  String get position => 'Должность';

  @override
  String get organization => 'Организация';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get changePhotoButton => 'Изменить фото';

  @override
  String get showStories => 'Показывать истории';

  @override
  String get profileLocked => 'Профиль редактируется на другом устройстве.';

  @override
  String get noInternetConnection => 'Нет подключения к интернету';

  @override
  String get adminPanel => 'Админ панель';

  @override
  String get searchHint => 'Поиск...';
}
