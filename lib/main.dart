import 'package:flutter/material.dart';
import 'jokes_screen.dart';
import 'jokes_webview_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laugh Factory',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laugh Factory')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('HTML Parsing'),
            subtitle: const Text('Fetch & parse jokes via http + html'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JokesScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.web),
            title: const Text('WebView'),
            subtitle: const Text('Load jokes website in a WebView'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JokesWebViewScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
