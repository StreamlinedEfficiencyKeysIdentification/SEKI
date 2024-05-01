import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'code_scanner.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'goup_page.dart';
import 'hardware_page.dart';
import 'login_page.dart';
import 'redefinir_senha.dart';
import 'register_page.dart';
import 'home_page.dart';
import 'alterar_senha.dart';
import 'checagem_page.dart';
import 'setor_page.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //serve pra iniciar somente depois que as configurações flutter forem iniciadas

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
