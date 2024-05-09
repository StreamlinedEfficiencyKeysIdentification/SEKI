import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'views/screens/goup_page.dart';
import 'views/screens/hardware_page.dart';
import 'views/screens/login_page.dart';
import 'views/screens/redefinir_senha.dart';
import 'views/screens/register_page.dart';
import 'views/screens/home_page.dart';
import 'views/screens/alterar_senha.dart';
import 'views/screens/checagem_page.dart';
import 'views/screens/scan_code.dart';
import 'views/screens/visualizar_empresas.dart';
import 'views/screens/visualizar_usuario.dart';

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
        '/view_usuarios': (context) => const VisualizarUsuarios(),
        '/alterar_senha': (context) => FirstAccessPage(
            title: ModalRoute.of(context)!.settings.arguments as String),
        '/home': (context) => const HomePage(),
        '/hardware': (context) => const HardwarePage(),
        '/group': (context) => const GroupPage(),
        '/view_empresas': (context) => const VisualizarEmpresas(),
        '/scan': (context) => const ScanCodePage(),
      },
    );
  }
}
