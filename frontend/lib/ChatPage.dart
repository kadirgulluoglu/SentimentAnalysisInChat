import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nlpproje/Configuration.dart';
import 'package:nlpproje/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final storeMessage = FirebaseFirestore.instance;
  TextEditingController msg = TextEditingController();
  UserModel? userModel = UserModel();
  User? user = FirebaseAuth.instance.currentUser;
  String? mesaj = " ";
  String? genelduygu = " ";
  bool bosmu = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      getFirebase();
      duygugetir();
    });
    mesajlarigetir();
  }

  genelduygubosmu() {
    if (genelduygu.toString() != " ") {
      setState(() {
        bosmu = true;
      });
    } else {
      setState(() {
        bosmu = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    duygugetir();
    genelduygubosmu();
    return userModel!.name != null
        ? Scaffold(
            appBar: AppBar(
              titleSpacing: 0.0,
              backgroundColor: primaryColorr,
              title: Container(
                width: size.width,
                padding: EdgeInsets.all(8.0),
                color: primaryColorr,
                height: size.height * .08,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      child: Icon(
                        Icons.person,
                        color: Colors.black26,
                      ),
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(width: size.width * 0.02),
                    Text(
                      "Kadir Güllüoğlu",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(width: size.width * 0.02),
                    bosmu
                        ? Text("Genel Duygu:" + genelduygu.toString())
                        : Text(""),
                  ],
                ),
              ),
            ),
            backgroundColor: Colors.white,
            body: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/background.jpg"),
                      fit: BoxFit.cover)),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: ListView(
                    children: [
                      Container(
                          height: size.height * .8,
                          child: SingleChildScrollView(
                              reverse: true, child: ShowMessages())),
                      Container(
                        width: size.width,
                        padding: EdgeInsets.all(8.0),
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                width: size.width * .5,
                                height: size.height * .06,
                                child: TextField(
                                  controller: msg,
                                  decoration: InputDecoration(
                                    hintText: "Mesaj Girin",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: BorderSide(
                                          color: primaryColorr, width: 2),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: BorderSide(
                                          color: primaryColorr, width: 2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                                onPressed: () async {
                                  if (msg.text.isNotEmpty) {
                                    String? sentimentResult;
                                    String? genelResult;
                                    mesajlarigetir();
                                    final url =
                                        Uri.parse('http://10.0.2.2:5000/nlp');
                                    final responsepost = await http.post(url,
                                        body: json.encode(
                                            {'text': msg.text.toString()}));

                                    final responseget = await http.get(url);
                                    final decoded = jsonDecode(responseget.body)
                                        as Map<String, dynamic>;

                                    setState(() {
                                      sentimentResult = decoded['merhaba'];
                                    });
                                    final rpost = await http.post(url,
                                        body: json.encode({
                                          'text': mesaj.toString() +
                                              " " +
                                              msg.text.toString()
                                        }));
                                    final rget = await http.get(url);
                                    final d = jsonDecode(rget.body)
                                        as Map<String, dynamic>;
                                    setState(() {
                                      genelResult = d['merhaba'];
                                    });
                                    DateTime now = DateTime.now();
                                    String formattedTime =
                                        DateFormat.Hm().format(now);
                                    storeMessage
                                        .collection("Mesajlar")
                                        .doc()
                                        .set({
                                      "msg": msg.text.trim(),
                                      "user": userModel!.name,
                                      "saat": formattedTime,
                                      "time": DateTime.now(),
                                      "email": userModel!.email,
                                      "sentimentResult": sentimentResult,
                                      "genelResult": genelResult
                                    });

                                    msg.clear();
                                  }
                                },
                                icon: Icon(Icons.send, color: primaryColorr))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        : Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                  backgroundColor: Colors.white, color: primaryColorr),
            ),
          );
  }

  mesajlarigetir() async {
    setState(() {
      mesaj = "";
    });
    await FirebaseFirestore.instance
        .collection('Mesajlar')
        .orderBy("time")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        userModel!.email == doc["email"].toString()
            ? setState(() {
                mesaj = mesaj! + doc["msg"].toString() + " ";
              })
            : Text("");
      });
      setState(() {
        mesaj;
      });
    });
  }

  duygugetir() async {
    await FirebaseFirestore.instance
        .collection('Mesajlar')
        .orderBy("time")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        userModel!.email != doc["email"].toString()
            ? setState(() {
                genelduygu = doc["genelResult"].toString();
              })
            : Text("");
      });
      setState(() {
        genelduygu;
      });
    });
  }

  Future getFirebase() async {
    await FirebaseFirestore.instance
        .collection("person")
        .doc(user!.uid)
        .get()
        .then((value) => {
              this.userModel = UserModel.fromMap(value.data()),
              setState(() {}),
            });
  }

  Widget ShowMessages() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Mesajlar")
            .orderBy("time")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: primaryColorr,
              ),
            );
          }
          return ListView.builder(
              primary: true,
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, i) {
                QueryDocumentSnapshot x = snapshot.data!.docs[i];
                return ListTile(
                  title: Column(
                    crossAxisAlignment:
                        userModel!.email.toString() == x["email"].toString()
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: userModel!.email.toString() ==
                                    x["email"].toString()
                                ? primaryColorr.withOpacity(.5)
                                : Color(0xffAC7D88).withOpacity(.9),
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              x["msg"],
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            userModel!.email.toString() == x["email"].toString()
                                ? Text("")
                                : Text(x["sentimentResult"]),
                            Text(x['saat']),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }
}
