import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  Future<String?> _getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usuarioLogado = prefs.getString('usuarioLogado');

    if (usuarioLogado != null) {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('Usuarios')
          .doc(usuarioLogado)
          .get();

      if (userDoc.exists) {
        String? userName = userDoc.data()?['Nome'];
        return userName;
      } else {
        print('Documento do usuário não encontrado no Firestore.');
        return null;
      }
    } else {
      return null;
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('usuarioLogado'); // Remova o UID do SharedPreferences

      await FirebaseAuth.instance.signOut();

      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      print('Erro ao fazer logout: $e');
    }
  }

 @override
Widget build(BuildContext context) {
  
  return Scaffold(
    appBar: AppBar(
      title: Text(''),
      actions: [
        IconButton(
  icon: Icon(Icons.logout, color: Colors.white),
  onPressed: () => _logout(context),
),
      ],
      backgroundColor: Color(0xff035fab),
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Alinhar o conteúdo à esquerda
      children: [
        FutureBuilder<String?>(
          future: _getUserName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Erro ao carregar o nome do usuário.'),
              );
            } else {
              String? userName = snapshot.data;
              return Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  userName != null
                      ? 'Bem-vindo,\n$userName!'
                      : 'Usuário desconhecido.',
                  // textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              );
            }
          },
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            children: [
              SizedBox(height: 20),
             ElevatedButton(
  onPressed: () {
  },
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(vertical: 20),
    backgroundColor: Color.fromRGBO(255, 255, 255, 0.4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: Colors.white),
    ),
  ),
    child: Padding(
    padding: const EdgeInsets.only(left: 20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    
    children: [
      Text(
        'Empresas',
        style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 255, 255, 255),),
      ),
      SizedBox(height: 20), 
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              // Ação para editar
            },
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(30),
            ),
            child: Icon(Icons.edit, color: Color(0xff035fab),),
          ),
          ElevatedButton(
            onPressed: () {
              // Ação para visualizar
            },
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(30),
            ),
            child: Icon(Icons.visibility, color: Color(0xff035fab),),
          ),
          ElevatedButton(
            onPressed: () {
    Navigator.pushNamed(context, '/register');
            },
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(30),
              
            ),
            child: Icon(Icons.add, color:Color(0xff035fab),),
          ),
        ],
      ),
    ],
  ),
),
             ),

              SizedBox(height: 10), 
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/hardware');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20),
               backgroundColor: Color.fromRGBO(255, 255, 255, 0.4), 
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), 
                    side: BorderSide(color: Colors.white),
                  ),
                ),
                child: Text(
                  'Registrar Novo hardware',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: 10), 
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/group');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20),
                   backgroundColor: Color.fromRGBO(255, 255, 255, 0.4), 
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), 
                    side: BorderSide(color: Colors.white),
                  ),
                ),
                child: Text(
                  'Registrar Novo Grupo',
                  style: TextStyle(fontSize: 16,color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    backgroundColor: Color(0xff035fab),
  );
}
}
