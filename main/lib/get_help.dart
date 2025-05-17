import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetHelp extends StatefulWidget {
  @override
  _GetHelpState createState() => _GetHelpState();
}

class _GetHelpState extends State<GetHelp> {
  final List<String> _options = [
    'Am nevoie de ajutor medical',
    'Vreau să vorbesc cu cineva',
    'Am nevoie de susținere emoțională',
    'Sunt în pericol',
  ];

  // Harta cu ce e bifat
  Map<String, bool> _checked = {};

  @override
  void initState() {
    super.initState();
    _loadSelections();
  }

  Future<void> _loadSelections() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _checked = {
        for (var option in _options)
          option: prefs.getBool(option) ?? false,
      };
    });
  }

  Future<void> _saveSelection(String option, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(option, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select your needs')),
      body: ListView(
        children: _options.map((option) {
          return CheckboxListTile(
            title: Text(option),
            value: _checked[option] ?? false,
            onChanged: (bool? value) {
              if (value == null) return;
              setState(() {
                _checked[option] = value;
              });
              _saveSelection(option, value);
            },
          );
        }).toList(),
      ),
    );
  }
}
