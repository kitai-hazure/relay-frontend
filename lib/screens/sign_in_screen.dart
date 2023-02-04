import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import 'package:relay/constants/graphql_endpoint.dart';
import 'package:relay/constants/queries.dart';
import 'package:relay/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  GoogleSignInAccount? _currentUser;
  bool isLoading = false;
  Future<void> backendUpload(
      {required String email,
      required String name,
      required String language,
      String? profilePicture,
      required context}) async {
    setState(() {
      isLoading = true;
    });

    final GraphQLEndPoints point = GraphQLEndPoints();
    ValueNotifier<GraphQLClient> client = point.getClient();

    QueryResult result = await client.value.mutate(MutationOptions(
        document: gql(Queries.signup()),
        variables: {
          "input": {
            'email': email,
            'name': name,
            "language": language ?? "en",
            "profilePicture": profilePicture ?? "LOL",
          }
        }));

    if (result.hasException) {
      //print(result.exception);
      setState(() {
        isLoading = false;
      });

      if (result.exception!.graphqlErrors.isEmpty) {
        print(result.exception.toString());
      } else {
        //print(result.exception!.graphqlErrors[0].message.toString());
      }
    } else {
      print(result.data);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("token", result.data!['signup']);
      print("DONE");
    }
  }

  Future<void> _handleSignIn() async {
    try {
      print("handling sign in");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print(googleUser);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("isLoggedIn", true);
      print("SIGNED IN");
      if(googleUser !=null)
      await backendUpload(
        email: googleUser.email, 
        name: googleUser.displayName ?? "NO NAME", 
        language: prefs.getString("locale") ?? "en", 
        context: context
      );
      print("PUSHING SCREEN");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: ((context) => HomeScreen())));
    } catch (error) {
      print(error);
    }
  }

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  // Future<void> _handleSignOut() => _googleSignIn.disconnect();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                LottieBuilder.asset("assets/lottie/onboarding-1.json"),
                const Text("Let's Get You Signed Up")
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              _handleSignIn();
            },
            child: Container(
              // height: 20,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FaIcon(FontAwesomeIcons.googlePlusG),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Sign In With Google"),
                )
              ]),
            ),
          )
        ],
      ),
    );
  }
}
