import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storatax/res/components/app_localization.dart';
import 'package:storatax/res/providers.dart';
import 'package:storatax/utils/routes/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:storatax/utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣ Load environment variables first
  await dotenv.load(fileName: "keys.env");

  // 2️⃣ Now set Stripe key from env
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';

  // 3️⃣ Configure status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 4️⃣ Initialize SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? saved = prefs.getString('saved_locale');

  Locale locale;
  if (saved != null && saved.contains('_')) {
    final parts = saved.split('_');
    locale = Locale(parts[0], parts[1]);
  } else {
    locale = const Locale('en', 'US');
  }

  // 5️⃣ Run app
  runApp(MyApp(initialLocale: locale));
}
class MyApp extends StatefulWidget {
  final Locale initialLocale;

  const MyApp({super.key, required this.initialLocale});

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  Future<void> changeLocale(Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'saved_locale', "${locale.languageCode}_${locale.countryCode}");

    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [...providers],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        title: 'StoraTax',
        debugShowCheckedModeBanner: false,
        locale: _locale,
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('fr', 'FR'),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
      ),
    );
  }
}
