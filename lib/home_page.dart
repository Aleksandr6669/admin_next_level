import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nextlevel/courses_page.dart';
import 'package:nextlevel/feed_page.dart';
import 'package:nextlevel/liquid_nav_bar.dart';
import 'package:nextlevel/progress_page.dart';
import 'package:nextlevel/settings_page.dart';
import 'package:nextlevel/tests_page.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:nextlevel/l10n/app_localizations.dart';
import 'package:nextlevel/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'styles.dart';

const String _showStoriesKey = 'show_stories';

class AppUser {
  final String name;
  final String role;
  final String? avatarUrl;

  AppUser({required this.name, required this.role, this.avatarUrl});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.changeLanguage});
  final void Function(Locale locale) changeLanguage;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _widgetIndex = 0;
  bool _showStories = true;
  late Future<AppUser> _userFuture;
  final _profileService = ProfileService();
  StreamSubscription? _profileSubscription;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadShowStories();
    _userFuture = _fetchUserData();
    _subscribeToUserUpdates();
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToUserUpdates() {
    _profileSubscription = _profileService.getUserProfile().listen((userProfile) {
      if (userProfile.exists && mounted) {
        final data = userProfile.data() as Map<String, dynamic>;
        final authUser = auth.FirebaseAuth.instance.currentUser;

        final name = data['name'] ?? '';
        final lastName = data['lastName'] ?? '';
        final role = data['role'];
        String? avatarUrl = data['avatarUrl'];

        String finalName;
        if (name.isNotEmpty || lastName.isNotEmpty) {
          finalName = '$name $lastName'.trim();
        } else {
          finalName = authUser?.displayName ?? 'No Name';
        }

        String finalRole = (role != null && role.isNotEmpty) ? role : 'Student';

        avatarUrl = (avatarUrl != null && avatarUrl.isNotEmpty) ? avatarUrl : null;
        avatarUrl ??= authUser?.photoURL;

        final updatedUser = AppUser(
          name: finalName,
          role: finalRole,
          avatarUrl: avatarUrl,
        );

        setState(() {
          _userFuture = Future.value(updatedUser);
        });
      }
    });
  }

  Future<AppUser> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final authUser = auth.FirebaseAuth.instance.currentUser;

    final name = prefs.getString('name');
    final lastName = prefs.getString('lastName');
    final role = prefs.getString('role');
    final avatarUrl = prefs.getString('avatarUrl');

    String finalName;
    if (name != null && lastName != null && (name.isNotEmpty || lastName.isNotEmpty)) {
      finalName = '$name $lastName'.trim();
    } else {
      finalName = authUser?.displayName ?? 'No Name';
    }

    String finalRole = (role != null && role.isNotEmpty) ? role : 'Student';

    String? finalAvatarUrl = (avatarUrl != null && avatarUrl.isNotEmpty) ? avatarUrl : null;
    finalAvatarUrl ??= authUser?.photoURL;
    
    return AppUser(
      name: finalName,
      role: finalRole,
      avatarUrl: finalAvatarUrl,
    );
  }


  Future<void> _loadShowStories() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _showStories = prefs.getBool(_showStoriesKey) ?? true;
      });
    }
  }

  void _handleSettingsEditModeChange(bool isEditing) {
    if (!isEditing) {
      setState(() {
        _userFuture = _fetchUserData();
      });
    }
  }

  void _handleShowStoriesChange(bool show) {
    setState(() {
      _showStories = show;
    });
  }

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  void _onItemTapped(int navBarIndex) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_showStories) {
        _widgetIndex = navBarIndex;
      } else {
        _widgetIndex = navBarIndex + 1;
      }
    });
  }

  void _toggleSidebar() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Future<void> _logout() async {
    await auth.FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final navItems = _getNavItems(context);

    final List<Widget> widgetOptions = <Widget>[
      const FeedPage(),
      const CoursesPage(),
      const TestsPage(),
      const ProgressPage(),
      SettingsPage(
        changeLanguage: widget.changeLanguage,
        onEditModeChange: _handleSettingsEditModeChange,
      ),
    ];

    int navBarIndex;
    if (_showStories) {
      navBarIndex = _widgetIndex;
    } else {
      navBarIndex = _widgetIndex > 0 ? _widgetIndex - 1 : 0;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<AppUser>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading user data'));
            }
            final user = snapshot.data ?? AppUser(name: 'Loading...', role: '');

            return Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  _buildHeader(context, user),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: _isExpanded ? 180 : 72,
                          child: _buildGlassmorphicSideNavBar(
                              context, navItems, navBarIndex),
                        ),
                        const VerticalDivider(thickness: 1, width: 1),
                        Expanded(
                          child: IndexedStack(
                            index: _widgetIndex,
                            children: widgetOptions,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildFooter(context),
                ],
              ),
            );
          }),
    );
  }

  List<Map<String, dynamic>> _getNavItems(BuildContext context) {
    return [
      if (_showStories) {'icon': Icons.home, 'label': l10n.bottomNavFeed},
      {'icon': Icons.school, 'label': l10n.bottomNavCourses},
      {'icon': Icons.assignment, 'label': l10n.bottomNavTests},
      {'icon': Icons.show_chart, 'label': l10n.bottomNavProgress},
      {'icon': Icons.settings, 'label': l10n.bottomNavSettings},
    ];
  }

  Widget _buildHeader(BuildContext context, AppUser user) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 70,
      borderRadius: 0,
      blur: 7,
      alignment: Alignment.center,
      border: 0,
      linearGradient: kDropdownGradient,
      borderGradient: kAppBarBorderGradient,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            const Icon(Icons.school, color: Colors.white, size: 30), // Logo placeholder
            const SizedBox(width: 8),
            Text('Next Level', style: kTitleTextStyle.copyWith(fontSize: 20)),
            const SizedBox(width: 30),
            if (user.role == 'Admin')
              Text(
                l10n.adminPanel,
                style: kTitleTextStyle.copyWith(fontSize: 16, color: Colors.white.withOpacity(0.8)),
              ),
            const Spacer(),
            SizedBox(
              width: 350, 
              child: TextField(
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  hintStyle: kSubtitleTextStyle.copyWith(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.2),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  user.name,
                  style: kTitleTextStyle.copyWith(fontSize: 16),
                ),
                Text(
                  user.role,
                  style: kSubtitleTextStyle.copyWith(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(width: 16),
            CircleAvatar(
              radius: 20,
              backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFooter(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 50,
      borderRadius: 0,
      blur: 7,
      alignment: Alignment.center,
      border: 0,
      linearGradient: kDropdownGradient,
      borderGradient: kAppBarBorderGradient,
      child: Center(
        child: Text(
          'Next Level © 2024',
          style: kSubtitleTextStyle.copyWith(fontSize: 16, color: Colors.white54),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicSideNavBar(
      BuildContext context, List<Map<String, dynamic>> navItems, int navBarIndex) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: double.infinity,
      borderRadius: 0,
      blur: 7,
      alignment: Alignment.center,
      border: 0,
      linearGradient: kDropdownGradient,
      borderGradient: kAppBarBorderGradient,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Align(
            alignment: _isExpanded ? Alignment.centerRight : Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(right: _isExpanded ? 16.0 : 0.0),
              child: IconButton(
                onPressed: _toggleSidebar,
                icon: Icon(
                  _isExpanded ? Icons.chevron_left : Icons.chevron_right,
                  color: Colors.white,
                ),
                tooltip: _isExpanded ? l10n.tooltipCollapse : l10n.tooltipExpand,
              ),
            ),
          ),
          Expanded(
            child: LiquidNavBar(
              selectedIndex: navBarIndex,
              onTap: _onItemTapped,
              items: navItems,
              selectedItemColor: kBottomNavSelectedItemColor,
              unselectedItemColor: kBottomNavUnselectedItemColor,
              direction: Axis.vertical,
              extended: _isExpanded,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: kBottomNavUnselectedItemColor.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: kBottomNavUnselectedItemColor),
                title: _isExpanded
                    ? Text(l10n.logout, style: const TextStyle(color: kBottomNavUnselectedItemColor, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis,)
                    : const SizedBox.shrink(),
                onTap: _logout,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
