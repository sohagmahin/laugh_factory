import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

class Joke {
  final String author;
  final String handle;
  final String text;

  Joke({required this.author, required this.handle, required this.text});
}

class JokesScreen extends StatefulWidget {
  const JokesScreen({super.key});

  @override
  State<JokesScreen> createState() => _JokesScreenState();
}

class _JokesScreenState extends State<JokesScreen> {
  List<Joke> _jokes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchJokes();
  }

  Future<void> _fetchJokes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://www.laughfactory.com/jokes'),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120 Mobile Safari/537.36',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load jokes: ${response.statusCode}');
      }

      final document = html_parser.parse(response.body);
      final jokes = _parseJokes(document);

      setState(() {
        _jokes = jokes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Joke> _parseJokes(dom.Document document) {
    final jokes = <Joke>[];

    final jokeContainers = document.querySelectorAll('h4');

    for (final h4 in jokeContainers) {
      final authorAnchor = h4.querySelector('a');
      if (authorAnchor == null) continue;

      final author = authorAnchor.text.trim();
      String handle = '';
      String jokeText = '';

      final parent = h4.parent;
      if (parent == null) continue;

      final children = parent.children;
      final h4Index = children.indexOf(h4);

      for (int i = h4Index + 1; i < children.length; i++) {
        final sibling = children[i];
        final tag = sibling.localName;

        if (tag == 'h4') break;

        if (tag == 'p' || tag == 'span') {
          final text = sibling.text.trim();
          if (text.startsWith('@') && handle.isEmpty) {
            handle = text;
          } else if (text.isNotEmpty &&
              !text.startsWith('Laughs') &&
              !text.contains('Share') &&
              jokeText.isEmpty) {
            jokeText = text;
          }
        }
      }

      if (jokeText.isNotEmpty) {
        jokes.add(Joke(author: author, handle: handle, text: jokeText));
      }
    }

    if (jokes.isEmpty) {
      final sections =
          document.querySelectorAll('.jokes-from-you, [class*="joke"]');
      for (final section in sections) {
        final text = section.text.trim();
        if (text.isNotEmpty) {
          jokes.add(Joke(
            author: 'TheLaughFactory',
            handle: '@TheLaughFactory',
            text: text,
          ));
        }
      }
    }

    return jokes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jokes From You')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    if (_jokes.isEmpty) {
      return const Center(child: Text('No jokes found'));
    }

    return ListView.builder(
      itemCount: _jokes.length,
      itemBuilder: (context, index) {
        final joke = _jokes[index];
        return ListTile(
          title: Text(joke.text),
          subtitle: Text('${joke.author} ${joke.handle}'),
        );
      },
    );
  }
}
