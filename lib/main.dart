import 'dart:async';
// import 'dart:ffi';
// import 'dart:js';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter xx ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // intial loaded URL
final webViewReload = GlobalKey<ChangeRouteState>();
String routeUrl = 'https://www.socialbite.co/login';
String newURL = "";

  // void _buttonPree(BuildContext context, String newURL){
  //   Navigator.push(context,
  //     MaterialPageRoute( builder: (context) => ChangeRoute(newURL)));
  // }

  void routeChanger() {
    print("routeURL Now: $newURL");
    webViewReload.currentState?.reloadPage(newURL);
    print("routeURL $routeUrl");
    // setState(() {
    //   print("route URL: $routeUrl");

    //   // Navigator.push(
    //   //     context,
    //   //     MaterialPageRoute(
    //   //         builder: (BuildContext context) =>
    //   //             ChangeRoute(routeUrl: routeUrl,)));
    // });
  }

  // TODO make all strings a final variable
  // TODO move styles to styles file
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          iconTheme: IconThemeData(color: Colors.black54),
          backgroundColor: Colors.white70,
          shadowColor: Colors.grey[50],
          centerTitle: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                // TODO change image to SVG
                'assets/images/logo.png',
                fit: BoxFit.contain,
                height: 32,
              )
            ],
          ),
        ),
        endDrawer: Drawer(
          backgroundColor: Colors.blueGrey[50],
          child: Container(
            padding: const EdgeInsets.only(top: 100.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () {
                    webViewReload.currentState?.reloadPage('https://www.socialbite.co');
                  },
                  icon: Icon(Icons.account_circle),
                  label: Text("Profile"),
                ),
                TextButton.icon(
                  onPressed: () {
                    newURL = 'https://www.socialbite.co';
                    routeChanger();
                  },
                  icon: Icon(Icons.settings),
                  label: Text("Settings"),
                ),
                TextButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.help_rounded),
                  label: Text("Support"),
                ),
              ],
            ),
          ),
        ),
        body: const ChangeRoute(
            // routeUrl: routeUrl,
            ));
  }
}

// JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
//   return JavascriptChannel(
//       name: 'Toaster',
//       onMessageReceived: (JavascriptMessage message) {
//         // ignore: deprecated_member_use
//         Scaffold.of(context).showSnackBar(
//           SnackBar(content: Text(message.message)),
//         );
//       });
// }

class ChangeRoute extends StatefulWidget {
  const ChangeRoute({Key? key}) : super(key: key);

  @override
  ChangeRouteState createState() => ChangeRouteState();
}

class ChangeRouteState extends State<ChangeRoute> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  late WebViewController _webViewController;

  // final Function() refresh;
  String routeUrl = 'https://www.socialbite.co/login';
  // ChangeRoute({Key? key, required this.refresh}) : super(key: key);
  // ChangeRoute({Key? key, required this.routeUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WebView(
      zoomEnabled: false,
      initialUrl: routeUrl,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        _webViewController = webViewController;
        _controller.complete(webViewController);
      },
      onProgress: (int progress) {
        print("webview is loading: $progress%");
      },
      // javascriptChannels: <JavascriptChannel>{
      //   _toasterJavascriptChannel(context),
      // },
      // navigationDelegate: (NavigationRequest request) {
      //   if (request.url.contains('socialbite.co/user')) {
      //     return NavigationDecision.navigate;
      //   }
      //   return NavigationDecision.prevent;
      // },
      onPageStarted: (String url) {
        print('Page started loading: $url');
      },
      onPageFinished: (String url) {
        print('Page finished loading: $url');
        _webViewController
            .runJavascriptReturningResult("javascript:(function() { " +
                "var head = document.getElementsByTagName('header')[0];" +
                "head.parentNode.removeChild(head);" +
                "var footer = document.getElementsByTagName('footer')[0];" +
                "footer.parentNode.removeChild(footer);" +
                "})()")
            .then((value) => debugPrint('Page finished loading Javascript'))
            .catchError((onError) => debugPrint('$onError'));
      },
      gestureNavigationEnabled: true,
    );
  }

  void reloadPage( String newURL) {
    print("reload");
    setState(() {
      routeUrl = newURL;
    });
    _webViewController.reload();
  }
}
