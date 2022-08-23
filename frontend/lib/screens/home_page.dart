import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String text = "";
  String sentimentResult = "";
  String sentimentScore = "";
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Form(
              key: _formkey,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    text = value;
                  });
                },
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                    hintText: "Bir şeyler yazınız",
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black87, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(30)))),
              ),
            ),
            const SizedBox(height: 35),
            TextButton.icon(
              style: TextButton.styleFrom(
                  primary: Colors.green,
                  backgroundColor: Colors.black.withOpacity(0.05)),
              icon: const Icon(
                Icons.sentiment_neutral,
                size: 30,
              ),
              label: const Text(
                "Duygulandır",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                final url = Uri.parse('http://10.0.2.2:5000/nlp');
                final responsepost =
                    await http.post(url, body: json.encode({'text': text}));

                final responseget = await http.get(url);
                final decoded =
                    jsonDecode(responseget.body) as Map<String, dynamic>;

                setState(() {
                  sentimentResult = decoded['merhaba'];
                });
              },
            ),
            const SizedBox(height: 10),
            Text(
              "Text: $text",
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 10),
            Text(
              "Sentiment: $sentimentResult",
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 10),
            Text(
              "Score: $sentimentScore",
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}
