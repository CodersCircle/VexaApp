import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/router.dart';
import 'features/downloads/bloc/downloads_bloc.dart';
import 'shared/services/download_service.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VexaApp());
}

class VexaApp extends StatelessWidget {
  const VexaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => DownloadService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => DownloadsBloc(
              context.read<DownloadService>(),
            )..add(LoadDownloads()),
          ),
        ],
        child: const VexaMaterialApp(),
      ),
    );
  }
}

class VexaMaterialApp extends StatelessWidget {
  const VexaMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoApp.router(
        title: 'Vexa',
        theme: AppTheme.cupertinoTheme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      );
    }
    return MaterialApp.router(
      title: 'Vexa',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
