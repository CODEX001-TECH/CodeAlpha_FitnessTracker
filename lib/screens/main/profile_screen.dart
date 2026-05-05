import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/activity_provider.dart';
import '../../providers/theme_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'notifications_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _pickImage(BuildContext context, ActivityProvider provider) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      provider.updatePhoto(image.path);
    }
  }

  void _editName(BuildContext context, ActivityProvider provider) {
    final controller = TextEditingController(text: provider.displayName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter your name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.updateProfile(controller.text, provider.stepGoal);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editGoal(BuildContext context, ActivityProvider provider) {
    final controller = TextEditingController(text: provider.stepGoal.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Daily Step Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "e.g. 10000"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              int? goal = int.tryParse(controller.text);
              if (goal != null) {
                provider.updateProfile(provider.displayName, goal);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider?>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (activityProvider == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.directions_run_rounded, color: Color(0xFF3D5AFE), size: 36),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Stride', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Theme.of(context).colorScheme.onSurface)),
                Text('My Profile', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.normal)),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  onTap: () => _pickImage(context, activityProvider),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: const Color(0xFF3D5AFE),
                    backgroundImage: activityProvider.photoUrl != null
                        ? (kIsWeb
                            ? NetworkImage(activityProvider.photoUrl!)
                            : FileImage(File(activityProvider.photoUrl!)) as ImageProvider)
                        : null,
                    child: activityProvider.photoUrl == null
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
                  ),
                ),
                Tooltip(
                  message: 'Change Photo',
                  child: GestureDetector(
                    onTap: () => _pickImage(context, activityProvider),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                      ),
                      child: const Icon(Icons.camera_alt, size: 18, color: Color(0xFF3D5AFE)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  activityProvider.displayName == "User" 
                      ? (authProvider.user?.email?.split('@')[0] ?? 'Guest')
                      : activityProvider.displayName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Color(0xFF3D5AFE)),
                  onPressed: () => _editName(context, activityProvider),
                ),
              ],
            ),
            Text(
              authProvider.user?.email ?? 'Guest User',
              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            ),
            const SizedBox(height: 40),
            _buildProfileOption(
              icon: Icons.track_changes,
              title: 'Daily Step Goal',
              subtitle: '${activityProvider.stepGoal.toString()} steps',
              onTap: () => _editGoal(context, activityProvider),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D5AFE).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.dark_mode_outlined, color: Color(0xFF3D5AFE), size: 22),
                ),
                title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(value),
                activeColor: const Color(0xFF3D5AFE),
              ),
            ),
            _buildProfileOption(
              icon: Icons.notifications_none,
              title: 'Notifications',
              subtitle: 'On',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                );
              },
            ),
            _buildProfileOption(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'View our terms',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Privacy Policy'),
                    content: const SingleChildScrollView(
                      child: Text('Here are the terms and conditions of Stride Fitness.\n\nWe value your privacy and do not sell your personal data. All activity data is securely stored and processed to provide you with the best fitness tracking experience.'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildProfileOption(
              icon: Icons.logout_rounded,
              title: 'Sign Out',
              subtitle: '',
              isDestructive: true,
              onTap: () async {
                await Provider.of<AuthProvider>(context, listen: false).signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDestructive ? Colors.redAccent.withOpacity(0.1) : const Color(0xFF3D5AFE).withOpacity(0.1), 
            borderRadius: BorderRadius.circular(12)
          ),
          child: Icon(icon, color: isDestructive ? Colors.redAccent : const Color(0xFF3D5AFE), size: 20),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: isDestructive ? Colors.redAccent : Theme.of(context).colorScheme.onSurface)),
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))) : null,
        trailing: Icon(Icons.chevron_right, size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  },
);
}
}
