import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talento/Views/splash.dart';
import 'package:talento/Views/masterScreen.dart';
import 'package:talento/Views/onboarding.dart';
import 'package:talento/firebase_options.dart';
import 'package:talento/providers/userProvider.dart';
import 'package:timeago/timeago.dart' as timeago;

class CustomEnMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => 'from now';
  @override
  String lessThanOneMinute(int seconds) => 'just now';
  @override
  String aboutAMinute(int minutes) => '1 minute ago';
  @override
  String minutes(int minutes) => '$minutes minutes ago';
  @override
  String aboutAnHour(int minutes) => '1 hour ago';
  @override
  String hours(int hours) => '$hours hours ago';
  @override
  String aDay(int hours) => '1 day ago';
  @override
  String days(int days) => '$days days ago';
  @override
  String aboutAMonth(int days) => '1 month ago';
  @override
  String months(int months) => '$months months ago';
  @override
  String aboutAYear(int year) => '1 year ago';
  @override
  String years(int years) => '$years years ago';
  @override
  String wordSeparator() => ' ';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  timeago.setLocaleMessages('en', CustomEnMessages());
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        StreamProvider<User?>(
          create: (_) => FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'Talento',
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
