import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'views/screens/chamado/chamado.dart';
import 'views/screens/chamado/view_chamado.dart';
import 'views/screens/empresa/goup_page.dart';
import 'views/screens/equipamento/hardware_page.dart';
import 'views/screens/login_page.dart';
import 'views/screens/redefinir_senha.dart';
import 'views/screens/usuario/register_page.dart';
import 'views/screens/home_page.dart';
import 'views/screens/alterar_senha.dart';
import 'views/screens/checagem_page.dart';
import 'views/screens/barcode/scan_code.dart';
import 'views/screens/empresa/visualizar_empresas.dart';
import 'views/screens/equipamento/visualizar_equipamentos.dart';
import 'views/screens/usuario/visualizar_usuario.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;

class ConnectionNotifer extends InheritedNotifier<ValueNotifier<bool>> {
  const ConnectionNotifer({
    super.key,
    required super.notifier,
    required super.child,
  });

  static ValueNotifier<bool> of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ConnectionNotifer>()!
        .notifier!;
  }
}

final internetConnectionChecker = InternetConnection.createInstance(
  checkInterval: const Duration(seconds: 1),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth = FirebaseAuth.instanceFor(app: app);

  final hasConnection = await internetConnectionChecker.hasInternetAccess;
  runApp(
    ConnectionNotifer(
      notifier: ValueNotifier(hasConnection),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  // ignore: use_super_parameters
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StreamSubscription<InternetStatus> listener;

  @override
  void initState() {
    super.initState();
    listener = internetConnectionChecker.onStatusChange.listen(
      (status) {
        final notifier = ConnectionNotifer.of(context);
        notifier.value = status == InternetStatus.connected ? true : false;
      },
    );
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

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
        '/view_equipamentos': (context) => const VisualizarEquipamentos(),
        '/group': (context) => const GroupPage(),
        '/view_empresas': (context) => const VisualizarEmpresas(),
        '/scan': (context) => const BarcodeScannerWithController(
              returnImmediately: false,
            ),
        '/chamado': (context) => const Chamado(
              qrcode: '',
            ),
        '/view_chamados': (context) => const ViewChamados(),
      },
    );
  }
}
