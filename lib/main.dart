import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MyApp());

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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: PreferredSize(
          child: Container(),
          preferredSize: Size.fromHeight(0.0),
        ),
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'https://www.ur-point.com/',
          onWebViewCreated: (controller) {
            this.controller = controller;
          },
          onPageStarted: (url) {
            print('New Website: $url');
          },
        ),
      );
}
