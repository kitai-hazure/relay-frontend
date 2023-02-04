import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import 'package:relay/screens/widgets/message_bubble.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatScreen extends StatefulWidget {
  final IO.Socket socket;
  final String room;
  final String token;
  const ChatScreen({
    Key? key,
    required this.socket,
    required this.room,
    required this.token,
  }) : super(key: key);

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
  
  List<Map<dynamic, dynamic>> messages = [];

  void _addMessage(dynamic message, bool isUser, String userName) {
    // print('inside _add msg: $message is user: $isUser');
    widget.socket.emit('chat', {"room" : widget.room, "msg": message, "token":widget.token});
    setState(() {
      messages.insert(0, {
        'message': message,
        'isUserMessage': isUser,
        'username': userName,
      });
    });
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.socket.on('chat',((data){
      print(data);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Messages(messages),
            // child: Container(),
          ),
          NewMessage(_addMessage)
        ],
      ),
    );
  }
}
class Messages extends StatelessWidget {
  final List<Map<dynamic, dynamic>> messages;
  Messages(this.messages);
  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.all(8),
      color: Colors.black12,
      child: ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (ctx, index) => MessageBubble(messages[index]['message'],
              messages[index]['isUserMessage'], messages[index]['username'])),
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