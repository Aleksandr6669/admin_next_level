import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:nextlevel/l10n/app_localizations.dart';
import 'package:nextlevel/profile_service.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'styles.dart';
import 'language_selector.dart';
import 'models/language.dart';

const String _showStoriesKey = 'show_stories';

class SettingsPage extends StatefulWidget {
  final void Function(Locale locale) changeLanguage;
  final void Function(bool) onEditModeChange;
  final void Function(bool) onShowStoriesChanged;

  const SettingsPage({
    super.key,
    required this.changeLanguage,
    required this.onEditModeChange,
    required this.onShowStoriesChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  final _profileService = ProfileService();
  bool _isEditing = false;
  bool _showStories = true;
  bool _isConnected = true;

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _roleController = TextEditingController();
  final _positionController = TextEditingController();
  final _organizationController = TextEditingController();
  final _aboutController = TextEditingController();

  String _avatarUrl = '';
  late Language _selectedLanguage;

  late final AnimationController _bgAnimationController;
  late final AnimationController _cardStateAnimationController;
  late final Animation<double> _editFieldsAnimation;
  final _scrollController = ScrollController();

  double _extraHeight = 0;
  bool _isExpanded = false;
  static const double _initialCardHeight = 280;
  static const double _maxPullDown = 200.0;

  @override
  void initState() {
    super.initState();
    _loadShowStories();
    _loadProfileFromLocalStorage();
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _cardStateAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _editFieldsAnimation = CurvedAnimation(
        parent: Tween<double>(begin: 1.0, end: 0.0).animate(_cardStateAnimationController),
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
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

  Future<void> _loadShowStories() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _showStories = prefs.getBool(_showStoriesKey) ?? true;
      });
    }
  }

  Future<void> _setShowStories(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showStoriesKey, value);
    if (mounted) {
      setState(() {
        _showStories = value;
      });
    }
    widget.onShowStoriesChanged(value);
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
    if (_isEditing) {
      _profileService.finishEditing();
    }
    _bgAnimationController.dispose();
    _cardStateAnimationController.dispose();
    _scrollController.dispose();
    _profileSubscription?.cancel();
    _nameController.dispose();
    _lastNameController.dispose();
    _roleController.dispose();
    _positionController.dispose();
    _organizationController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  StreamSubscription? _profileSubscription;
  void _subscribeToProfileUpdates() {
    _profileSubscription?.cancel();
    _profileSubscription = _profileService.getUserProfile().listen((userProfile) {
      if (userProfile.exists) {
        final data = userProfile.data() as Map<String, dynamic>;
        _saveProfileToLocalStorage(data);
        if (mounted) {
            setState(() {
              _isConnected = true;
            });
          }
        if (!_isEditing) {
          _nameController.text = data['name'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _roleController.text = data['role'] ?? '';
          _positionController.text = data['position'] ?? '';
          _organizationController.text = data['organization'] ?? '';
          _aboutController.text = data['about'] ?? '';
        }
        if (mounted) {
          setState(() {
            _avatarUrl = data['avatarUrl'] ?? '';
          });
        }
      }
    }, onError: (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
      }
    });
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _setEditing(bool isEditing) async {
    if (isEditing) {
      await _profileService.startEditing();
    } else {
      await _profileService.finishEditing();
    }

    _scrollToTop();
    setState(() => _isEditing = isEditing);
    widget.onEditModeChange(isEditing);
    if (isEditing) {
      _animateCard(false);
    } else {
      _subscribeToProfileUpdates();
    }
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
      await _setEditing(false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
      }
    }
  }

