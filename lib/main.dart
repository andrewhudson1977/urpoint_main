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
        appBar: AppBar(
          title: const Text('Ur Point'),
          actions: [
            IconButton(
              icon: const Icon(Icons.auto_fix_high),
              onPressed: () async {
                // 1. load new website url
                controller.loadUrl('https://www.ur-cards.com');

                // 2. get current website url
                // final url = await controller.currentUrl();
                // print('Current Website: $url');

                // 3. go to previous website url
                // if (await controller.canGoBack()) {
                //   controller.goBack();
                // }

                // 4. reload website url
                // controller.reload();
              },
            ),
          ],
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
