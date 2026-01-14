
class Language {
  final String name;
  final String code;
  final String flagCode;

  const Language({required this.name, required this.code, required this.flagCode});
}

const List<Language> supportedLanguages = [
  Language(name: 'English', code: 'en', flagCode: 'GB'),
  Language(name: 'Français', code: 'fr', flagCode: 'FR'),
  Language(name: 'Українська', code: 'uk', flagCode: 'UA'),
];
