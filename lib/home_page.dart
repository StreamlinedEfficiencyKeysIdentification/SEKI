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
          
        ],
        backgroundColor: Color(0xff035fab),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    // Adicione ação aqui
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
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
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
                              child: Icon(Icons.edit, color: Color(0xff035fab), size: 35,),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Ação para visualizar
                              },
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(30),
                              ),
                              child: Icon(Icons.visibility, color: Color(0xff035fab), size: 35,),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(30),
                              ),
                              child: Icon(Icons.add, color:Color(0xff035fab), size: 35,),
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
                    // Adicione ação aqui
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
                          'Usuário',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
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
                              child: Icon(Icons.edit, color: Color(0xff035fab), size: 35,),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Ação para visualizar
                              },
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(30),
                              ),
                              child: Icon(Icons.visibility, color: Color(0xff035fab), size: 35,),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(30),
                              ),
                              child: Icon(Icons.add, color:Color(0xff035fab), size: 35,),
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
                    // Adicione ação aqui
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
                          'Máquina',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
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
                              child: Icon(Icons.edit, color: Color(0xff035fab), size: 35,),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Ação para visualizar
                              },
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(30),
                              ),
                              child: Icon(Icons.visibility, color: Color(0xff035fab), size: 35,),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/group');
                              },
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(30),
                              ),
                              child: Icon(Icons.add, color:Color(0xff035fab), size: 35,),
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
                    // Adicione ação aqui
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
                          'Chamado',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
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
                              child: Icon(Icons.edit, color: Color(0xff035fab), size: 35,),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Ação para visualizar
                              },
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(30),
                              ),
                              child: Icon(Icons.visibility, color: Color(0xff035fab), size: 35,),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(30),
                              ),
                              child: Icon(Icons.add, color:Color(0xff035fab), size: 35,),
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
                    // Adicione ação aqui
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
                          'Cadastrar QRcode',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
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
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xff035fab),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ação do botão de contador
        },
        child: Icon(Icons.qr_code, color: Color(0xff035fab),),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      bottomNavigationBar: ClipRRect(
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(20.0),
    topRight: Radius.circular(20.0),
  ),
  child: BottomAppBar(
    color: Colors.white,
    elevation: 50,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.logout, color: Color(0xff035fab)),
          onPressed: () => _logout(context),
        ),
        IconButton(
          onPressed: () {
            // Adicione ação para o segundo ícone do menu footer
          },
          icon: Icon(Icons.home, color: Color(0xff035fab)),
        ),
        IconButton(
          onPressed: () {
            // Adicione ação para o terceiro ícone do menu footer
          },
          icon: Icon(Icons.people_alt, color: Color(0xff035fab)),
        ),
      ],
   ),
   ),
   ),
    );


  }
}
