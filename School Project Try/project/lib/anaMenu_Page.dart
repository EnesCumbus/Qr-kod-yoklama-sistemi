import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/login.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:intl/intl.dart';

class QrCode {
  String codeName;
  QrCode(this.codeName);
}

class AnaMenuPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  AnaMenuPage({required this.userData});

  @override
  State<AnaMenuPage> createState() => _QrMenuPageState();
}

class _QrMenuPageState extends State<AnaMenuPage> {
  int currentIndex = 0;
  bool isScanning = false; // Yeni eklenen değişken
  bool isCodeSent = false;

///////////////////////////////////////////////////////////////////////////////////////////////////

  void goToPage(index) {
    setState(() {
      currentIndex = index;
    });
  }

  List<Widget> _pages = [/*QrPage(userData: widget.userData,), HistoryPage()*/];

  @override
  void initState() {
    //_initializeCamera();
    // _qrKey = GlobalKey();

    super.initState();
    _pages = [QrPage(userData: widget.userData), HistoryPage()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[currentIndex],
      bottomNavigationBar: BottomNavyBar(
        containerHeight: 70,
        mainAxisAlignment: MainAxisAlignment.center,
        selectedIndex: currentIndex,
        onItemSelected: (index) => goToPage(index),
        items: [
          BottomNavyBarItem(
              icon: Icon(Icons.qr_code),
              title: Text('QR'),
              activeColor: Color.fromARGB(255, 33, 80, 122)),
          BottomNavyBarItem(
              icon: Icon(Icons.history),
              title: Text('Geçmiş'),
              activeColor: const Color.fromARGB(255, 33, 80, 122)),
        ],
      ),
    );
  }
}

class QrPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  QrPage({required this.userData});

  Future<void> processQRCode(String codeName) async {
    // QR kodu ile ilgili işlemleri gerçekleştir (veritabanına ekleme vb.).
    CollectionReference qrCodes =
        FirebaseFirestore.instance.collection('qr_codes');
    await qrCodes.add({
      'codeName': codeName,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 15,
              child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/SSS");
                },
                icon: Icon(
                  Icons.question_mark,
                  size: 15,
                ),
              ),
            ),
            SizedBox(
              width: 12,
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HesapPage(userData: userData),
                  ),
                );
              },
              icon: Icon(Icons.person),
            )
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: Container(
              width: 380,
              height: 94,
              child: Column(
                children: [
                  Text(
                    userData['adı'],
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  Text(
                    userData['bölümü'],
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 380,
            height: 140,
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) => Column(
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 10),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Container(
                        child: Text(
                          "QR KODU OKUTUN",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Container(
                        child: Text(
                          "Qr kodunu belirlenen alana ortalayacak şekilde hizalayın.",
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),

                    /*
                    Expanded(
                      child: QRView(
                        key: GlobalKey(),
                        onQRViewCreated: (controller) {
                          // Burada QR kodu tarandığında gerçekleştirilecek işlemleri tanımlayabilirsiniz.
                          // Örneğin, taranan QR kodunun içeriğini alabilirsiniz.

                          controller.scannedDataStream.listen((scanData) async {
                            String codeName =
                                scanData.code ?? "Bilinmeyen QR Kodu";
                            print("Taranan QR Kodu: $codeName");
                            CollectionReference qrCodes = FirebaseFirestore
                                .instance
                                .collection('qr_codes');
                            await qrCodes.add({
                              'codeName': codeName,
                              'timestamp': FieldValue.serverTimestamp(),
                            });

                            //  QrCode qrCode = QrCode(codeName);
                            // Burada yapılmak istenen işlemleri gerçekleştirebilirsiniz.
                            // Örneğin, taranan QR koduna bağlı olarak bir sayfaya yönlendirme yapabilirsiniz.
                          });
                        },
                      ),

                    ),


*/

                    Expanded(
                      child: QRView(
                        key: GlobalKey(),
                        onQRViewCreated: (controller) {
                          controller.scannedDataStream.listen((scanData) async {
                            String codeName =
                                scanData.code ?? "Bilinmeyen QR Kodu";
                            print("Taranan QR Kodu: $codeName");
                            await processQRCode(codeName);

                            // Anasayfaya yönlendirme
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AnaMenuPage(userData: userData),
                              ),
                            );
                          });
                        },
                      ),
                    )
                  ],
                ),
              );
            },
            icon: Icon(
              Icons.qr_code_scanner_outlined,
              color: Color.fromARGB(255, 28, 70, 104),

              // size: 180,
            ),
            iconSize: 180,
          ),
          //bursayı projeden sonra yaptım
          Text(
            "Okutmak için tıklayın",
            style: TextStyle(
                color: const Color.fromARGB(255, 28, 70, 104),
                fontSize: 17,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }
}
/*
class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: AppBar(
          actions: [
            Row(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.view_sidebar_rounded,
                      size: 30,
                    )),
                SizedBox(
                  width: 296,
                ),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.delete,
                      size: 30,
                    ))
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: Container(
              width: 380,
              height: 94,
              child: Column(
                children: [
                  SizedBox(
                    height: 47,
                  ),
                  Text(
                    "Geçmiş",
                    style: TextStyle(fontSize: 29, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
*/
/*
class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: AppBar(
          actions: [
            Row(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.view_sidebar_rounded,
                      size: 30,
                    )),
                SizedBox(
                  width: 296,
                ),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.delete,
                      size: 30,
                    ))
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: Container(
              width: 380,
              height: 94,
              child: Column(
                children: [
                  SizedBox(
                    height: 47,
                  ),
                  Text(
                    "Geçmiş",
                    style: TextStyle(fontSize: 29, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: _buildHistoryList(),
    );
  }

  Widget _buildHistoryList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('qr_codes').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<Widget> qrCodeList = [];

        snapshot.data!.docs.forEach((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;

          String codeName = data['codeName'] ?? 'Bilinmeyen QR Kodu';
          Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
          DateTime date = timestamp.toDate();

          qrCodeList.add(
            ListTile(
              title: Text(codeName),
              subtitle: Text('Tarih: ${date.day}/${date.month}/${date.year}'),
            ),
          );
        });

        return ListView(
          children: qrCodeList,
        );
      },
    );
  }
}

*/

