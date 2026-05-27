import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/colors.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoActionSheet(
        title: const Text('Settings'),
        message: const Text('Configure your preferences'),
        actions: [
          _buildCupertinoItem(
            context,
            'Download Folder',
            CupertinoIcons.folder,
            'Vexa/Videos',
          ),
          _buildCupertinoItem(
            context,
            'Default Quality',
            CupertinoIcons.settings,
            '1080p',
          ),
          _buildCupertinoItem(
            context,
            'Dark Mode',
            CupertinoIcons.moon,
            'On',
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'Settings',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildMaterialItem(
            'Download Folder',
            HugeIcons.strokeRoundedFolder01,
            'Vexa/Videos',
          ),
          _buildMaterialItem(
            'Default Quality',
            HugeIcons.strokeRoundedSettings02,
            '1080p',
          ),
          _buildMaterialItem(
            'Theme Mode',
            HugeIcons.strokeRoundedMoon02,
            'Dark',
          ),
          _buildMaterialItem(
            'Storage Info',
            HugeIcons.strokeRoundedDatabase,
            '1.2 GB used',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCupertinoItem(BuildContext context, String title, IconData icon, String value) {
    return CupertinoActionSheetAction(
      onPressed: () {},
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 14, color: CupertinoColors.systemGrey)),
        ],
      ),
    );
  }

  Widget _buildMaterialItem(String title, dynamic icon, String value) {
    return ListTile(
      leading: icon is IconData 
          ? Icon(icon, color: AppColors.primary, size: 24)
          : HugeIcon(icon: icon, color: AppColors.primary, size: 24),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      trailing: Text(value, style: const TextStyle(color: AppColors.textSecondary)),
      onTap: () {},
    );
  }
}
