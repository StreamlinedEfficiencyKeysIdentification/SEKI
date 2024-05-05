import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'views/activites/goup_page.dart';
import 'views/activites/hardware_page.dart';
import 'views/activites/login_page.dart';
import 'views/activites/redefinir_senha.dart';
import 'views/activites/register_page.dart';
import 'views/activites/home_page.dart';
import 'views/activites/alterar_senha.dart';
import 'views/activites/checagem_page.dart';
import 'views/activites/scan_code.dart';
import 'views/activites/setor_page.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth = FirebaseAuth.instanceFor(app: app);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // ignore: use_super_parameters
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        // ignore: prefer_const_constructors
        '/': (context) => ChecagemPage(),
        '/login': (context) => LoginPage(),
        '/reset_password': (context) => const ResetPasswordPage(),
        '/register': (context) => const RegisterPage(),
        '/alterar_senha': (context) => FirstAccessPage(
            title: ModalRoute.of(context)!.settings.arguments as String),
        '/home': (context) => const HomePage(),
        '/hardware': (context) => const HardwarePage(),
        '/group': (context) => const GroupPage(),
        '/setor': (context) => const SetorPage(),
        '/scan': (context) => const ScanCodePage(),
      },
    );
  }
}
