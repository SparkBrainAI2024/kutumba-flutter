import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kutumba/pages/forgot_password.dart';
import 'package:kutumba/pages/login.dart';
import 'package:kutumba/pages/notes.dart';
import 'package:kutumba/pages/playlist.dart';
import 'package:kutumba/pages/register.dart';
import 'package:kutumba/pages/video.dart';
import 'package:kutumba/providers/auth.dart';
import 'package:kutumba/providers/user_provider.dart';
import 'package:kutumba/services/service_locator.dart';
import 'package:kutumba/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:kutumba/services/push_nofitications.dart';

import './pages/home.dart';
import './pages/albums.dart';
import './pages/videos.dart';
import './pages/profile.dart';
import './pages/payment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  await Firebase.initializeApp();

  PushNotificationsManager pushNotificationsManager =
      PushNotificationsManager();
  await pushNotificationsManager.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: OverlaySupport.global(
        child: MaterialApp(
          title: 'Kutumba',
          theme: ThemeData(
            primaryColor: const Color.fromARGB(255, 251, 132, 35),
            brightness: Brightness.dark,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            primaryIconTheme: const IconThemeData(color: Colors.white),
            colorScheme: ColorScheme.fromSwatch(
                    primarySwatch: Colors.orange, brightness: Brightness.dark)
                .copyWith(secondary: const Color.fromARGB(255, 251, 132, 35)),
          ),
          initialRoute: '/',
          onGenerateRoute: (RouteSettings settings) {
            var routes = <String, WidgetBuilder>{
              // '/': (context)=>Home(),
              '/': (context) => const Wrapper(),
              '/home': (context) => const Home(),
              '/login': (context) => const Login(),
              '/register': (context) => const Register(),
              '/forgot-password': (context) => const ForgotPassword(),
              '/albums': (context) => const Albums(),
              // '/albumDetail': (context) => AlbumDetail(),
              '/albumDetail': (context) => Playlist(settings.arguments),

              '/videos': (context) => const Videos(),
              '/videoDetail': (context) => VideoPage(settings.arguments),
              '/notes': (context) => const Notes(),
              '/profile': (context) => const Profile(),
              '/payment': (context) => Payment(settings.arguments),
            };
            WidgetBuilder builder = routes[settings.name];
            return MaterialPageRoute(builder: (ctx) => builder(ctx));
          },
        ),
      ),
    );
  }
}
