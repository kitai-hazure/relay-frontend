import 'dart:convert';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:relay/constants/graphql_endpoint.dart';
import 'package:relay/constants/queries.dart';
import 'package:relay/models/user_model.dart';
import 'package:relay/screens/chat_screen.dart';
import 'package:relay/screens/settings_screen.dart';
import 'package:relay/screens/speech_to_text_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  bool isLoadingSocket = true;
  int _currentIndex = 0;
  late String token;
  late PageController _pageController;
  late Position position;
  late Position _currentPosition;
  late IO.Socket socket;

  late Future _future;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  _getCurrentLocation() async {
    Position pos = await _determinePosition();
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print("TOKEN $token");
    initSocket(token, pos.latitude.toString(), pos.longitude.toString());
    setState(() {
      // socket = soc;
      this.token = token;
      _currentPosition = pos;
      isLoading = false;
    });
  }

  initSocket(String token, String lat, String long) {
    socket = IO.io(
        'https://relay-backend.azurewebsites.net/?token=$token&latitute=$lat&longitude=$long',
        <String, dynamic>{
          'autoConnect': false,
          'transports': ['websocket'],
        });
    socket.connect();
    socket.onConnect((_) async {
      print('Connection established');
      await _getUsers(token);
    });
    socket.on("request-call", (data) {
      print("CALL REQUEST");
      print("DATA $data");
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text(data["name"].toString() + " wants to chat"),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        _acceptPressed(data["fromId"], data["toId"]);
                      },
                      child: const Text("Accept")),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Reject"))
                ],
                content: Text("Connect and grow"),
              ));
    });

    socket.on("joinedRoom", (data) {
      print("DATAAAA $data");
    });

    socket.on("chat", (data){
      print("CHAT DATAAAA $data");
    });

    socket.onDisconnect((_) => print('Connection Disconnection'));
    socket.onConnectError((err) => print(err));
    socket.onError((err) => print(err));
    // return true;
  }

  Future<List<User>?> _getUsers(String token) async {
    print("RUNNING API");
    final GraphQLEndPoints point = GraphQLEndPoints();
    ValueNotifier<GraphQLClient> client = point.getClientWithToken(token);

    QueryResult result = await client.value.mutate(MutationOptions(
      document: gql(Queries.getUsers()),
    ));

    if (result.hasException) {
      //print(result.exception);
      setState(() {
        isLoading = false;
      });

      if (result.exception!.graphqlErrors.isEmpty) {
        print("EXCEPTION HERE");
        print(result.exception.toString());
      } else {
        print("EXCEPTION HERE");
        print(result.exception!.graphqlErrors[0].message.toString());
      }
    } else {
      print("RUNNN");
      print(result.data);
      List<User> users = [];
      for (var x in result.data!["findPeople"]) {
        print(x["user"].toString());
        users.add(User(
          id: x["user"]["id"],
          name: x["user"]["name"],
          language: x["user"]["language"],
          profilePic: x["user"]["profilePicture"],
        ));
      }
      // setState(() {
      //   x = users;
      // });
      // x = users;

      print("DONE");
      return users;
    }
  }

  _requestConnect(String toID) {
    // Navigator.pop(context);
    print("in request connect");
    String fromID = "63de7963dbdae42975eb0ec0";
    socket.emit("request-call", {"fromId": fromID, "toId": toID});
    socket.emit("joinRoom", {"room": fromID + toID, "token": token});
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => ChatScreen(
          socket: socket, room: fromID + toID,token: token,
        )));
  }

  _acceptPressed(String fromID, String toID) {
    print("ACCEPTED");
    socket.emit("joinRoom", {"room": fromID + toID, "token": token});
    print("LOL HERE");
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => ChatScreen(
          socket: socket, room: fromID + toID,token: token,
        )));
  }
  // _listenCall() {
  //   socket.on("request-call", (data) {
  //     print("CALL REQUEST");
  //     print(data);
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print(_currentPosition.latitude.toString() + "LOLL");
    return isLoading
        ? Scaffold(
          body: const Center(
              child: CircularProgressIndicator(),
            ),
        )
        : Scaffold(
            // appBar: AppBar(title: Text("Bottom Nav Bar")),
            body: SizedBox.expand(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                children: <Widget>[
                  // Text(x[0].uid.toString()),
                  FutureBuilder(
                      future: _getUsers(token),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          print(snapshot.data);
                          if (snapshot.hasData) {
                            return Scaffold(
                              // backgroundColor: Colors.blue,
                              body: SafeArea(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 6,
                                        child: Stack(
                                          children: [
                                            LottieBuilder.asset(
                                              "assets/lottie/radar.json",
                                              width: double.infinity,
                                              fit: BoxFit.fitWidth,
                                            ),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                    "Finding Users Near You",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 25))),
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
                                                  topRight:
                                                      Radius.circular(20)),
                                              color: Colors.white),
                                          child: Column(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(16),
                                                child: Text(
                                                  'Users near you...',
                                                  style:
                                                      TextStyle(fontSize: 20.0),
                                                ),
                                              ),
                                              snapshot.data!.length !=0?
                                              Expanded(
                                                child: ListView.builder(
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        snapshot.data!.length,
                                                    itemBuilder: (ctx, index) {
                                                      return ListTile(
                                                        leading: CircleAvatar(
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                        title: Text(snapshot
                                                            .data![index].name),
                                                        trailing:
                                                            ElevatedButton(
                                                          child:
                                                              Text("Connect"),
                                                          onPressed: () {
                                                            _requestConnect(
                                                                snapshot
                                                                    .data![
                                                                        index]
                                                                    .id);
                                                          },
                                                        ),
                                                      );
                                                    }),
                                              ): Column(
                                                children: [
                                                  LottieBuilder.asset("assets/lottie/no_users.json"),
                                                  Text("No Users Found", style: TextStyle(
                                                    fontSize: 20
                                                  )),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          return Center(child: Text("No User Found"));
                        }
                      }),
                  // STTPage(getUsers: x),
                  // Container(
                  //   color: Colors.red,
                  // ),
                  // ChatScreen(),
                  SettingsScreen()
                ],
              ),
            ),
            bottomNavigationBar: BottomNavyBar(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              showElevation: false,
              selectedIndex: _currentIndex,
              onItemSelected: (index) {
                setState(() => _currentIndex = index);
                _pageController.jumpToPage(index);
              },
              items: <BottomNavyBarItem>[
                BottomNavyBarItem(
                    title: Text('Home'),
                    icon: Icon(Icons.home),
                    textAlign: TextAlign.center),
                // BottomNavyBarItem(title: Text('Connect'), icon: Icon(Icons.apps)),
                // BottomNavyBarItem(
                //     title: Text('Chat'), icon: Icon(Icons.chat_bubble)),
                BottomNavyBarItem(
                    textAlign: TextAlign.center,
                    title: Text('Settings'),
                    icon: Icon(Icons.settings)),
              ],
            ),
          );
  }
}
