// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get createAccount => 'Створити акаунт';

  @override
  String get joinUsToStartYourJourney =>
      'Приєднуйтесь до нас, щоб почати свою подорож';

  @override
  String get email => 'Електронна пошта';

  @override
  String get password => 'Пароль';

  @override
  String get confirmPassword => 'Підтвердіть пароль';

  @override
  String get signUp => 'Зареєструватися';

  @override
  String get alreadyHaveAnAccount => 'Вже є акаунт? ';

  @override
  String get login => 'Увійти';

  @override
  String get welcomeBack => 'З поверненням!';

  @override
  String get dontHaveAnAccount => 'Немає акаунта? ';

  @override
  String get pleaseEnterYourEmail =>
      'Будь ласка, введіть вашу електронну пошту';

  @override
  String get pleaseEnterYourPassword => 'Будь ласка, введіть ваш пароль';

  @override
  String get pleaseConfirmYourPassword => 'Будь ласка, підтвердіть ваш пароль';

  @override
  String get passwordsDoNotMatch => 'Паролі не збігаються';

  @override
  String get language => 'Мова';

  @override
  String get appTitle => 'Демо Аврора';

  @override
  String get feedTitle => 'Стрічка';

  @override
  String get profileTitle => 'Профіль';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get bottomNavFeed => 'Стрічка';

  @override
  String get bottomNavSettings => 'Налашт-ння';

  @override
  String get bottomNavCourses => 'Курси';

  @override
  String get bottomNavTests => 'Тести';

  @override
  String get bottomNavProgress => 'Прогрес';

  @override
  String get logout => 'Вийти';

  @override
  String get enterVerificationCode => 'Введіть код підтвердження';

  @override
  String get verificationCodeSent =>
      'Код підтвердження було надіслано на вашу електронну пошту.';

  @override
  String get verificationCode => 'Код підтвердження';

  @override
  String get pleaseEnterTheCode => 'Будь ласка, введіть 6-значний код.';

  @override
  String get verify => 'Підтвердити';

  @override
  String get resendCode => 'Надіслати код ще раз';

  @override
  String get invalidCode => 'Невірний код підтвердження.';

  @override
  String get userNotFound =>
      'Користувача з такою електронною поштою не знайдено. Будь ласка, зареєструйтесь.';

  @override
  String get wrongPassword => 'Невірний пароль.';

  @override
  String get emailAlreadyInUse =>
      'Ця адреса електронної пошти вже використовується іншим акаунтом.';

  @override
  String get authenticationFailed =>
      'Помилка автентифікації. Будь ласка, спробуйте ще раз.';

  @override
  String get authenticationSuccess => 'Автентифікація пройшла успішно!';

  @override
  String get userDisabled =>
      'Цього користувача було вимкнено. Будь ласка, зв’яжіться з підтримкою.';

  @override
  String get invalidEmail => 'Невірний формат електронної пошти.';

  @override
  String get weakPassword => 'Пароль занадто слабкий.';

  @override
  String get tooManyRequests =>
      'Забагато запитів. Будь ласка, спробуйте пізніше.';

  @override
  String get verifyYourEmail => 'Підтвердіть вашу електронну пошту';

  @override
  String verificationLinkSent(String email) {
    return 'Посилання для підтвердження було надіслано на $email. Будь ласка, перевірте вашу поштову скриньку та дотримуйтесь інструкцій для завершення реєстрації.';
  }

  @override
  String get pressButtonToVerify =>
      'Натисніть кнопку нижче, щоб завершити підтвердження електронної пошти.';

  @override
  String get resendEmail => 'Надіслати лист ще раз';

  @override
  String get cancel => 'Скасувати';

  @override
  String get forgotPassword => 'Забули пароль?';

  @override
  String get resetPassword => 'Скинути пароль';

  @override
  String get newPassword => 'Новий пароль';

  @override
  String get confirmNewPassword => 'Підтвердіть новий пароль';

  @override
  String get passwordResetSuccess =>
      'Ваш пароль було успішно скинуто. Тепер ви можете увійти з новим паролем.';

  @override
  String get passwordResetFailed =>
      'Не вдалося скинути пароль. Посилання може бути недійсним або застарілим.';

  @override
  String resetPasswordLinkSent(String email) {
    return 'Посилання для скидання пароля було надіслано на $email. Будь ласка, перевірте вашу поштову скриньку.';
  }

  @override
  String get resetPasswordInstructions =>
      'Введіть вашу адресу електронної пошти, і ми надішлемо вам посилання для скидання пароля.';

  @override
  String get sendResetLink => 'Надіслати посилання для скидання';

  @override
  String get backToLogin => 'Повернутися до входу';

  @override
  String get profileSaved => 'Профіль успішно збережено';

  @override
  String get editProfileButton => 'Редагувати профіль';

  @override
  String get firstName => 'Ім’я';

  @override
  String get pleaseEnterFirstName => 'Будь ласка, введіть ваше ім’я';

  @override
  String get lastName => 'Прізвище';

  @override
  String get pleaseEnterLastName => 'Будь ласка, введіть ваше прізвище';

  @override
  String get role => 'Роль';

  @override
  String get dateOfBirth => 'Дата народження';

  @override
  String get specialty => 'Спеціальність';

  @override
  String get aboutMe => 'Про мене';

  @override
  String get skillsHint => 'Навички (через кому)';

  @override
  String get saveChanges => 'Зберегти зміни';

  @override
  String get phoneNumber => 'Номер телефону';

  @override
  String get gender => 'Стать';

  @override
  String get position => 'Посада';

  @override
  String get organization => 'Організація';

  @override
  String get editProfile => 'Редагувати профіль';

  @override
  String get changePhotoButton => 'Змінити фото';

  @override
  String get showStories => 'Показувати історії';

  @override
  String get profileLocked => 'Профіль редагується на іншому пристрої.';

  @override
  String get noInternetConnection => 'Немає підключення до Інтернету';

  @override
  String get adminPanel => 'Адмін-панель';

  @override
  String get searchHint => 'Пошук...';

  @override
  String get schoolProfile => 'Профіль школи';

  @override
  String get users => 'Користувачі';

  @override
  String get tooltipCollapse => 'Згорнути';

  @override
  String get tooltipExpand => 'Розгорнути';

  @override
  String get accessDeniedNotAdmin =>
      'Доступ заборонено. Вхід тільки для адміністраторів.';

  @override
  String get schoolInfo => 'Інформація про школу';

  @override
  String get editSchool => 'Редагувати школу';

  @override
  String get userList => 'Список користувачів';

  @override
  String get about => 'Про нас';

  @override
  String get contact => 'Контакт';

  @override
  String get students => 'Студенти';

  @override
  String get schoolName => 'Назва школи';

  @override
  String get save => 'Зберегти';

  @override
  String get deleteUser => 'Видалити користувача';

  @override
  String get deleteUserConfirmation =>
      'Ви впевнені, що хочете видалити цього користувача? Цю дію неможливо скасувати.';

  @override
  String get delete => 'Видалити';
}
