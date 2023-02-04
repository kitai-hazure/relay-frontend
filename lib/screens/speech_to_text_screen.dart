import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:relay/models/user_model.dart';
import 'package:relay/screens/sign_in_screen.dart';

import '../constants/graphql_endpoint.dart';
import '../constants/queries.dart';

class STTPage extends StatefulWidget {
  // Future<List<User>?> getUsers;
  STTPage({
    Key? key,
    // required this.getUsers,
  }) : super(key: key);

  @override
  _STTPageState createState() => _STTPageState();
}

class _STTPageState extends State<STTPage> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // _initSpeech();
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
                      // FutureBuilder(
                      //   future: widget.getUsers,
                      //   builder: ((context, snapshot){
                      //     if(snapshot.connectionState == ConnectionState.waiting){
                      //       return CircularProgressIndicator();
                      //     }
                      //     print(snapshot.hasData);
                      //     if(snapshot.hasData){
                      //       return ListTile(
                      //         title: Text("has data"),
                      //       );
                      //     }

                      //     return Text("No data");
                      //   })
                      // )
                      ListTile(
                        leading: CircleAvatar(backgroundColor: Colors.red),
                        title: Text("Akhilesh Manda"),
                        trailing: ElevatedButton(
                          child: Text("Connect"),
                          onPressed: () {},
                        ),
                      ),
                      ListTile(
                        leading: CircleAvatar(backgroundColor: Colors.orange),
                        title: Text("Dhruv Dave"),
                        trailing: ElevatedButton(
                          child: Text("Connect"),
                          onPressed: () {},
                        ),
                      ),
                      ListTile(
                        leading: CircleAvatar(backgroundColor: Colors.yellow),
                        title: Text("Kalash Shah"),
                        trailing: ElevatedButton(
                          child: Text("Connect"),
                          onPressed: () {},
                        ),
                      ),
                                            ListTile(
                        leading: CircleAvatar(backgroundColor: Colors.blue),
                        title: Text("Name"),
                        trailing: ElevatedButton(
                          child: Text("Connect"),
                          onPressed: () {},
                        ),
                      )
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
