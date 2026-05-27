import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/constants/colors.dart';

class AdaptiveScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;

  const AdaptiveScaffold({
    super.key,
    required this.body,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            title,
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
                  inherit: false,
                  color: Colors.white,
                ),
          ),
          trailing: actions != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                )
              : null,
          backgroundColor: AppColors.background.withValues(alpha: 0.5),
          border: null,
        ),
        child: SafeArea(
          child: Material(
            color: Colors.transparent,
            child: body,
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: body,
    );
  }
}

class AdaptiveIcon extends StatelessWidget {
  final IconData iosIcon;
  final dynamic androidIcon;
  final Color? color;
  final double? size;

  const AdaptiveIcon({
    super.key,
    required this.iosIcon,
    required this.androidIcon,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return Icon(iosIcon, color: color, size: size);
    }
    if (androidIcon is IconData) {
      return Icon(androidIcon as IconData, color: color ?? AppColors.textPrimary, size: size ?? 24);
    }
    return HugeIcon(
      icon: androidIcon,
      color: color ?? AppColors.textPrimary,
      size: size ?? 24,
    );
  }
}
