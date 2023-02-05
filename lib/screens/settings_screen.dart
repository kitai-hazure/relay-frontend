import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:relay/constants/graphql_endpoint.dart';
import 'package:relay/constants/queries.dart';
import 'package:relay/models/language_model.dart';
import 'package:relay/screens/sign_in_screen.dart';
import 'package:relay/screens/sign_in_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  GoogleSignInAccount? googleUse;
  bool isLoading = true;
  late String init;
  _getAccount() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String locale = prefs.getString('locale') ?? "en";
    print(googleUser);
    setState(() {
      googleUse = googleUser;
      isLoading = false;
      init = locale;
    });
  }

  Future<void> _handleSignOut() async {
    try {
      await GoogleSignIn().disconnect();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
          (route) => false);
    } catch (error) {
      print(error);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAccount();
  }

  // List of items in our dropdown menu
  var items = [
    'en',
    'hi',
    'ab',
    'cs',
    'ca',
    "es",
    "fr"
  ];

  _updateLanguage(String new_locale)async{
    SharedPreferences prefs =  await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
        final GraphQLEndPoints point = GraphQLEndPoints();
    ValueNotifier<GraphQLClient> client = point.getClientWithToken(token);

    QueryResult result = await client.value.mutate(MutationOptions(
      document: gql(Queries.updateLanguage()),
      variables: {
        "input": {
          "lang":new_locale
        }
      }
    ));

    if (result.hasException) {
      //print(result.exception);

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
      print("DONE");
    }
    
  }

  @override
  Widget build(BuildContext context) {
    print(googleUse);
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Column(
              // mainAxisAlignment: MainAxisAlignmen
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LottieBuilder.asset("assets/lottie/profile.json"),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "User",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 206, 219, 225),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.red),
                    title: Text(googleUse!.displayName!),
                    subtitle: Text(googleUse!.email),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Language Preferences",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Divider(),
                Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      // color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton(
                      borderRadius: BorderRadius.circular(20),
                      elevation: 0,
                      // style: BorderStyle.none,
                      value: init,
                      isExpanded: true,
                      // Down Arrow Icon
                      icon: const Icon(Icons.language),
                      // Array list of items
                      items: items.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items, style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500
                          ),),
                        );
                      }).toList(),
                      // After selecting the desired option,it will
                      // change button value to selected value
                      onChanged: (String? newValue) async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setString("locale", newValue!);
                        _updateLanguage(newValue);
                        setState(() {
                          init = newValue;
                        });
                      },
                    ),
                    // child: DropdownButton<Language>(
                    //   underline: const SizedBox(),
                    //   icon: const Icon(
                    //     Icons.language,
                    //     // color: Colors.white,
                    //   ),
                    //   value: dropdownValue == null ? null : dropdownValue,
                    //   // value: temp,
                    //   onChanged: (Language? language) async {
                    //     if (language != null) {
                    //       // Locale _locale = await setLocale(language.languageCode);
                    //       // MyApp.setLocale(context, _locale);
                    //       // print(_locale);
                    //       dropdownValue = language;
                    //       setState(() {});
                    //     }
                    //   },
                    //   items: Language.languageList()
                    //       .map<DropdownMenuItem<Language>>(
                    //         (e) => DropdownMenuItem<Language>(
                    //           value: e,
                    //           child: Row(
                    //             mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //             children: <Widget>[
                    //               Text(
                    //                 e.flag,
                    //                 style: const TextStyle(fontSize: 30),
                    //               ),
                    //               Text(e.name)
                    //             ],
                    //           ),
                    //         ),
                    //       )
                    //       .toList(),
                    // ),
                  ),
                ),
                // Container(
                //     margin: EdgeInsets.all(10),
                //     decoration: BoxDecoration(
                //         color: Colors.grey,
                //         borderRadius: BorderRadius.all(Radius.circular(20))),
                //     child: ListTile(
                //       title: Text("Log Out"),
                //       trailing: IconButton(
                //         icon:Icon(Icons.logout),
                //         onPressed: _handleSignOut,
                //       ),
                //     ))
              ],
            )),
    );
  }
}
