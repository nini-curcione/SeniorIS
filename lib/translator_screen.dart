import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// TranslatorScreen: A StatefulWidget that provides a UI for text translation.
class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({Key? key}) : super(key: key);

  @override
  _TranslatorScreenState createState() => _TranslatorScreenState();
}

// _TranslatorScreenState: State class for TranslatorScreen.
class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _textController = TextEditingController();
  String _translatedText = "";
  String _inputLanguage = 'en'; // Default input language is English
  String _outputLanguage = 'zh-TW'; // Default target language is Chinese Traditional
  final String apiKey = 'YOUR_TOKEN';

  // List of supported languages with their code and name.
  final List<Map<String, String>> supportedLanguages = [
      {'code': 'am', 'name': 'Amharic'},
      {'code': 'ar', 'name': 'Arabic'},
      {'code': 'eu', 'name': 'Basque'},
      {'code': 'bn', 'name': 'Bengali'},
      {'code': 'en-GB', 'name': 'English(UK)'},
      {'code': 'pt-BR', 'name': 'Portuguese(Brazil)'},
      {'code': 'bg', 'name': 'Bulgarian'},
      {'code': 'ca', 'name': 'Catalan'},
      {'code': 'chr', 'name': 'Cherokee'},
      {'code': 'zh-CN', 'name': 'Chinese Simplified'},
      {'code': 'zh-TW', 'name': 'Chinese Traditional'},
      {'code': 'hr', 'name': 'Croatian'},
      {'code': 'cs', 'name': 'Czech'},
      {'code': 'da', 'name': 'Danish'},
      {'code': 'nl', 'name': 'Dutch'},
      {'code': 'en', 'name': 'English'},
      {'code': 'et', 'name': 'Estonian'},
      {'code': 'fil', 'name': 'Filipino'},
      {'code': 'fi', 'name': 'Finnish'},
      {'code': 'fr', 'name': 'French'},
      {'code': 'de', 'name': 'German'},
      {'code': 'el', 'name': 'Greek'},
      {'code': 'gu', 'name': 'Gujarati'},
      {'code': 'iw', 'name': 'Hebrew'},
      {'code': 'hi', 'name': 'Hindi'},
      {'code': 'hu', 'name': 'Hungarian'},
      {'code': 'is', 'name': 'Icelandic'},
      {'code': 'id', 'name': 'Indonesian'},
      {'code': 'it', 'name': 'Italian'},
      {'code': 'ja', 'name': 'Japanese'},
      {'code': 'kn', 'name': 'Kannada'},
      {'code': 'ko', 'name': 'Korean'},
      {'code': 'lv', 'name': 'Latvian'},
      {'code': 'lt', 'name': 'Lithuanian'},
      {'code': 'ms', 'name': 'Malay'},
      {'code': 'ml', 'name': 'Malayalam'},
      {'code': 'mr', 'name': 'Marathi'},
      {'code': 'no', 'name': 'Norwegian'},
      {'code': 'pl', 'name': 'Polish'},
      {'code': 'pt-PT', 'name': 'Portuguese(Portugal)'},
      {'code': 'ro', 'name': 'Romanian'},
      {'code': 'ru', 'name': 'Russian'},
      {'code': 'sr', 'name': 'Serbian'},
      {'code': 'sk', 'name': 'Slovak'},
      {'code': 'sl', 'name': 'Slovenian'},
      {'code': 'es', 'name': 'Spanish'},
      {'code': 'sw', 'name': 'Swahili'},
      {'code': 'sv', 'name': 'Swedish'},
      {'code': 'ta', 'name': 'Tamil'},
      {'code': 'te', 'name': 'Telugu'},
      {'code': 'th', 'name': 'Thai'},
      {'code': 'tr', 'name': 'Turkish'},
      {'code': 'ur', 'name': 'Urdu'},
      {'code': 'uk', 'name': 'Ukrainian'},
      {'code': 'vi', 'name': 'Vitenamese'},
      {'code': 'cy', 'name': 'Welsh'},
  ];

  // Function to translate text using Google Translate API.
  Future<void> translateText(String text, String targetLanguage) async {
    final response = await http.post(
      Uri.parse('https://translation.googleapis.com/language/translate/v2?key=$apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'q': text,
        'source': _inputLanguage,
        'target': targetLanguage,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _translatedText = data['data']['translations'][0]['translatedText'];
      });
    } else {
      throw Exception('Failed to load data from the Google Translate API');
    }
  }

  // Builds the UI for the translation screen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Select Input Language:'),
                DropdownButton<String>(
                  value: _inputLanguage,
                  onChanged: (String? newValue) {
                    setState(() {
                      _inputLanguage = newValue!;
                    });
                  },
                  items: supportedLanguages.map((language) {
                    return DropdownMenuItem<String>(
                      value: language['code']!,
                      child: Text(language['name']!),
                    );
                  }).toList(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Select Target Language:'),
                DropdownButton<String>(
                  value: _outputLanguage,
                  onChanged: (String? newValue) {
                    setState(() {
                      _outputLanguage = newValue!;
                    });
                  },
                  items: supportedLanguages.map((language) {
                    return DropdownMenuItem<String>(
                      value: language['code']!,
                      child: Text(language['name']!),
                    );
                  }).toList(),
                ),
              ],
            ),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Enter text to translate',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                translateText(_textController.text, _outputLanguage);
              },
              child: const Text('Translate'),
            ),
            Text('Translated Text: $_translatedText'),
          ],
        ),
      ),
    );
  }
}
