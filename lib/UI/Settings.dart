import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../auth/auth_state.dart';
import '../auth/signin_page.dart';
import '../auth/signup_page.dart';
import '../auth/profile_page.dart';
import '../services/auth_services.dart';

class SettingUi extends StatefulWidget {
  const SettingUi({Key? key}) : super(key: key);

  @override
  State<SettingUi> createState() => _SettingUiState();
}

class _SettingUiState extends State<SettingUi> {
  bool _isDark = false;

  // ---------- Helper Dialogs ----------
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Food App',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.fastfood, size: 40),
      children: const [
        SizedBox(height: 10),
        Text(
          'Food App helps users discover and order delicious food '
          'from different categories like bakeries, drinks, fruits, and salads.',
        ),
      ],
    );
  }

  void _showSimpleDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDark ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Settings"),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ListView(
              children: [
                // Show logged-in email if available
                if (AuthState.isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Logged in as: ${AuthState.userEmail}",
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),

                // ---------- GENERAL ----------
                _SingleSection(
                  title: "General",
                  children: [
                    _CustomListTile(
                      title: "Dark Mode",
                      icon: Icons.dark_mode_outlined,
                      trailing: Switch(
                        value: _isDark,
                        onChanged: (value) {
                          setState(() {
                            _isDark = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      onTap: _showAboutDialog,
                      title: const Text("About this App"),
                      leading: const Icon(Icons.info_outline),
                    ),
                    _CustomListTile(
                      title: "Notifications",
                      icon: Icons.notifications_none_rounded,
                      onTap: () {
                        _showSimpleDialog(
                          'Notifications',
                          'Notification settings are managed from your device system settings.',
                        );
                      },
                    ),
                    _CustomListTile(
                      title: "Security Status",
                      icon: CupertinoIcons.lock_shield,
                      onTap: () {
                        _showSimpleDialog(
                          'Security Status',
                          'Your account is secure. No issues detected.',
                        );
                      },
                    ),
                  ],
                ),

                const Divider(),

                // ---------- ORGANIZATION ----------
                _SingleSection(
                  title: "Organization",
                  children: [
                    _CustomListTile(
                      title: "Profile",
                      icon: Icons.person_outline_rounded,
                      onTap: () async {
                        if (!AuthState.isLoggedIn) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignInPage()),
                          );
                          setState(() {});
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProfilePage()),
                          );
                        }
                      },
                    ),
                    _CustomListTile(
                      title: "Messaging",
                      icon: Icons.message_outlined,
                      onTap: () {
                        _showSimpleDialog(
                          'Messaging',
                          'Messaging feature will be available in a future update.',
                        );
                      },
                    ),
                    _CustomListTile(
                      title: "Calling",
                      icon: Icons.phone_outlined,
                      onTap: () {
                        _showSimpleDialog(
                          'Calling',
                          'Calling feature is not enabled yet.',
                        );
                      },
                    ),
                    _CustomListTile(
                      title: "People",
                      icon: Icons.contacts_outlined,
                      onTap: () {
                        _showSimpleDialog(
                          'People',
                          'Contact management coming soon.',
                        );
                      },
                    ),
                    _CustomListTile(
                      title: "Calendar",
                      icon: Icons.calendar_today_rounded,
                      onTap: () {
                        _showSimpleDialog(
                          'Calendar',
                          'Calendar integration coming soon.',
                        );
                      },
                    ),
                  ],
                ),

                const Divider(),

                // ---------- ACCOUNT ----------
                _SingleSection(
                  children: [
                    _CustomListTile(
                      title: "Help & Feedback",
                      icon: Icons.help_outline_rounded,
                      onTap: () {
                        _showSimpleDialog(
                          'Help & Feedback',
                          'Contact us at support@foodapp.com',
                        );
                      },
                    ),

                    // Show Sign Up if user not logged in
                    if (!AuthState.isLoggedIn)
                      _CustomListTile(
                        title: "Sign Up",
                        icon: Icons.app_registration_rounded,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignupPage()),
                          );
                          setState(() {}); // Refresh UI after signup
                        },
                      ),

                    // Show Sign In if user not logged in
                    if (!AuthState.isLoggedIn)
                      _CustomListTile(
                        title: "Sign In",
                        icon: Icons.login_rounded,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignInPage()),
                          );
                          setState(() {}); // Refresh UI after login
                        },
                      ),

                    // Show Sign Out if user logged in
                    if (AuthState.isLoggedIn)
                      _CustomListTile(
                        title: "Sign Out",
                        icon: Icons.exit_to_app_rounded,
                        onTap: () async {
                          await AuthService.signOut();
                          setState(() {});
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- Custom Widgets ----------

class _CustomListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _CustomListTile({
    Key? key,
    required this.title,
    required this.icon,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _SingleSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _SingleSection({
    Key? key,
    this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Column(children: children),
      ],
    );
  }
}
