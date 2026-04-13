import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class JokesWebViewScreen extends StatefulWidget {
  const JokesWebViewScreen({super.key});

  @override
  State<JokesWebViewScreen> createState() => _JokesWebViewScreenState();
}

class _JokesWebViewScreenState extends State<JokesWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      // ..loadFlutterAsset('assets/jokes.html');
      ..loadRequest(Uri.parse('http://192.168.0.104:3000/'));
  }

  Future<List<String>> _readJokes() async {
    final result = await _controller.runJavaScriptReturningResult('''
      JSON.stringify(
        Array.from(document.querySelectorAll('#jokes-list li'))
          .map(li => li.innerText + ' - (ID: ' + li.id + ')' )
      )
    ''');

    String jsonStr = result.toString();
    if (jsonStr.startsWith('"') && jsonStr.endsWith('"')) {
      jsonStr = jsonDecode(jsonStr) as String;
    }

    return (jsonDecode(jsonStr) as List<dynamic>).cast<String>();
  }

  void _showJokesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => FutureBuilder<List<String>>(
          future: _readJokes(),
          builder: (context, snapshot) => Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Jokes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              Expanded(child: _buildModalBody(snapshot, scrollController)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalBody(
    AsyncSnapshot<List<String>> snapshot,
    ScrollController controller,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: ${snapshot.error}'),
        ),
      );
    }
    final jokes = snapshot.data ?? [];
    if (jokes.isEmpty) {
      return const Center(child: Text('No jokes found'));
    }
    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.all(16),
      itemCount: jokes.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(jokes[index], style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jokes (WebView)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _showJokesModal,
        child: const Icon(Icons.list),
      ),
    );
  }
}
