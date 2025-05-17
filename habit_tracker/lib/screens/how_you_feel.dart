import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HowYouFeelScreen extends StatefulWidget {
  @override
  _HowYouFeelScreenState createState() => _HowYouFeelScreenState();
}

class _HowYouFeelScreenState extends State<HowYouFeelScreen> {
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;
  List<String> generatedTasks = [];

  Future<void> fetchGPTTasks(String userInput) async {
    setState(() {
      isLoading = true;
      generatedTasks = [];
    });

    const apiKey = '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';
    const endpoint = 'https://api.openai.com/v1/chat/completions';

    final prompt = """Sunt un asistent care creează obiceiuri zilnice pentru sănătatea mintală.
Utilizatorul a spus: "$userInput"

Răspunde cu o listă de 4-6 obiceiuri zilnice simple care pot ajuta.
Fiecare pe o linie nouă, fără alte explicații.
""";

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "user", "content": prompt}
        ],
        "max_tokens": 150,
        "temperature": 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final content = data['choices'][0]['message']['content'] as String;

      setState(() {
        generatedTasks = content
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.replaceAll(RegExp(r'^\d+\.?\s*'), '').trim())
            .toList();
      });
    } else {
      print('Eroare GPT: ${response.body}');
      setState(() {
        generatedTasks = ['A apărut o eroare. Încearcă din nou.'];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cum te simți azi?")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Descrie în câteva cuvinte cum te simți...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => fetchGPTTasks(_controller.text.trim()),
              child: Text("Generează obiceiuri"),
            ),
            SizedBox(height: 24),
            if (isLoading) CircularProgressIndicator(),
            if (!isLoading && generatedTasks.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: generatedTasks.length,
                  itemBuilder: (ctx, i) {
                    return CheckboxListTile(
                      title: Text(generatedTasks[i]),
                      value: false,
                      onChanged: (_) {},
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}
