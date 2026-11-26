import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/l10n.dart';
import 'pages/detail_page.dart';
import 'pages/list_page.dart';
import 'pages/main_shell.dart';
import 'pages/online_page.dart';
import 'pages/settings_page.dart';
import 'state/catalog_model.dart';
import 'state/favorites_model.dart';
import 'state/settings_model.dart';

final ValueNotifier<String?> globalError = ValueNotifier<String?>(null);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    reportError(details.exceptionAsString());
  };
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    debugPrint('Uncaught async error: $error');
    reportError(error.toString());
    return true;
  };
  final prefs = await SharedPreferences.getInstance();
  runApp(TextbookApp(prefs: prefs));
}

void reportError(String message) {
  if (globalError.value == message) {
    return;
  }
  globalError.value = message;
}

class TextbookApp extends StatelessWidget {
  const TextbookApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CatalogModel(prefs)),
        ChangeNotifierProvider(create: (_) => FavoritesModel(prefs)),
        ChangeNotifierProvider(create: (_) => SettingsModel(prefs)),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Textbook Exchange',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8FB8DE))
            .copyWith(
              primary: const Color(0xFF5B8FC7),
              onPrimary: Colors.white,
              secondary: const Color(0xFFE8A0B4),
              onSecondary: const Color(0xFF4A2430),
              surface: Colors.white,
              onSurface: const Color(0xFF2B3445),
              surfaceContainerHighest: const Color(0xFFEFF4FB),
              outlineVariant: const Color(0xFFE1E8F2),
            ),
        scaffoldBackgroundColor: const Color(0xFFF7FAFE),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Color(0xFFF7FAFE),
          surfaceTintColor: Colors.transparent,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Color(0xFFF9D8E3),
          surfaceTintColor: Colors.transparent,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE9EEF6),
          thickness: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE1E8F2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE1E8F2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF8FB8DE), width: 1.4),
          ),
        ),
      ),
      home: const MainShell(),
      onGenerateRoute: _onGenerateRoute,
      builder: (context, child) {
        return ColoredBox(
          color: const Color(0xFFE9EEF6),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: _GlobalErrorHost(child: child ?? const SizedBox.shrink()),
            ),
          ),
        );
      },
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case ListPage.routeName:
        final args = settings.arguments! as ListPageArgs;
        return MaterialPageRoute<void>(
          builder: (_) => ListPage(args: args),
          settings: settings,
        );
      case DetailPage.routeName:
        final args = settings.arguments! as DetailArgs;
        return PageRouteBuilder<void>(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 240),
          pageBuilder: (context, animation, secondaryAnimation) =>
              DetailPage(args: args),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
      case SettingsPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => const SettingsPage(),
          settings: settings,
        );
      case OnlinePage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => const OnlinePage(),
          settings: settings,
        );
    }
    return null;
  }
}

class _GlobalErrorHost extends StatelessWidget {
  const _GlobalErrorHost({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ValueListenableBuilder<String?>(
            valueListenable: globalError,
            builder: (context, message, _) {
              if (message == null) {
                return const SizedBox.shrink();
              }
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Material(
                    color: const Color(0xFFB3261E),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => globalError.value = null,
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                            tooltip: l.close,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
