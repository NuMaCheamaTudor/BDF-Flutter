import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LifeJournalPage extends StatefulWidget {
  @override
  _LifeJournalPageState createState() => _LifeJournalPageState();
}

class _LifeJournalPageState extends State<LifeJournalPage> {
  final TextEditingController _controller = TextEditingController();
  String _selectedMood = "😌";
  List<Map<String, String>> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('life_entries');
    if (raw != null) {
      final decoded = jsonDecode(raw) as List;
      setState(() {
        _entries = decoded.cast<Map<String, String>>();
      });
    }
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('life_entries', jsonEncode(_entries));
  }

  void _addEntry() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final entry = {
      'date': DateTime.now().toIso8601String(),
      'mood': _selectedMood,
      'text': text,
    };

    setState(() {
      _entries.insert(0, entry);
      _controller.clear();
    });

    _saveEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📓 Life Journal"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xfffbc2eb), Color(0xffa6c1ee)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _buildEntryInputCard(),
            Expanded(child: _buildEntryList()),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryInputCard() {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text("Ce s-a schimbat azi în viața ta?", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Scrie aici...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Starea ta:", style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: ['😌', '😢', '😡', '😎', '🥺', '😴'].map((emoji) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMood = emoji),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedMood == emoji ? Colors.deepPurple.withOpacity(0.2) : Colors.transparent,
                          ),
                          child: Text(emoji, style: TextStyle(fontSize: 24)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _addEntry,
              icon: Icon(Icons.add),
              label: Text("Adaugă"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryList() {
    if (_entries.isEmpty) {
      return Center(child: Text("Nicio intrare încă. Hai să adăugăm ceva!"));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        final date = DateTime.parse(entry['date']!);
        final formattedDate = "${date.day}/${date.month}/${date.year}";

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white.withOpacity(0.85),
          child: ListTile(
            leading: Text(entry['mood']!, style: TextStyle(fontSize: 28)),
            title: Text(entry['text']!, style: TextStyle(fontSize: 16)),
            subtitle: Text(formattedDate),
          ),
        );
      },
    );
  }
}
