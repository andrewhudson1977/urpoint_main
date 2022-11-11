import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:is_first_run/is_first_run.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var db = FirebaseFirestore.instance;
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options:
  DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
  //Remove this method to stop OneSignal Debugging
  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

  OneSignal.shared.setAppId("bb459789-7bb7-46cf-b712-15f6ecd564d9");

  OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    print("Accepted permission: $accepted");
  });

  SharedPreferences prefs = await  SharedPreferences.getInstance();
  bool res = prefs.containsKey('userdata');
  bool firstRun = await IsFirstRun.isFirstRun();
  if(firstRun == false) {
    var data = prefs.getString('userdata');
  }
}

String getPlatform(){
  var platform;
  if (Platform.isAndroid) {
    platform = "android";
  } else if (Platform.isIOS) {
    platform = "IOS";
  }
  return platform;
}

Future<String> getUserInfo(var userid) async {
  // gets user device information and sends it to the firestore database
  // Gets the user platform
  var platform = getPlatform();

  //Generates a unique ID for the firestore database
  var db = FirebaseFirestore.instance;
  var UID = db
      .collection('name')
      .doc()
      .id;
  // Gets the OneSignal PlayerID
  await Future.doWhile(() async {
    var status = await OneSignal.shared.getDeviceState();
    String? osUserID = status?.userId;
    if(osUserID == null){
      return true;
    } else {
      return false;
    }
  });
  var status = await OneSignal.shared.getDeviceState();
  String? osUserID = status?.userId;
  String? playerId = osUserID;
  //Creates a class of the user info
  if(playerId == null){
    playerId = "null";
  }
  var user = User(playerId, platform, UID, userid);
  var usermap = user.toMap();
  // Sends user info to FireStore database.
  db.collection("users").doc(UID).set(usermap);
  // Saves user info to users  local storage
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var data = json.encode(usermap);
  prefs.setString('userdata', data);
  var url = "https://www.ur-point.com/firestore.php?userid=$userid&platform=$platform&firestoreid=$UID&playerid=$playerId";
  return url;
}

class User {
  String player_id;
  String platform;
  String firebaseID;
  String userId;
  //constructor
  User(this.player_id, this.platform, this.firebaseID, this.userId);

  Map<String, String> toMap() {
    return {
      "player_id": player_id,
      "platform": platform,
      "firebaseID": firebaseID,
      "userId" : userId
    };
  }
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.blue),
        home: MainPage(),
      );
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}


class _MainPageState extends State<MainPage> {
  late WebViewController controller;
  bool idGot = false;

  get homeUrl => 'https://www.ur-point.com/index.php';

  get userIdUrl => 'https://www.ur-point.com/firestore.php';

  @override
  Widget build(BuildContext context) =>
      Scaffold(
          body: WebView(
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: 'https://www.ur-point.com/',
            onWebViewCreated: (controller) {
              this.controller = controller;
            },

            onPageStarted: (url) async {
              print(idGot);
              if (url == homeUrl && idGot == false) {
                controller.loadUrl(userIdUrl);
              }
            },
            onPageFinished: (url) async {
              var getId = await controller.runJavascriptReturningResult("document.getElementById('userid').value");
              var userId = getId.replaceAll('"', '');
              var senderUrl = await getUserInfo(userId);
              if (url == userIdUrl && idGot == false) {
                print("check4");
                print(senderUrl);
                controller.loadUrl(senderUrl);
              }
            },
          )
      );
}