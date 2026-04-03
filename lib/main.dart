import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patres/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:patres/blocs/library_bloc.dart';
import 'package:patres/blocs/theme_bloc.dart';
import 'package:patres/router.dart';
import 'package:patres/services/text_service.dart';
import 'package:patres/theme.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Use bundled SQLite (from sqlite3_flutter_libs) via FFI.
  // This ensures FTS5 is available on all platforms.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Match status bar to splash from the first frame
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFFF5E6D3),
  ));

  runApp(const PatresApp());
}

class PatresApp extends StatelessWidget {
  const PatresApp({super.key, this.textService = const TextService()});

  final TextService textService;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeBloc()),
        BlocProvider(
          create: (_) => LibraryBloc(textService: textService),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Patres',
            debugShowCheckedModeBanner: false,
            theme: PatresTheme.themeFor(state.themeMode),
            locale: const Locale('pl'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: router,
          );
        },
      ),
    );
  }
}
