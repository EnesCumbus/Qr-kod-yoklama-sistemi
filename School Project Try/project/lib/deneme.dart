import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage1 extends StatefulWidget {
  const LoginPage1({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage1> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> signIn() async {
    try {
      QuerySnapshot users = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: usernameController.text)
          .where('password', isEqualTo: passwordController.text)
          .get();

      if (users.docs.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              userData: users.docs[0].data() as Map<String, dynamic>,
            ),
          ),
        );
      } else {
        print("Kullanıcı bulunamadı");
      }
    } catch (e) {
      print("Giriş Hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Kullanıcı adı zorunlu';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Şifre zorunlu';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      signIn();
                    }
                  },
                  child: Text("Giriş yap"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final Map<String, dynamic> userData;

  HomePage({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Hoş geldiniz, ${userData['adı']}"),
            Text("Bölüm: ${userData['department']}"),
          ],
        ),
      ),
    );
  }
}
