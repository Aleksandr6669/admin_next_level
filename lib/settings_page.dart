import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nextlevel/l10n/app_localizations.dart';
import 'package:nextlevel/profile_service.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'styles.dart';
import 'language_selector.dart';
import 'models/language.dart';

class SettingsPage extends StatefulWidget {
  final void Function(Locale locale) changeLanguage;
  final void Function(bool) onEditModeChange;

  const SettingsPage({
    super.key,
    required this.changeLanguage,
    required this.onEditModeChange,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  final _profileService = ProfileService();
  bool _isProfileEditing = false;
  bool _isSchoolEditing = false;
  bool _isConnected = true;

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _roleController = TextEditingController();
  final _positionController = TextEditingController();
  final _organizationController = TextEditingController();
  final _aboutController = TextEditingController();

  final _schoolNameController = TextEditingController(text: "NextLevel School");
  final _schoolAboutController = TextEditingController(text: "NextLevel: Online learning platform");
  final _schoolContactController = TextEditingController(text: "info@nextlevel.com");
  final _schoolStudentsController = TextEditingController(text: "1500 students");

  String _avatarUrl = '';
  late Language _selectedLanguage;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProfileFromLocalStorage();
    _subscribeToProfileUpdates();
  }

  Future<void> _loadProfileFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _nameController.text = prefs.getString('name') ?? '';
        _lastNameController.text = prefs.getString('lastName') ?? '';
        _roleController.text = prefs.getString('role') ?? '';
        _positionController.text = prefs.getString('position') ?? '';
        _organizationController.text = prefs.getString('organization') ?? '';
        _aboutController.text = prefs.getString('about') ?? '';
        _avatarUrl = prefs.getString('avatarUrl') ?? '';
      });
    }
  }

  Future<void> _saveProfileToLocalStorage(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', data['name'] ?? '');
    await prefs.setString('lastName', data['lastName'] ?? '');
    await prefs.setString('role', data['role'] ?? '');
    await prefs.setString('position', data['position'] ?? '');
    await prefs.setString('organization', data['organization'] ?? '');
    await prefs.setString('about', data['about'] ?? '');
    await prefs.setString('avatarUrl', data['avatarUrl'] ?? '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLocale = Localizations.localeOf(context);
    _selectedLanguage = supportedLanguages.firstWhere(
      (lang) => lang.code == currentLocale.languageCode,
      orElse: () => supportedLanguages.first,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _roleController.dispose();
    _positionController.dispose();
    _organizationController.dispose();
    _aboutController.dispose();
    _schoolNameController.dispose();
    _schoolAboutController.dispose();
    _schoolContactController.dispose();
    _schoolStudentsController.dispose();
    super.dispose();
  }

  StreamSubscription? _profileSubscription;
  void _subscribeToProfileUpdates() {
    _profileSubscription?.cancel();
    _profileSubscription = _profileService.getUserProfile().listen((userProfile) {
      if (userProfile.exists) {
        final data = userProfile.data() as Map<String, dynamic>;
        _saveProfileToLocalStorage(data);
        if (mounted) setState(() => _isConnected = true);
        if (!_isProfileEditing) {
          _nameController.text = data['name'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _roleController.text = data['role'] ?? '';
          _positionController.text = data['position'] ?? '';
          _organizationController.text = data['organization'] ?? '';
          _aboutController.text = data['about'] ?? '';
        }
        if (mounted) setState(() => _avatarUrl = data['avatarUrl'] ?? '');
      }
    }, onError: (e) {
      if (mounted) setState(() => _isConnected = false);
    });
  }

  Future<void> _updateProfile() async {
    try {
      final dataToUpdate = {
        'name': _nameController.text,
        'lastName': _lastNameController.text,
        'role': _roleController.text,
        'position': _positionController.text,
        'organization': _organizationController.text,
        'about': _aboutController.text,
        'avatarUrl': _avatarUrl,
      };
      await _profileService.updateUserProfile(dataToUpdate);
      await _saveProfileToLocalStorage(dataToUpdate);
      setState(() => _isProfileEditing = false);
      widget.onEditModeChange(false);
    } catch (e) {
      if (mounted) setState(() => _isConnected = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isConnected)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(l10n.noInternetConnection, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = constraints.maxWidth > 1100 ? (constraints.maxWidth - 40) / 3 : constraints.maxWidth;
                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildColumnWithTitle(l10n.profileTitle, _buildProfileCard(l10n), width: cardWidth),
                      _buildColumnWithTitle(l10n.schoolProfile, _buildSchoolCard(l10n), width: cardWidth),
                      _buildColumnWithTitle(l10n.users, _buildUsersCard(l10n), width: cardWidth),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),
              LanguageSelector(
                selectedLanguage: _selectedLanguage,
                onLanguageChange: (language) {
                  if (language != null) {
                    setState(() => _selectedLanguage = language);
                    widget.changeLanguage(Locale(language.code));
                  }
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColumnWithTitle(String title, Widget content, {required double width}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
            child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          content,
        ],
      ),
    );
  }

  Widget _buildProfileCard(AppLocalizations l10n) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 550,
      borderRadius: 20,
      blur: 15,
      border: 1,
      linearGradient: kGlassmorphicGradient,
      borderGradient: kGlassmorphicBorderGradient,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
              child: _avatarUrl.isEmpty ? const Icon(Icons.person, size: 50) : null,
            ),
            const SizedBox(height: 15),
            if (!_isProfileEditing) ...[
              Text('${_nameController.text} ${_lastNameController.text}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 16, color: Colors.blueAccent),
                label: Text(l10n.editProfile, style: const TextStyle(color: Colors.blueAccent)),
                onPressed: () => setState(() => _isProfileEditing = true),
              ),
              const Spacer(),
              _buildInfoRow(l10n.role, _roleController.text),
              _buildInfoRow(l10n.position, _positionController.text),
              _buildInfoRow(l10n.organization, _organizationController.text),
              _buildInfoRow(l10n.aboutMe, _aboutController.text, maxLines: 2),
            ] else ...[
              Expanded(
                child: ListView(
                  children: [
                    _buildTextField(_nameController, l10n.firstName),
                    _buildTextField(_lastNameController, l10n.lastName),
                    _buildTextField(_roleController, l10n.role),
                    _buildTextField(_positionController, l10n.position),
                    _buildTextField(_organizationController, l10n.organization),
                    _buildTextField(_aboutController, l10n.aboutMe, maxLines: 2),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(onPressed: () => setState(() => _isProfileEditing = false), child: const Text("Cancel")),
                  ElevatedButton(onPressed: _updateProfile, child: Text(l10n.saveChanges)),
                ],
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolCard(AppLocalizations l10n) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 550,
      borderRadius: 20,
      blur: 15,
      border: 1,
      linearGradient: kGlassmorphicGradient,
      borderGradient: kGlassmorphicBorderGradient,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.school, color: Colors.white)),
                SizedBox(width: 15),
                Text("School Info", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            if (!_isSchoolEditing) ...[
              _buildInfoRow("Name", _schoolNameController.text),
              _buildInfoRow("About", _schoolAboutController.text),
              _buildInfoRow("Contact", _schoolContactController.text),
              _buildInfoRow("Students", _schoolStudentsController.text),
              const Spacer(),
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.edit, size: 16, color: Colors.blueAccent),
                  label: const Text("Edit School", style: TextStyle(color: Colors.blueAccent)),
                  onPressed: () => setState(() => _isSchoolEditing = true),
                ),
              ),
            ] else ...[
              Expanded(
                child: ListView(
                  children: [
                    _buildTextField(_schoolNameController, "Name"),
                    _buildTextField(_schoolAboutController, "About"),
                    _buildTextField(_schoolContactController, "Contact"),
                    _buildTextField(_schoolStudentsController, "Students"),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(onPressed: () => setState(() => _isSchoolEditing = false), child: const Text("Cancel")),
                  ElevatedButton(onPressed: () => setState(() => _isSchoolEditing = false), child: const Text("Save")),
                ],
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUsersCard(AppLocalizations l10n) {
    final mockUsers = ["Иван Петров", "Мария Сидорова", "Алексей Ковалев", "Елена Смирнова", "Сергей Новиков", "Андрей Федоров", "Юлия Котова"];
    return GlassmorphicContainer(
      width: double.infinity,
      height: 550,
      borderRadius: 20,
      blur: 15,
      border: 1,
      linearGradient: kGlassmorphicGradient,
      borderGradient: kGlassmorphicBorderGradient,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.people, color: Colors.white)),
                SizedBox(width: 15),
                Text("User List", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: mockUsers.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white10),
              itemBuilder: (context, index) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(radius: 15, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 15, color: Colors.white)),
                title: Text(mockUsers[index], style: const TextStyle(color: Colors.white, fontSize: 14)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Text(value.isEmpty ? '-' : value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const Divider(color: Colors.white10),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
        ),
      ),
    );
  }
}
