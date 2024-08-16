import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URL Shortener',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _aliasController = TextEditingController();
  String _shortenedUrl = '';

  Future<void> shortenUrl() async {
    final String originalUrl = _urlController.text;
    final String alias = _aliasController.text;

    final response = await http.post(
      Uri.parse(
          'https://url-shortener-gt1a.onrender.com/shorten'), // Replace with your backend URL
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'original_url': originalUrl,
        'alias': alias,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _shortenedUrl = json.decode(response.body)['shortened_url'];
      });
    } else {
      setState(() {
        _shortenedUrl = 'Error: Could not shorten URL';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('URL Shortener'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Original URL',
              ),
            ),
            TextField(
              controller: _aliasController,
              decoration: const InputDecoration(
                labelText: 'Alias (optional)',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: shortenUrl,
              child: const Text('Shorten URL'),
            ),
            const SizedBox(height: 20),
            SelectableText(
              _shortenedUrl,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