/*
class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: AppBar(
          actions: [
            Row(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.view_sidebar_rounded,
                      size: 30,
                    )),
                SizedBox(
                  width: 296,
                ),
                IconButton(
                    onPressed: () {
                      _clearHistory();
                    },
                    icon: Icon(
                      Icons.delete,
                      size: 30,
                    ))
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: Container(
              width: 380,
              height: 94,
              child: Column(
                children: [
                  SizedBox(
                    height: 47,
                  ),
                  Text(
                    "Geçmiş",
                    style: TextStyle(fontSize: 29, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: _buildHistoryList(),
    );
  }

  Widget _buildHistoryList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('qr_codes').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<Widget> qrCodeList = [];

        snapshot.data!.docs.forEach((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;

          String codeName = data['codeName'] ?? 'Bilinmeyen QR Kodu';
          Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
          DateTime date = timestamp.toDate();

          qrCodeList.add(
            ListTile(
              title: Text(codeName),
              subtitle: Text('Tarih: ${date.day}/${date.month}/${date.year}'),
            ),
          );
        });

        return ListView(
          children: qrCodeList,
        );
      },
    );
  }

  void _clearHistory() {
    FirebaseFirestore.instance
        .collection('qr_codes')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        document.reference.delete();
      });
    });
  }
}

*/

//bu en son ve güzel olan kod

