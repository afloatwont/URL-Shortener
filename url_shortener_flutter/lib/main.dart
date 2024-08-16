import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter URL Shortener',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _aliasController = TextEditingController();
  String _shortenedUrl = '';
  bool _isLoading = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> shortenUrl() async {
    final String originalUrl = _urlController.text;

    // Check if the URL field is empty
    if (originalUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a URL')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    _animationController.forward();

    final String alias = _aliasController.text;

    try {
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
          _isLoading = false;
        });
      } else {
        setState(() {
          _shortenedUrl = 'Error: Could not shorten URL';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _shortenedUrl = 'Error: Something went wrong';
        _isLoading = false;
      });
    }
    _animationController.reverse();
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.inAppBrowserView,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Background Image
          Image.network(
            'https://ghiblicollection.com/cdn/shop/products/totoro_hires_1_7dc984c6-a680-4b5e-ac19-642c5e7617ce.jpg?v=1675792119&width=1920', // Replace with your desired image URL
            fit: BoxFit.cover,
          ),
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Welcome to URL Shortener',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Easily shorten long URLs and make them easy to share.\n'
                          'Create custom aliases for your links and track their usage.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: width > height ? width * 0.5 : width,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Shorten a Long URL',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _urlController,
                            decoration: InputDecoration(
                              labelText: 'Original URL',
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.blue[50],
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _aliasController,
                            decoration: InputDecoration(
                              labelText: 'Customize Your Link (Alias)',
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.blue[50],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _isLoading
                              ? const CircularProgressIndicator()
                              : AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return ElevatedButton(
                                      onPressed: shortenUrl,
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor:
                                            _animationController.isAnimating
                                                ? Colors.blue[900]
                                                : Colors.blue[700],
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        textStyle:
                                            const TextStyle(fontSize: 18),
                                      ),
                                      child: _animationController.isAnimating
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text('Shorten URL'),
                                    );
                                  },
                                ),
                          const SizedBox(height: 20),
                          if (_shortenedUrl.isNotEmpty)
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _launchUrl(_shortenedUrl);
                                    },
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: Text(
                                        _shortenedUrl,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.blue[900],
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: () {
                                    Clipboard.setData(
                                        ClipboardData(text: _shortenedUrl));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Link copied to clipboard')),
                                    );
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
