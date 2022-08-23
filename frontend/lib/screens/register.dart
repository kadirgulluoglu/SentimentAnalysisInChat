import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/user_model.dart';
import '../theme/colors.dart';
import 'login.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //formkey

  final _formkey = GlobalKey<FormState>();

  //textcontrolller
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final TextEditingController passwordagaincontroller = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool isObscure = true;
  bool isLoading = false;

  bool isVisible = false;

  Widget buildAd() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ad Soyad',
          style: TextStyle(
            color: primaryColorr,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: primaryColorr,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                )
              ]),
          height: 60,
          child: TextFormField(
            validator: (value) {
              RegExp regexp = RegExp(r'^.{6,}$');
              if (value!.isEmpty) {
                return "Ad Boş girilemez";
              }
              if (!regexp.hasMatch(value)) {
                return "Hatalı Ad Soyad";
              }
              return null;
            },
            controller: namecontroller,
            keyboardType: TextInputType.text,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(top: 15),
                prefixIcon:
                    const Icon(Icons.account_circle, color: Colors.white),
                hintText: "Ad Soyad",
                hintStyle:
                    TextStyle(color: Theme.of(context).secondaryHeaderColor)),
          ),
        )
      ],
    );
  }

  Widget buildEposta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'E-Posta',
          style: TextStyle(
            color: primaryColorr,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: primaryColorr,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                )
              ]),
          height: 60,
          child: TextFormField(
            validator: (value) {
              if (value!.isEmpty) {
                return "Mail Boş girilemez";
              }
              if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                  .hasMatch(value)) {
                return "Hatalı Mail girdiniz";
              }
              return null;
            },
            onSaved: (value) {
              emailcontroller.text = value!;
            },
            controller: emailcontroller,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 15),
              prefixIcon: const Icon(Icons.email, color: Colors.white),
              hintText: "Eposta",
              hintStyle:
                  TextStyle(color: Theme.of(context).secondaryHeaderColor),
            ),
          ),
        )
      ],
    );
  }

  Widget buildSifre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Şifre',
          style: TextStyle(
            color: primaryColorr,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: primaryColorr,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                )
              ]),
          height: 60,
          child: TextFormField(
            validator: (value) {
              RegExp regexp = RegExp(r'^.{6,}$');
              if (value!.isEmpty) {
                return "Şifre Boş girilemez";
              }
              if (!regexp.hasMatch(value)) {
                return "Hatalı Şifre Girdiniz";
              }
              return null;
            },
            onSaved: (value) {
              passwordcontroller.text = value!;
            },
            controller: passwordcontroller,
            keyboardType: TextInputType.visiblePassword,
            obscureText: isObscure,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(top: 15),
                prefixIcon: const Icon(Icons.lock, color: Colors.white),
                hintText: "Şifre",
                hintStyle:
                    TextStyle(color: Theme.of(context).secondaryHeaderColor)),
          ),
        )
      ],
    );
  }

  Widget buildYeniSifre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Şifre Tekrar',
          style: TextStyle(
            color: primaryColorr,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: primaryColorr,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                )
              ]),
          height: 60,
          child: TextFormField(
            validator: (value) {
              if (passwordcontroller.text != passwordagaincontroller.text) {
                return "Şifreler Eşleşmiyor";
              }
              return null;
            },
            onSaved: (value) {
              passwordagaincontroller.text = value!;
            },
            controller: passwordagaincontroller,
            keyboardType: TextInputType.visiblePassword,
            obscureText: isObscure,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(top: 15),
                prefixIcon: const Icon(Icons.lock, color: Colors.white),
                hintText: "Şifre Tekrar",
                hintStyle: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                )),
          ),
        )
      ],
    );
  }

  Widget buildSignupButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5,
          primary: primaryColorr,
          padding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text('Kayıt Ol',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          signUp(emailcontroller.text, passwordcontroller.text);
        },
      ),
    );
  }

  Widget buildSignInbuton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Login()));
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "Hesabınız var mı ? ",
              style: TextStyle(
                  color: primaryColorr,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            TextSpan(
                text: "GİRİŞ YAP",
                style: TextStyle(
                  fontSize: 18,
                  color: primaryColorr,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: GestureDetector(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white],
                ),
              ),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.07,
                  vertical: size.height * 0.14,
                ),
                child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: size.width * 0.6,
                        child: FittedBox(
                          child: Text(
                            'KAYIT OL',
                            style: TextStyle(
                                color: primaryColorr,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      buildAd(),
                      SizedBox(height: size.height * 0.02),
                      buildEposta(),
                      SizedBox(height: size.height * 0.02),
                      buildSifre(),
                      SizedBox(height: size.height * 0.02),
                      buildYeniSifre(),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      const SizedBox(height: 20),
                      isLoading
                          ? Container(
                              padding: const EdgeInsets.symmetric(vertical: 25),
                              child: CircularProgressIndicator(
                                color: primaryColorr,
                              ),
                            )
                          : buildSignupButton(),
                      buildSignInbuton(),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void signUp(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then(
            (value) => {
              postDetailsToFirestore(),
            },
          )
          .catchError((e) {
        Fluttertoast.showToast(
            msg:
                "Daha Önceden Bu E-Posta İle Kayıt Yapılmıştır. Lütfen Farklı Bir E-Posta Adresi Giriniz.");
      });
      setState(() {
        isLoading = false;
      });
    }
  }

  postDetailsToFirestore() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    setState(() {
      isLoading = true;
    });
    User? user = _auth.currentUser;
    UserModel userModel = UserModel();
    userModel.uid = user?.uid;
    userModel.name = namecontroller.text;
    userModel.email = user?.email;

    await firebaseFirestore
        .collection("person")
        .doc(user?.uid)
        .set(userModel.toMap());
    Fluttertoast.showToast(msg: "Kayıt Başarılı");
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Login()));
    setState(() {
      isLoading = false;
    });
  }
}
