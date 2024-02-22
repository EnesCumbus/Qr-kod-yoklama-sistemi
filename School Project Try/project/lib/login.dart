import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/anaMenu_Page.dart';
import 'package:url_launcher/link.dart';

class LoginPage extends StatefulWidget {
  //const LoginPage({super.key});
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final username = TextEditingController();
  final password = TextEditingController();

  final formkey = GlobalKey<FormState>();

  String ogrenci_durumu = "Öğrenci";

  String akademisyen_durumu = "Akademisyen";

  String son_durum = "Öğrenci";

  String son_durum_email = "@st.biruni.edu.tr";

  String ogrenciKontrol(son_durum) {
    if (son_durum == "Öğrenci") {
      son_durum_email = "@st.biruni.edu.tr";
      return son_durum_email;
    } else {
      son_durum_email = "@biruni.edu.tr";
      return son_durum_email;
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signIn() async {
    try {
      QuerySnapshot users = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: username.text + son_durum_email)
          .where('password', isEqualTo: password.text)
          .get();

      if (users.docs.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AnaMenuPage(
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
        automaticallyImplyLeading: false,
        title: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.all(0),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: Icon(
                          Icons.question_mark_rounded,
                          size: 15,
                        ),
                        color: Colors.black,
                        onPressed: () {
                          Navigator.pushNamed(context, "/SSS");
                          // Butona tıklanınca yapılacak işlemler
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                "Biruni Üniversitesi",
                style: TextStyle(fontSize: 25),
              ),
              SizedBox(
                height: 10,
              ),
              Text("Yoklama Sistemi")
            ],
          ),
        ),

        toolbarHeight: 150, // İstenilen yüksekliği ayarlayın
        // Diğer AppBar özellikleri buraya eklenebilir
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: formkey,
            child: Column(
              children: [
                SizedBox(
                  height: 13,
                ),
                Image.asset(
                  'assets/images/biruni.jpg',
                  width: 170,
                  height: 150,
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: 360,
                  height: 50,

                  //username field
                  child: TextFormField(
                    controller: username,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Kullanıcı Adı zorunludur";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        suffixText: ogrenciKontrol(son_durum),
                        hintText: 'Kullanıcı Adı',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4))),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: 360,
                  height: 50,

                  //password field
                  child: TextFormField(
                    controller: password,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Şifre zorunludur";
                      }
                      return null;
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                        hintText: 'Şifre',
                        prefixIcon: Icon(Icons.password),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4))),
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 19,
                    ),
                    Container(
                      width: 350,
                      height: 50,
                      child: PopupMenuButton(
                        offset: const Offset(10, 0), // Sağa çıkan menu,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Text(ogrenci_durumu),
                            value: ogrenci_durumu,
                          ),
                          PopupMenuItem(
                            child: Text(akademisyen_durumu),
                            value: akademisyen_durumu,
                          ),
                        ],
                        onSelected: (String newValue) {
                          setState(() {
                            son_durum = newValue;
                          });
                        },
                        child: Row(children: [
                          SizedBox(
                            width: 236,
                          ),
                          Text(
                            son_durum,
                            style: TextStyle(
                                fontSize:
                                    son_durum == akademisyen_durumu ? 14 : 16),
                          ),
                          SizedBox(
                            width: son_durum == akademisyen_durumu ? 5 : 35,
                          ),
                          Icon(
                            Icons.school_outlined,
                            color: Color.fromARGB(255, 30, 72, 106),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: ElevatedButton(
                      onPressed: () {
                        if (formkey.currentState!.validate()) {
                          //method buraya yazılıcak.
                          signIn();
                        }
                      },
                      child: Text("Giriş yap")),
                  width: 360,
                  height: 40,
                ),
                SizedBox(
                  height: 18,
                ),
                Row(children: [
                  SizedBox(
                    width: 250,
                  ),
                  Link(
                    uri: Uri.parse('https://sifre.biruni.edu.tr'),
                    builder: (context, followLink) => GestureDetector(
                      onTap: followLink,
                      child: Text(
                        'Parolamı Unuttum',
                        style: TextStyle(color: Colors.blue, fontSize: 15),
                      ),
                    ),
                  ),
                ]),
                SizedBox(
                  height: 20,
                ),
                Row(children: [
                  SizedBox(
                    width: 291,
                  ),
                  Link(
                    uri: Uri.parse('https://ders.biruni.edu.tr'),
                    builder: (context, followLink) => GestureDetector(
                      onTap: followLink,
                      child: Text('Cihaz Sıfırla',
                          style: TextStyle(color: Colors.blue, fontSize: 15)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SSS extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        //automaticallyImplyLeading: false,
        title: Row(children: [
          SizedBox(width: 100),
          Text(
            "SSS",
            style: TextStyle(fontSize: 24),
          )
        ]),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 18,
          ),
          Row(
            children: [
              SizedBox(
                width: 12,
              ),
              Icon(
                Icons.info,
                size: 35,
                color: Colors.grey,
              ),
              SizedBox(
                width: 28,
              ),
              Container(
                  width: 290,
                  height: 60,
                  child: Column(
                    children: [
                      Text(
                        "Cihaz bilgisini kaç kere sıfırlayabilirim?",
                        style: TextStyle(fontSize: 17),
                      ),
                      Text(
                        "Cihaz bilgisini sıfırlama işlemini haftada bir kez yapabilirsiniz.",
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      )
                    ],
                  )),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              SizedBox(
                width: 12,
              ),
              Icon(
                Icons.info,
                size: 35,
                color: Colors.grey,
              ),
              SizedBox(
                width: 28,
              ),
              Container(
                  width: 290,
                  height: 100,
                  child: Column(
                    children: [
                      Text(
                        "Neden cihaz eşleştirme hatası alıyorum?",
                        style: TextStyle(fontSize: 17),
                      ),
                      Text(
                        "Uygulamayı silip tekrar yüklemeniz veya başka cihazdan girmeniz halinde cihaz eşleştirme hatası alırsınız.",
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      )
                    ],
                  )),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              SizedBox(
                width: 12,
              ),
              Icon(
                Icons.info,
                size: 35,
                color: Colors.grey,
              ),
              SizedBox(
                width: 28,
              ),
              Container(
                  width: 304,
                  height: 100,
                  child: Column(
                    children: [
                      Text(
                        "Bilgilerim doğru olmasına rağmen neden giriş yapamıyorum?",
                        style: TextStyle(fontSize: 17),
                      ),
                      Text(
                        "Giriş ekranında öğrenciyseniz 'Öğrenci', akademisyen iseniz 'Akademisyen' seçeneğini seçtiğinizden emin olun.",
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      )
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