/*

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: AppBar(
          actions: [
            Row(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.view_sidebar_rounded,
                      size: 30,
                    )),
                SizedBox(
                  width: 296,
                ),
                IconButton(
                    onPressed: () {
                      _showConfirmationDialog();
                    },
                    icon: Icon(
                      Icons.delete,
                      size: 30,
                    ))
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: Container(
              width: 380,
              height: 94,
              child: Column(
                children: [
                  SizedBox(
                    height: 47,
                  ),
                  Text(
                    "Geçmiş",
                    style: TextStyle(fontSize: 29, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: _buildHistoryList(),
    );
  }

  Widget _buildHistoryList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('qr_codes').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<Widget> qrCodeList = [];

        snapshot.data!.docs.forEach((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;

          String codeName = data['codeName'] ?? 'Bilinmeyen QR Kodu';
          Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
          DateTime date = timestamp.toDate();

          // URL'yi parse et
          Uri uri = Uri.parse(codeName);

          // Ana ismi al
          String host = uri.host ?? 'Bilinmeyen Site';

          qrCodeList.add(
            ListTile(
              title: Text(host),
              subtitle: Text('Tarih: ${date.day}/${date.month}/${date.year}'),
            ),
          );
        });

        return ListView(
          children: qrCodeList,
        );
      },
    );
  }

  void _clearHistory() {
    FirebaseFirestore.instance
        .collection('qr_codes')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        document.reference.delete();
      });
    });
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // dialog dışına tıklanarak kapatılmasın
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bilgilendirme'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Ders geçmişinizi silmek istediğinize emin misiniz?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Vazgeç'),
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
              },
            ),
            TextButton(
              child: Text('Sil'),
              onPressed: () {
                _clearHistory();
                Navigator.of(context).pop(); // Dialog'u kapat
              },
            ),
          ],
        );
      },
    );
  }
}


/*

Zmana göre düzenleme yapan kod 




import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: AppBar(
          actions: [
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.view_sidebar_rounded,
                    size: 30,
                  ),
                ),
                SizedBox(
                  width: 296,
                ),
                IconButton(
                  onPressed: () {
                    _showConfirmationDialog();
                  },
                  icon: Icon(
                    Icons.delete,
                    size: 30,
                  ),
                )
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: Container(
              width: 380,
              height: 94,
              child: Column(
                children: [
                  SizedBox(
                    height: 47,
                  ),
                  Text(
                    "Geçmiş",
                    style: TextStyle(fontSize: 29, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: _buildHistoryList(),
    );
  }

  Widget _buildHistoryList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('qr_codes').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<Map<String, dynamic>> qrCodeList = [];

        snapshot.data!.docs.forEach((DocumentSnapshot document) {
          Map<String, dynamic> data =
              document.data() as Map<String, dynamic>;

          String codeName = data['codeName'] ?? 'Bilinmeyen QR Kodu';
          Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
          DateTime date = timestamp.toDate();

          // Saati ve dakikayı al
          String formattedTime = DateFormat.Hm().format(date);

          // URL'yi parse et
          Uri uri = Uri.parse(codeName);

          // Ana ismi al
          String host = uri.host ?? 'Bilinmeyen Site';

          qrCodeList.add({
            'host': host,
            'formattedTime': formattedTime,
            'date': date,
          });
        });

        // Sıralama işlemi burada yapılır
        qrCodeList.sort((a, b) {
          DateTime dateA = a['date'];
          DateTime dateB = b['date'];
          return dateB.compareTo(dateA);
        });

        return ListView.builder(
          itemCount: qrCodeList.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> data = qrCodeList[index];

            return ListTile(
              title: Text(data['host']),
              subtitle: Text('Tarih: ${data['date'].day}/${data['date'].month}/${data['date'].year} - Saat: ${data['formattedTime']}'),
            );
          },
        );
      },
    );
  }

  void _clearHistory() {
    FirebaseFirestore.instance
        .collection('qr_codes')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        document.reference.delete();
      });
    });
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bilgilendirme'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Ders geçmişinizi silmek istediğinize emin misiniz?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Vazgeç'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Sil'),
              onPressed: () {
                _clearHistory();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}


*/





*/

