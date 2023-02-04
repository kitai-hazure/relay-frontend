import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:relay/screens/sign_in_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class STTPage extends StatefulWidget {
  STTPage({Key? key}) : super(key: key);

  @override
  _STTPageState createState() => _STTPageState();
}

class _STTPageState extends State<STTPage> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _handleSignOut() async {
    try {
      GoogleSignInAccount? acc = await GoogleSignIn().disconnect();
      print(acc);
      final prefs = await SharedPreferences.getInstance();
      prefs.remove("isLoggedIn");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
    } catch (error) {
      print(error);
    }
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    var locales = await _speechToText.locales();

    // Some UI or other code to select a locale from the list
    // resulting in an index, selectedLocale
    _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: "hi",
    );
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.blue,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    LottieBuilder.asset(
                      "assets/lottie/radar.json",
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Finding Users Near You",
                            style:
                                TextStyle(color: Colors.white, fontSize: 25))),
                  ],
                  alignment: Alignment.center,
                ),
              ),
              Expanded(
                flex: 10,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      color: Colors.white),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Users near you.....',
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      // Container(
                      //     margin: EdgeInsets.all(10),
                      //     decoration: BoxDecoration(
                      //         color: Colors.grey,
                      //         borderRadius:
                      //             BorderRadius.all(Radius.circular(20))),
                      //     child: ListTile(
                      //       title: Text("Log Out"),
                      //       trailing: IconButton(
                      //         icon: Icon(Icons.logout),
                      //         onPressed: _handleSignOut,
                      //       ),
                      //     ))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed:
      //       // If not yet listening for speech start, otherwise stop
      //       _speechToText.isNotListening ? _startListening : _stopListening,
      //   tooltip: 'Listen',
      //   child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      // ),
    );
  }
}
