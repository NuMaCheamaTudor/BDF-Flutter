import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AiChecklistScreen extends StatefulWidget {
  @override
  _AiChecklistScreenState createState() => _AiChecklistScreenState();
}

class _AiChecklistScreenState extends State<AiChecklistScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _tasks = [];
  Map<String, bool> _checked = {};
  bool _loading = false;

  Future<void> fetchChecklistFromOpenAI(String input) async {
    setState(() {
      _loading = true;
      _tasks = [];
      _checked = {};
    });

    final apiKey = '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';
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "user",
          "content": "Am această problemă: '$input'. Te rog oferă-mi o listă de 5 obiceiuri zilnice care m-ar ajuta. Scrie-le fiecare pe o linie, fără explicații."
        }
      ],
      "max_tokens": 150,
      "temperature": 0.7
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      final lines = content
          .split('')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .map((line) => line.replaceAll(RegExp(r'^\d+\.?\s*'), ''))
          .toList();

      setState(() {
        _tasks = lines;
        _checked = {for (var task in lines) task: false};
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
        _tasks = ['Eroare: ${response.statusCode}'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Obiceiuri AI după problemă')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Ce problemă ai?',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () => fetchChecklistFromOpenAI(_controller.text.trim()),
              child: Text("Generează obiceiuri"),
            ),
            SizedBox(height: 20),
            if (_loading) CircularProgressIndicator(),
            if (!_loading && _tasks.isNotEmpty)
              Expanded(
                child: ListView(
                  children: _tasks.map((task) {
                    return CheckboxListTile(
                      title: Text(task),
                      value: _checked[task] ?? false,
                      onChanged: (value) {
                        setState(() {
                          _checked[task] = value ?? false;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
