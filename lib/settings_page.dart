import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _schoolExists = false;

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _roleController = TextEditingController();
  final _positionController = TextEditingController();
  final _organizationController = TextEditingController();
  final _aboutController = TextEditingController();

  final _schoolNameController = TextEditingController();
  final _schoolDirectionController = TextEditingController();
  final _schoolCreationDateController = TextEditingController();
  final _schoolEmailController = TextEditingController();
  final _schoolPhoneController = TextEditingController();
  final _schoolAdminNameController = TextEditingController();
  final _schoolAboutController = TextEditingController();

  String _avatarUrl = '';
  late Language _selectedLanguage;

  final _scrollController = ScrollController();
  StreamSubscription? _profileSubscription;
  StreamSubscription? _schoolSubscription;
  
  List<String> _adminIds = [];
  List<String> _teacherIds = [];
  List<String> _studentIds = [];

  @override
  void initState() {
    super.initState();
    _loadProfileFromLocalStorage();
    _subscribeToProfileUpdates();
    _subscribeToSchoolUpdates();
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
    _schoolDirectionController.dispose();
    _schoolCreationDateController.dispose();
    _schoolEmailController.dispose();
    _schoolPhoneController.dispose();
    _schoolAdminNameController.dispose();
    _schoolAboutController.dispose();
    _profileSubscription?.cancel();
    _schoolSubscription?.cancel();
    super.dispose();
  }

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

  void _subscribeToSchoolUpdates() {
    _schoolSubscription?.cancel();
    _schoolSubscription = _profileService.getSchoolProfile().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _schoolExists = true;
            if (!_isSchoolEditing) {
              _schoolNameController.text = data['name'] ?? '';
              _schoolDirectionController.text = data['direction'] ?? '';
              _schoolCreationDateController.text = data['creationDate'] ?? '';
              _schoolEmailController.text = data['email'] ?? '';
              _schoolPhoneController.text = data['phone'] ?? '';
              _schoolAdminNameController.text = data['adminName'] ?? '';
              _schoolAboutController.text = data['about'] ?? '';
            }
            _adminIds = List<String>.from(data['admins'] ?? []);
            _teacherIds = List<String>.from(data['teachers'] ?? []);
            _studentIds = List<String>.from(data['students'] ?? []);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _schoolExists = false;
            _adminIds = [];
            _teacherIds = [];
            _studentIds = [];
          });
        }
      }
    }, onError: (e) {
       if (mounted) setState(() => _isConnected = false);
    });
  }

  Future<void> _updateProfile() async {
    if (!_isConnected) return;
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
      if (mounted) {
        setState(() => _isProfileEditing = false);
        widget.onEditModeChange(false);
      }
    } catch (e) {
      if (mounted) setState(() => _isConnected = false);
    }
  }

  Future<void> _updateSchool() async {
    if (!_isConnected) return;
    try {
      final dataToUpdate = {
        'name': _schoolNameController.text,
        'direction': _schoolDirectionController.text,
        'email': _schoolEmailController.text,
        'phone': _schoolPhoneController.text,
        'adminName': _schoolAdminNameController.text,
        'about': _schoolAboutController.text,
      };
      await _profileService.updateSchoolProfile(dataToUpdate);
      if (mounted) {
        setState(() => _isSchoolEditing = false);
      }
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
                  final cardWidth = constraints.maxWidth > 850 ? (constraints.maxWidth - 40) / 3 : constraints.maxWidth;
                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildColumnWithTitle(l10n.profileTitle, _buildProfileCard(l10n), width: cardWidth),
                      _buildColumnWithTitle(l10n.schoolProfile, _buildSchoolCard(l10n), width: cardWidth),
                      if (_schoolExists) ...[
                         _buildColumnWithTitle(
                          l10n.admins,
                          _SchoolUsersCard(
                            key: ValueKey('admins_${_adminIds.length}'), // Важно для перестроения виджета
                            l10n: l10n,
                            userIds: _adminIds,
                            role: 'admins',
                            profileService: _profileService
                          ),
                          width: cardWidth,
                        ),
                        _buildColumnWithTitle(
                          l10n.teachers,
                           _SchoolUsersCard(
                            key: ValueKey('teachers_${_teacherIds.length}'),
                            l10n: l10n, 
                            userIds: _teacherIds, 
                            role: 'teachers', 
                            profileService: _profileService
                          ),
                          width: cardWidth,
                        ),
                        _buildColumnWithTitle(
                          l10n.students,
                           _SchoolUsersCard(
                            key: ValueKey('students_${_studentIds.length}'),
                            l10n: l10n, 
                            userIds: _studentIds, 
                            role: 'students', 
                            profileService: _profileService
                           ),
                          width: cardWidth,
                        ),
                      ]
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
      height: 650,
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
                onPressed: () => setState(() {
                  _isProfileEditing = true;
                  widget.onEditModeChange(true);
                }),
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
                  TextButton(onPressed: () => setState((){
                    _isProfileEditing = false;
                    widget.onEditModeChange(false);
                    _subscribeToProfileUpdates();
                  }), child: Text(l10n.cancel, style: const TextStyle(color: Colors.blueAccent)),),
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
      height: 650,
      borderRadius: 20,
      blur: 15,
      border: 0,
      linearGradient: kGlassmorphicGradient,
      borderGradient: kGlassmorphicBorderGradient,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white24,
              child: Icon(Icons.school, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 15),
            if (!_schoolExists && !_isSchoolEditing) ...[
              const Spacer(),
              Text(l10n.noSchoolMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
              const Spacer(),
              ElevatedButton(
                onPressed: () => setState(() {
                  _isSchoolEditing = true;
                  _schoolNameController.clear();
                  _schoolDirectionController.clear();
                  _schoolCreationDateController.clear();
                  _schoolEmailController.clear();
                  _schoolPhoneController.clear();
                  _schoolAdminNameController.clear();
                  _schoolAboutController.clear();
                }),
                child: Text(l10n.createSchool),
              ),
            ] else if (!_isSchoolEditing) ...[
              Text(_schoolNameController.text.isEmpty ? l10n.schoolName : _schoolNameController.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 16, color: Colors.blueAccent),
                label: Text(l10n.editSchool, style: const TextStyle(color: Colors.blueAccent)),
                onPressed: () => setState(() => _isSchoolEditing = true),
              ),
              const Spacer(),
              _buildInfoRow(l10n.schoolName, _schoolNameController.text),
              _buildInfoRow(l10n.schoolDirection, _schoolDirectionController.text),
              _buildInfoRow(l10n.creationDate, _schoolCreationDateController.text),
              _buildInfoRow(l10n.email, _schoolEmailController.text),
              _buildInfoRow(l10n.phone, _schoolPhoneController.text),
              _buildInfoRow(l10n.adminName, _schoolAdminNameController.text),
              _buildInfoRow(l10n.about, _schoolAboutController.text, maxLines: 2),
            ] else ...[
              Expanded(
                child: ListView(
                  children: [
                    _buildTextField(_schoolNameController, l10n.schoolName),
                    _buildTextField(_schoolDirectionController, l10n.schoolDirection),
                    _buildTextField(_schoolCreationDateController, l10n.creationDate, enabled: false),
                    _buildTextField(_schoolEmailController, l10n.email),
                    _buildTextField(_schoolPhoneController, l10n.phone),
                    _buildTextField(_schoolAdminNameController, l10n.adminName),
                    _buildTextField(_schoolAboutController, l10n.about, maxLines: 2),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(onPressed: () => setState(() {
                    _isSchoolEditing = false;
                    _subscribeToSchoolUpdates();
                    }), 
                    child: Text(l10n.cancel, style: const TextStyle(color: Colors.blueAccent)),),
                  ElevatedButton(
                    onPressed: _updateSchool, 
                    child: Text(_schoolExists ? l10n.saveChanges : l10n.createSchool)
                  ),
                ],
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          Text(value.isEmpty ? '-' : value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
          const Divider(color: Colors.white10, height: 8),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        style: TextStyle(color: enabled ? Colors.white : Colors.white38, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
          disabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
        ),
      ),
    );
  }
}

class _SchoolUsersCard extends StatefulWidget {
  final AppLocalizations l10n;
  final List<String> userIds;
  final String role;
  final ProfileService profileService;

  const _SchoolUsersCard({
    super.key, 
    required this.l10n,
    required this.userIds,
    required this.role,
    required this.profileService,
  });

  @override
  State<_SchoolUsersCard> createState() => _SchoolUsersCardState();
}

class _SchoolUsersCardState extends State<_SchoolUsersCard> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (_searchController.text.isNotEmpty) {
        widget.profileService.searchUsersByEmail(_searchController.text.toLowerCase()).then((results) {
          if (mounted) setState(() => _searchResults = results);
        });
      } else {
        if (mounted) setState(() => _searchResults = []);
      }
    });
  }

  void _showRemoveUserDialog(BuildContext context, String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xAA222222),
        title: Text(widget.l10n.removeUser, style: const TextStyle(color: Colors.white)),
        content: Text(widget.l10n.removeUserConfirmation(userName), style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(widget.l10n.cancel, style: const TextStyle(color: Colors.blueAccent))),
          ElevatedButton(
            onPressed: () async {
              await widget.profileService.removeUserFromSchool(userId, widget.role);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.l10n.userRemovedSuccess), backgroundColor: Colors.green));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(widget.l10n.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _addUser(String userId) async {
    await widget.profileService.addUserToSchool(userId, widget.role);
    _searchController.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.l10n.userAddedSuccess), backgroundColor: Colors.green));
  }

  String _getRoleTitle() {
    switch (widget.role) {
      case 'admins': return widget.l10n.admins;
      case 'teachers': return widget.l10n.teachers;
      case 'students': return widget.l10n.students;
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 650,
      borderRadius: 20,
      blur: 15,
      border: 0,
      linearGradient: kGlassmorphicGradient,
      borderGradient: kGlassmorphicBorderGradient,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isSearching ? _buildSearchView() : _buildUserListView(),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.people_alt_outlined, color: Colors.white)),
          const SizedBox(width: 15),
          Text(_getRoleTitle(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.add, color: Colors.white),
            onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) _searchController.clear();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListView() {
    if (widget.userIds.isEmpty) {
      return Center(child: Text(widget.l10n.noUsersInList, style: const TextStyle(color: Colors.white70)));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: widget.userIds.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
      itemBuilder: (context, index) {
        final userId = widget.userIds[index];
        return FutureBuilder<DocumentSnapshot>(
          future: widget.profileService.getUserById(userId),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const ListTile(title: Text('...', style: TextStyle(color: Colors.white38)));
            }
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final userName = '${userData['name'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
            final userEmail = userData['email'] ?? '';
            final avatarUrl = userData['avatarUrl'] as String? ?? '';
            return ListTile(
              onTap: () => _showRemoveUserDialog(context, userId, userName.isEmpty ? userEmail : userName),
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white24,
                  backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl.isEmpty ? const Icon(Icons.person, size: 20, color: Colors.white) : null),
              title: Text(userName.isEmpty ? widget.l10n.userNotFound : userName, style: const TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: Text(userEmail, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              trailing: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: widget.l10n.searchUserByEmail,
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _searchResults.isEmpty
                ? Center(child: Text(_searchController.text.isEmpty ? widget.l10n.searchTypeEmail : widget.l10n.searchNoUsersFound, style: const TextStyle(color: Colors.white70)))
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final userDoc = _searchResults[index];
                      final userData = userDoc.data() as Map<String, dynamic>;
                      final userName = '${userData['name'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
                      final userEmail = userData['email'] ?? '';
                      final avatarUrl = userData['avatarUrl'] as String? ?? '';
                      final isAlreadyAdded = widget.userIds.contains(userDoc.id);
                      return ListTile(
                        onTap: isAlreadyAdded ? null : () => _addUser(userDoc.id),
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white24,
                            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                            child: avatarUrl.isEmpty ? const Icon(Icons.person, size: 20, color: Colors.white) : null),
                        title: Text(userName.isEmpty ? widget.l10n.userNotFound : userName, style: TextStyle(color: isAlreadyAdded ? Colors.white38 : Colors.white, fontSize: 14)),
                        subtitle: Text(userEmail, style: TextStyle(color: isAlreadyAdded ? Colors.white38 : Colors.white70, fontSize: 12)),
                        trailing: isAlreadyAdded
                            ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                            : const Icon(Icons.add_circle_outline, color: Colors.blueAccent, size: 20),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(widget.l10n.totalUsers(widget.userIds.length), style: const TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }
}