  Future<void> _animateCard(bool expand) {
    _isExpanded = expand;
    final animation = expand ? _cardStateAnimationController.forward() : _cardStateAnimationController.reverse();
    return animation.then((_) {
        if (!expand) {
          setState(() => _extraHeight = 0);
        }
    });
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is OverscrollNotification && notification.dragDetails != null) {
      if (notification.overscroll > 0) {
        setState(() {
          _extraHeight += notification.overscroll / 2;
          _extraHeight = math.min(_extraHeight, _maxPullDown + 50); 
        });
      }
    } else if (notification is ScrollEndNotification) {
      if (_extraHeight > _maxPullDown / 2) {
        if (!_isExpanded) _animateCard(true);
      } else {
        if (_isExpanded || _extraHeight > 0) _animateCard(false);
      }
    } else if (notification is ScrollUpdateNotification) {
      if (_isExpanded && _scrollController.offset > 0) {
        _animateCard(false);
      }
    }
    return false;
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              children: [
                if (!_isConnected)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      l10n.noInternetConnection,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                _buildProfileSection(l10n),
                const SizedBox(height: 20),
                _buildInfoSection(l10n),
                const SizedBox(height: 20),
                _buildBottomSection(l10n),
                const SizedBox(height: 20),
                if (!_isEditing) _buildStoriesSwitch(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(AppLocalizations l10n) {
    final double currentHeight = _initialCardHeight + _extraHeight;
    final expansionValue =_cardStateAnimationController.value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      height: _isEditing ? 260 : currentHeight,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 20,
        blur: 10,
        border: 0,
        linearGradient: kGlassmorphicGradient,
        borderGradient: kGlassmorphicBorderGradient,
        child: Stack(
          children: [
            if (_avatarUrl.isNotEmpty)
              Positioned.fill(
                child: Opacity(
                  opacity: expansionValue,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(_avatarUrl, fit: BoxFit.cover, alignment: Alignment.center),
                  ),
                ),
              ),
            
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: double.infinity),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: _isEditing ? 40.0 : 60.0),
                  duration: const Duration(milliseconds: 100),
                  builder: (context, radius, child) {
                    return CircleAvatar(
                      radius: radius,
                      backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                      child: _avatarUrl.isEmpty ? Icon(Icons.person, size: radius) : null,
                    );
                  },
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: _isEditing
                      ? TextButton(
                          key: const ValueKey('changePhoto'),
                          onPressed: () { /* TODO: Implement image picker */ },
                          child: Text(l10n.changePhotoButton, style: const TextStyle(color: Color.fromARGB(211, 24, 109, 179))),
                        )
                      : const SizedBox(key: ValueKey('emptyButtonSpace'), height: 25),
                ),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                  child: _isEditing 
                      ? _buildProfileEditContent(l10n) 
                      : _buildProfileViewContent(l10n),
                ),
              ],
            ),

            if (!_isEditing)
              Positioned(
                bottom: 16,
                left: 16,
                child: FadeTransition(
                  opacity: _cardStateAnimationController,
                  child: Text(
                    '${_nameController.text}\n${_lastNameController.text}',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 8.0, color: Colors.black54)]),
                  ),
                ),
              ),
            if (!_isEditing)
              Positioned(
                top: 16,
                right: 16,
                child: FadeTransition(
                  opacity: _cardStateAnimationController,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: _isConnected ? () => _setEditing(true) : null,
                    style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileViewContent(AppLocalizations l10n) {
    return FadeTransition(
      key: const ValueKey('profileView'),
      opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_cardStateAnimationController),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildInfoDisplay('', '${_nameController.text} ${_lastNameController.text}', isFullName: true),
          const SizedBox(height: 10),
            TextButton.icon(
              icon: const Icon(Icons.edit, size: 16, color: Colors.white70),
              label: Text(l10n.editProfile, style: const TextStyle(color: Colors.white70)),
              onPressed: _isConnected ? () => _setEditing(true) : null,
            ),
        ],
      ),
    );
  }
  
  Widget _buildProfileEditContent(AppLocalizations l10n) {
    return FadeTransition(
      opacity: _editFieldsAnimation,
      child: Padding(
        key: const ValueKey('profileEdit'),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextField(_nameController, l10n.firstName),
            const SizedBox(height: 10),
            _buildTextField(_lastNameController, l10n.lastName),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(AppLocalizations l10n) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      width: double.infinity,
      height: _isEditing ? 340 : 300,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 20,
        blur: 10,
        border: 0,
        linearGradient: kGlassmorphicGradient,
        borderGradient: kGlassmorphicBorderGradient,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: _isEditing ? _buildInfoEditContent(l10n) : _buildInfoViewContent(l10n),
        ),
      ),
    );
  }

  Widget _buildInfoViewContent(AppLocalizations l10n) {
    return Padding(
      key: const ValueKey('infoView'),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoDisplay(l10n.role, _roleController.text),
          _buildInfoDisplay(l10n.position, _positionController.text),
          _buildInfoDisplay(l10n.organization, _organizationController.text),
          _buildInfoDisplay(l10n.aboutMe, _aboutController.text),
        ],
      ),
    );
  }

  Widget _buildInfoEditContent(AppLocalizations l10n) {
    return FadeTransition(
      opacity: _editFieldsAnimation,
      child: Padding(
        key: const ValueKey('infoEdit'),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextField(_roleController, l10n.role),
            const SizedBox(height: 10),
            _buildTextField(_positionController, l10n.position),
            const SizedBox(height: 10),
            _buildTextField(_organizationController, l10n.organization),
            const SizedBox(height: 10),
            _buildTextField(_aboutController, l10n.aboutMe, maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(AppLocalizations l10n) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(animation),
            child: child,
          ),
        );
      },
      child: _isEditing
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  key: const ValueKey('saveButton'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  onPressed: _updateProfile,
                  child: Text(l10n.saveChanges, style: const TextStyle(color: Colors.white)),
                ),
              ],
            )
          : LanguageSelector(
              key: const ValueKey('languageSelector'),
              selectedLanguage: _selectedLanguage,
              onLanguageChange: (language) {
                if (language != null) {
                  setState(() => _selectedLanguage = language);
                  widget.changeLanguage(Locale(language.code));
                }
              },
            ),
    );
  }

  Widget _buildStoriesSwitch(AppLocalizations l10n) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 60,
      borderRadius: 35,
      blur: 10,
      alignment: Alignment.center,
      border: 0,
      linearGradient: kGlassmorphicGradient,
      borderGradient: kGlassmorphicBorderGradient,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.showStories, style: const TextStyle(color: Colors.white, fontSize: 16)),
            Switch(
              value: _showStories,
              onChanged: _setShowStories,
              activeThumbColor: Colors.blue,
              inactiveTrackColor: Colors.white30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        isDense: true,
      ),
    );
  }

  Widget _buildInfoDisplay(String title, String value, {bool isFullName = false}) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: isFullName ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isFullName)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ),
          Text(
            value.isEmpty ? '-' : value,
            textAlign: isFullName ? TextAlign.center : TextAlign.start,
            style: TextStyle(color: Colors.white, fontSize: isFullName ? 22 : 16, fontWeight: isFullName ? FontWeight.bold : FontWeight.normal),
          ),
          if (!isFullName)
            const Divider(color: Colors.white24, height: 16, thickness: 0.5),
        ],
      ),
    );
  }
}
