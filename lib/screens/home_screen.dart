import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
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
  int _currentIndex = 0;
  late String token;
  late PageController _pageController;
  late Position position;
  late Position _currentPosition;
  late IO.Socket socket;

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

  _getCurrentLocation()async{
    Position pos = await _determinePosition();
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print("TOKEN $token");
    initSocket(token);
    setState(() {
      // socket = soc;
      _currentPosition = pos;
      isLoading = false;
    });
  }

  initSocket(String token) {
  socket = IO.io('http://192.168.229.210:8080/?token=$token', <String, dynamic>{
    'autoConnect': false,
    'transports': ['websocket'],
  });
  socket.connect();
  socket.onConnect((_) {
    print('Connection established');
  });
  socket.onDisconnect((_) => print('Connection Disconnection'));
  socket.onConnectError((err) => print(err));
  socket.onError((err) => print(err));
}


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
    return isLoading?Center(
      child: CircularProgressIndicator(),
    ) : Scaffold(
      // appBar: AppBar(title: Text("Bottom Nav Bar")),
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: <Widget>[
            STTPage(),
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
