import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  String? _editingUserId;
  Map<String, dynamic>? _editingUserData;
  final _editUserNameController = TextEditingController();
  final _editUserLastNameController = TextEditingController();
  final _editUserEmailController = TextEditingController();
  final _editUserRoleController = TextEditingController();
  final _editUserPositionController = TextEditingController();
  final _editUserOrganizationController = TextEditingController();

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
    _editUserNameController.dispose();
    _editUserLastNameController.dispose();
    _editUserEmailController.dispose();
    _editUserRoleController.dispose();
    _editUserPositionController.dispose();
    _editUserOrganizationController.dispose();
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
      border: 0,
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
                  TextButton(onPressed: () => setState(() => _isProfileEditing = false), child: Text(l10n.cancel)),
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
      border: 0,
      linearGradient: kGlassmorphicGradient,
      borderGradient: kGlassmorphicBorderGradient,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.school, color: Colors.white)),
                const SizedBox(width: 15),
                Text(l10n.schoolInfo, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            if (!_isSchoolEditing) ...[
              _buildInfoRow(l10n.schoolName, _schoolNameController.text),
              _buildInfoRow(l10n.about, _schoolAboutController.text),
              _buildInfoRow(l10n.contact, _schoolContactController.text),
              _buildInfoRow(l10n.students, _schoolStudentsController.text),
              const Spacer(),
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.edit, size: 16, color: Colors.blueAccent),
                  label: Text(l10n.editSchool, style: const TextStyle(color: Colors.blueAccent)),
                  onPressed: () => setState(() => _isSchoolEditing = true),
                ),
              ),
            ] else ...[
              Expanded(
                child: ListView(
                  children: [
                    _buildTextField(_schoolNameController, l10n.schoolName),
                    _buildTextField(_schoolAboutController, l10n.about),
                    _buildTextField(_schoolContactController, l10n.contact),
                    _buildTextField(_schoolStudentsController, l10n.students),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(onPressed: () => setState(() => _isSchoolEditing = false), child: Text(l10n.cancel)),
                  ElevatedButton(onPressed: () => setState(() => _isSchoolEditing = false), child: Text(l10n.saveChanges)),
                ],
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUsersCard(AppLocalizations l10n) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 550,
      borderRadius: 20,
      blur: 15,
      border: 0,
      linearGradient: kGlassmorphicGradient,
      borderGradient: kGlassmorphicBorderGradient,
      child: Stack(
        children: [
          // User list
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.people, color: Colors.white)),
                    const SizedBox(width: 15),
                    Text(l10n.userList, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No users found', style: const TextStyle(color: Colors.white)));
                    }

                    final users = snapshot.data!.docs;

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: users.length,
                      separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                      itemBuilder: (context, index) {
                        final userDoc = users[index];
                        final user = userDoc.data() as Map<String, dynamic>;
                        final userId = userDoc.id;
                        final userName = user['name'] ?? 'N/A';
                        final userLastName = user['lastName'] ?? '';
                        final userEmail = user['email'] ?? '';
                        final avatarUrl = user['avatarUrl'] as String? ?? '';

                        return ListTile(
                          onTap: () {
                            setState(() {
                              _editingUserId = userId;
                              _editingUserData = user;
                              _editUserNameController.text = user['name'] ?? '';
                              _editUserLastNameController.text = user['lastName'] ?? '';
                              _editUserEmailController.text = user['email'] ?? '';
                              _editUserRoleController.text = user['role'] ?? '';
                              _editUserPositionController.text = user['position'] ?? '';
                              _editUserOrganizationController.text = user['organization'] ?? '';
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white24,
                            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                            child: avatarUrl.isEmpty ? const Icon(Icons.person, size: 20, color: Colors.white) : null,
                          ),
                          title: Text('$userName $userLastName', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          subtitle: Text(userEmail, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right, color: Colors.white24),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          _buildEditUserPanel(l10n),
        ],
      ),
    );
  }

  Widget _buildEditUserPanel(AppLocalizations l10n) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(animation);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      child: _editingUserId != null
          ? GlassmorphicContainer(
              key: ValueKey(_editingUserId), // Important for AnimatedSwitcher
              width: double.infinity,
              height: double.infinity,
              borderRadius: 20,
              blur: 15,
              border: 0,
              linearGradient: kGlassmorphicGradient,
              borderGradient: kGlassmorphicBorderGradient,
              child: _buildUserEditForm(l10n),
            )
          : const SizedBox.shrink(), // Render nothing when not editing
    );
  }

  Widget _buildUserEditForm(AppLocalizations l10n) {
    final avatarUrl = _editingUserData?['avatarUrl'] as String? ?? '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _editingUserId = null;
              _editingUserData = null;
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmDeleteUser(context, l10n, _editingUserId!),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              child: avatarUrl.isEmpty ? const Icon(Icons.person, size: 50) : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(_editUserNameController, l10n.firstName),
            _buildTextField(_editUserLastNameController, l10n.lastName),
            _buildTextField(_editUserEmailController, l10n.email),
            _buildTextField(_editUserRoleController, l10n.role),
            _buildTextField(_editUserPositionController, l10n.position),
            _buildTextField(_editUserOrganizationController, l10n.organization),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _editingUserId = null;
                      _editingUserData = null;
                    });
                  },
                  child: Text(l10n.cancel, style: const TextStyle(color: Colors.blueAccent)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final updatedData = {
                      'name': _editUserNameController.text,
                      'lastName': _editUserLastNameController.text,
                      'email': _editUserEmailController.text,
                      'role': _editUserRoleController.text,
                      'position': _editUserPositionController.text,
                      'organization': _editUserOrganizationController.text,
                    };
                    FirebaseFirestore.instance.collection('users').doc(_editingUserId!).update(updatedData);
                    setState(() {
                      _editingUserId = null;
                      _editingUserData = null;
                    });
                  },
                  child: Text(l10n.save),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteUser(BuildContext context, AppLocalizations l10n, String userId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2c2c2c),
          title: const Text("Delete User", style: TextStyle(color: Colors.white)),
          content: const Text("Are you sure you want to delete this user?", style: TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel, style: const TextStyle(color: Colors.blueAccent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                FirebaseFirestore.instance.collection('users').doc(userId).delete();
                Navigator.of(context).pop(); // Close the confirmation dialog
                setState(() {
                  _editingUserId = null; // Close the edit panel
                  _editingUserData = null;
                });
              },
            ),
          ],
        );
      },
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