//en son kod buydu hata aldığı için değişiyorum şimdilik

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: AppBar(
          actions: [
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.view_sidebar_rounded,
                    size: 30,
                  ),
                ),
                SizedBox(
                  width: 296,
                ),
                IconButton(
                  onPressed: () {
                    _showConfirmationDialog();
                  },
                  icon: Icon(
                    Icons.delete,
                    size: 30,
                  ),
                )
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: Container(
              width: 380,
              height: 94,
              child: Column(
                children: [
                  SizedBox(
                    height: 47,
                  ),
                  Text(
                    "Geçmiş",
                    style: TextStyle(fontSize: 29, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: _buildHistoryList(),
    );
  }

  Widget _buildHistoryList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('qr_codes').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<Widget> qrCodeList = [];

        snapshot.data!.docs.forEach((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;

          String codeName = data['codeName'] ?? 'Bilinmeyen QR Kodu';
          Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
          DateTime date = timestamp.toDate();

          // Saati ve dakikayı al
          String formattedTime = DateFormat.Hm().format(date);

          // URL'yi parse et
          Uri uri = Uri.parse(codeName);

          // Ana ismi al
          String host = uri.host ?? 'Bilinmeyen Site';

          qrCodeList.add(
            ListTile(
              title: Text(host),
              subtitle: Text(
                  'Tarih: ${date.day}/${date.month}/${date.year} - Saat: $formattedTime'),
            ),
          );
        });

        return ListView(
          children: qrCodeList,
        );
      },
    );
  }

  void _clearHistory() {
    FirebaseFirestore.instance
        .collection('qr_codes')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        document.reference.delete();
      });
    });
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bilgilendirme'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Ders geçmişinizi silmek istediğinize emin misiniz?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Vazgeç'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Sil'),
              onPressed: () {
                _clearHistory();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

/*
class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: AppBar(
          actions: [
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.view_sidebar_rounded,
                    size: 30,
                  ),
                ),
                SizedBox(
                  width: 296,
                ),
                IconButton(
                  onPressed: () {
                    _showConfirmationDialog();
                  },
                  icon: Icon(
                    Icons.delete,
                    size: 30,
                  ),
                ),
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: Container(
              width: 380,
              height: 94,
              child: Column(
                children: [
                  SizedBox(
                    height: 47,
                  ),
                  Text(
                    "Geçmiş",
                    style: TextStyle(fontSize: 29, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _buildHistoryList(),
    );
  }

  Widget _buildHistoryList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('qr_codes').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<Widget> qrCodeList = [];

        snapshot.data!.docs.forEach((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;

          String codeName = data['codeName'] ?? 'Bilinmeyen QR Kodu';
          Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
          DateTime date = timestamp.toDate();

          // URL'yi parse et
          Uri uri = Uri.parse(codeName);

          // Ana ismi al
          String host = uri.host ?? 'Bilinmeyen Site';

          // Uzantı ve önekleri temizle
          host = host.replaceAll(RegExp(r'(^www\.|\.com$|\.org$|\.tr$)'), '');

          qrCodeList.add(
            ListTile(
              title: Text(host),
              subtitle: Text('Tarih: ${date.day}/${date.month}/${date.year}'),
            ),
          );
        });

        return ListView(
          children: qrCodeList,
        );
      },
    );
  }

  void _clearHistory() {
    FirebaseFirestore.instance
        .collection('qr_codes')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        document.reference.delete();
      });
    });
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bilgilendirme'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Ders geçmişinizi silmek istediğinize emin misiniz?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Vazgeç'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Sil'),
              onPressed: () {
                _clearHistory();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

*/

/*
class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<String> addedCodes = []; // Eklenen QR kodlarını kontrol etmek için liste

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: AppBar(
          actions: [
            Row(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.view_sidebar_rounded,
                      size: 30,
                    )),
                SizedBox(
                  width: 296,
                ),
                IconButton(
                    onPressed: () {
                      _showConfirmationDialog();
                    },
                    icon: Icon(
                      Icons.delete,
                      size: 30,
                    ))
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: Container(
              width: 380,
              height: 94,
              child: Column(
                children: [
                  SizedBox(
                    height: 47,
                  ),
                  Text(
                    "Geçmiş",
                    style: TextStyle(fontSize: 29, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: _buildHistoryList(),
    );
  }

  Widget _buildHistoryList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('qr_codes').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<Widget> qrCodeList = [];

        snapshot.data!.docs.forEach((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;

          String codeName = data['codeName'] ?? 'Bilinmeyen QR Kodu';
          Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
          DateTime date = timestamp.toDate();

          // Eğer bu QR kodu daha önce eklenmediyse ve listeye eklenmişse
          if (!addedCodes.contains(codeName)) {
            qrCodeList.add(
              ListTile(
                title: Text(codeName),
                subtitle: Text('Tarih: ${date.day}/${date.month}/${date.year}'),
              ),
            );
            addedCodes.add(codeName); // Eklenenleri listeye ekle
          }
        });

        return ListView(
          children: qrCodeList,
        );
      },
    );
  }

  void _clearHistory() {
    FirebaseFirestore.instance
        .collection('qr_codes')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        document.reference.delete();
      });
    });

    addedCodes.clear(); // Listeyi temizle
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // dialog dışına tıklanarak kapatılmasın
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ders Geçmişinizi Sil'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Ders geçmişinizi silmek istediğinize emin misiniz?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Vazgeç'),
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
              },
            ),
            TextButton(
              child: Text('Sil'),
              onPressed: () {
                _clearHistory();
                Navigator.of(context).pop(); // Dialog'u kapat
              },
            ),
          ],
        );
      },
    );
  }
}
*/
class HesapPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  HesapPage({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 80,
          title: Row(
            children: [
              SizedBox(
                width: 90,
              ),
              Text("HESAP")
            ],
          )),
      body: Column(
        children: [
          SizedBox(
            height: 24,
          ),
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Ad",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Spacer(), // Ekranın geri kalanını kaplamak için Spacer ekledik
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  userData['ad'],
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
          SizedBox(
            height: 42,
          ),
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Soyad",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Spacer(), // Ekranın geri kalanını kaplamak için Spacer ekledik
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  userData['soyad'],
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
          SizedBox(
            height: 42,
          ),
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Fakülte",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Spacer(), // Ekranın geri kalanını kaplamak için Spacer ekledik
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  userData['fakülte'],
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
          SizedBox(
            height: 40,
          ),
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Bölüm",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Spacer(), // Ekranın geri kalanını kaplamak için Spacer ekledik
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  userData['bölümü'],
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          LoginPage(),
                    ));
              },
              child: Text("Çıkış Yap")),
        ],
      ),
    );
  }
}
