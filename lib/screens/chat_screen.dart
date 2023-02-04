import 'dart:math';
import 'dart:convert';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

const baseurl =
    'https://iyojna-backend.herokuapp.com/schemes/retrieve-query-schemes/?query=';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

class _ChatScreenState extends State<ChatScreen> {
  List<Item> _data = [];
  List<Map<dynamic, dynamic>> messages = [];

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        var mssg =
            "${_data[index].headerValue}\n\n${_data[index].expandedValue}";
        _addMessage(mssg, false, 'Bot');
        setState(() {
          _data[index].isExpanded = !isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(item.headerValue),
            );
          },
          body: ListTile(
              title: Text(item.expandedValue),
              subtitle:
                  const Text('To delete this panel, tap the trash can icon'),
              trailing: const Icon(Icons.delete),
              onTap: () {
                setState(() {
                  _data.map((e) => e.isExpanded = !e.isExpanded).toList();
                  _data.removeWhere((Item currentItem) => item == currentItem);
                });
              }),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }

  void _addMessage(dynamic message, bool isUser, String userName) {
    // print('inside _add msg: $message is user: $isUser');
    setState(() {
      messages.insert(0, {
        'message': message,
        'isUserMessage': isUser,
        'username': userName,
      });
    });
    if (isUser) {
      final userMsg = messages.elementAt(0);
      // for every space in the message, replace it with &
      final query = userMsg['message'].toString().replaceAll(' ', ',');
      final combinedurl = baseurl + query;
      // print(query);
      final uri = Uri.parse(combinedurl);

      Widget botIcon = const SizedBox(
        child: CircularProgressIndicator(),
      );

      _addMessage(botIcon, false, 'Bot');

      // make async function
      Future<void> getResponse() async {
        final response = await http.get(uri, headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        });

        if (response.statusCode == 200) {
          setState(() {
            messages.removeAt(0);
          });
          print(json.decode(response.body));
          final Map<dynamic, dynamic> data = json.decode(response.body);

          if (data.isEmpty) {
            _addMessage('No results found! Please try again', false, 'Bot');
          } else {
            // print(data);
            _data.clear();
            for (var x in data.keys.toList()) {
              // var reply = "${data[x]["name"]}\n\n${data[x]["desc"]}";
              for (var elem in data[x]) {
                var reply = "${elem["name"]}\n\n${elem["desc"]}";
                _data.add(Item(
                  headerValue: elem["name"],
                  expandedValue: elem["desc"],
                ));
              }
            }
            _addMessage(_buildPanel(), false, 'Bot');
          }
        } else {
          setState(() {
            messages.removeAt(0);
          });
          _addMessage('An error occurred while processing, please try again',
              false, 'Bot');
        }
      }

      getResponse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            // child: Messages(messages),
            child: Container(),
          ),
          NewMessage(_addMessage)
        ],
      ),
    );
  }
}

class NewMessage extends StatefulWidget {
  Function addMsg;
  NewMessage(this.addMsg);
  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = new TextEditingController();
  String hintText = "";

  void _sendMessage() async {
    if (_controller.text.isEmpty) {
      print('empty message');
      return;
    }
    String username = "Akhilesh";

    widget.addMsg(_controller.text, true, username);
    FocusScope.of(context).unfocus();
  }

  void dispose() {
    //dialogFlowtter.dispose();
    super.dispose();
  }

  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  // Function where we capture the voice
  void _onSpeechResultText(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      // print(_lastWords);
      setState(() {
        _controller.text = _lastWords;
      });
      // print("LOL" + hintText);
    });
  }

  void _startListeningText() async {
    var locales = await _speechToText.locales();
    // print("LOCALES: " + locales.length.toString());
    final Locale appLocale = Localizations.localeOf(context);
    // print(appLocale.toString());
    await _speechToText.listen(
      onResult: _onSpeechResultText, localeId: "hi"
    );
    // if (appLocale.toString() == "es") {
    //   await _speechToText.listen(
    //       onResult: _onSpeechResultText, localeId: appLocale.toLanguageTag());
    //   setState(() {});
    //   return;
    // }
    await _speechToText.listen(onResult: _onSpeechResultText);
    setState(() {});
  }

  void _stopListening() async {
    // print("stopped");
    await _speechToText.stop();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(10),
            height: 60,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), color: Colors.black12),
            child: Center(
              child: TextField(
                //Defaults to an uppercase keyboard for the first letter of each sentence.
                textCapitalization: TextCapitalization.sentences,
                enableSuggestions: true,
                controller: _controller,
                decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: FloatingActionButton(
                        backgroundColor: Colors.transparent,
                        onPressed:
                            // If not yet listening for speech start, otherwise stop
                            _speechToText.isNotListening
                                ? _startListeningText
                                : _stopListening,
                        tooltip: 'Listen',
                        child: Icon(
                          _speechToText.isNotListening
                              ? Icons.mic_off
                              : Icons.mic,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    contentPadding: const EdgeInsets.only(bottom: 10),
                    hintText: hintText == "" ? 'Send a message..' : hintText,
                    border: InputBorder.none),
                onChanged: (value) {
                  setState(() {
                    //will update entered message with every keystroke
                    _controller.text = value;
                  });
                },
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            _sendMessage();
            _controller.clear();
          },
          icon: const Icon(Icons.send),
        ),
      ],
    );
  }
}