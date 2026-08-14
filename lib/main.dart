import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kutumba/models/album.dart';
import 'package:kutumba/pages/albums.dart';
import 'package:kutumba/pages/forgot_password.dart';
import 'package:kutumba/pages/home.dart';
import 'package:kutumba/pages/login.dart';
import 'package:kutumba/pages/notes.dart';
import 'package:kutumba/pages/payment.dart';
import 'package:kutumba/pages/playlist.dart';
import 'package:kutumba/pages/profile.dart';
import 'package:kutumba/pages/register.dart';
import 'package:kutumba/pages/video.dart';
import 'package:kutumba/pages/videos.dart';
import 'package:kutumba/providers/auth.dart';
import 'package:kutumba/providers/user_provider.dart';
import 'package:kutumba/services/push_nofitications.dart';
import 'package:kutumba/services/service_locator.dart';
import 'package:kutumba/wrapper.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'models/video.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await setupServiceLocator();

  // Initialize Firebase
  // await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize push notifications
  final PushNotificationsManager pushNotificationsManager =
      PushNotificationsManager();

  await pushNotificationsManager.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),
      ],
      child: OverlaySupport.global(
        child: MaterialApp(
          title: 'Kutumba',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: const Color.fromARGB(255, 251, 132, 35),
            brightness: Brightness.dark,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            primaryIconTheme: const IconThemeData(
              color: Colors.white,
            ),
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.orange,
              brightness: Brightness.dark,
            ).copyWith(
              secondary: const Color.fromARGB(255, 251, 132, 35),
            ),
          ),
          initialRoute: '/',
          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(
                  builder: (_) => Wrapper(),
                );

              case '/home':
                return MaterialPageRoute(
                  builder: (_) => const Home(),
                );

              case '/login':
                return MaterialPageRoute(
                  builder: (_) => const Login(),
                );

              case '/register':
                return MaterialPageRoute(
                  builder: (_) => const Register(),
                );

              case '/forgot-password':
                return MaterialPageRoute(
                  builder: (_) => const ForgotPassword(),
                );

              case '/albums':
                return MaterialPageRoute(
                  builder: (_) => const Albums(),
                );

              case '/albumDetail':
                final args = settings.arguments as Map<String, dynamic>?;
                if (args != null && args.containsKey('album')) {
                  return MaterialPageRoute(
                    builder: (_) => Playlist(args['album'] as Album),
                  );
                }

              case '/videos':
                return MaterialPageRoute(
                  builder: (_) => const Videos(),
                );

              case '/videoDetail':
                return MaterialPageRoute(
                  builder: (_) => VideoPage(settings.arguments as Video),
                );

              case '/notes':
                return MaterialPageRoute(
                  builder: (_) => const Notes(),
                );

              case '/profile':
                return MaterialPageRoute(
                  builder: (_) => const Profile(),
                );

              case '/payment':
                return MaterialPageRoute(
                  builder: (_) => Payment(settings.arguments as String),
                );

              default:
                return MaterialPageRoute(
                  builder: (_) => Wrapper(),
                );
            }
          },
        ),
      ),
    );
  }
}
