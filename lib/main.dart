import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

// appbar and drawer are removed in app basic
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // DO YOUR STUFF
    new Future<String>.delayed(Duration(seconds: 2), () => '["call back"]')
        .then((String value) {
      print("+++++ FUTURE CALL FINISHED");

      setState(() {
        areYouLoggedIn();
      });
    });
  }

  var webViewReload = GlobalKey<ChangeRouteState>();
  bool showLogout = false;
  // bool isLoggedIn = false;

  Widget showLogoutButton() {
    if (showLogout) {
      return Row(
        children: [
          const SizedBox(
            width: 30.0,
          ),
          TextButton(
              onPressed: () {
                webViewReload.currentState?.clearCache();
                // webViewReload.currentState?.reloadPage('https://socialbite.co/logout?action=logout');
                // Call webivew to redirect here
                setState(() {
                  showLogout = false;
                });
              },
              child: const Text("Logout"))
        ],
      );
    } else {
      return const SizedBox(
        width: 0,
        height: 0,
      );
    }
  }

  bool areYouLoggedIn() {
    var webviewlogin = webViewReload.currentState?.loggedIn;

    print("------->>>home areyouLoggedin : $webviewlogin");

    if (webviewlogin != null) {
      return true;
    } else {
      return false;
    }
  }

  // TODO move styles to styles file Body is
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent, // Color for Android
      statusBarBrightness: Brightness.light,// Dark == white status bar -- for IOS.
       statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
        body: Column(
          children: [
            const SizedBox(
              height: 40.0,
            ),
            Expanded(
              child: ChangeRoute(key: webViewReload),
              flex: 12,
            ),
            Expanded(
              child: showLogoutButton(),
              flex: (showLogout ? 1 : 0),
            )
          ],
        ));
  }
}

class ChangeRoute extends StatefulWidget {
  const ChangeRoute({Key? key}) : super(key: key);

  @override
  ChangeRouteState createState() => ChangeRouteState();
}

class ChangeRouteState extends State<ChangeRoute> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  late WebViewController _webViewController;

  String routeUrl = 'https://www.socialbite.co/login';
  String currentUrl = "";
  bool loggedIn = false;
  @override
  Widget build(BuildContext context) {
    return WebView(
      debuggingEnabled: true,
      zoomEnabled: false,
      initialUrl: routeUrl,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        _webViewController = webViewController;
        _controller.complete(webViewController);
      },
      navigationDelegate: (NavigationRequest request) {
        print("--- is equal to url : " + request.url ==
            ('https://socialbite.co/'));
        if (request.url == ('https://socialbite.co/')) {
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
      onProgress: (int progress) {
        print("webview is loading: $progress%");
      },
      onPageStarted: (String url) {
        print('Page started loading: $url');
        // currentUrl = (await _webViewController.currentUrl())!;
        // currentUrl = url;
      },
      onPageFinished: (String url) {
        // If user is not logged in
        // login user
        currentUrl = url;
        // _getCurrentUrl();
        // TODO check url if it is not login
        // if(!areYouLoggedIn()){
        //   clearCache();
        // }
        if (!areYouLoggedIn()) {
          print("-->>> logging in $url");
          loggedIn = true;
          _webViewController
              .runJavascriptReturningResult("javascript:(function() { " +
                  " var email = document.getElementById('user_email-70');" +
                  "var password = document.getElementById('user_password-70');" +
                  // "document.getElementById('checkbox').checked = true;"+
                 // "email.value = '<email>';" +
                  //"password.value = '<pass>';" +
                  "document.getElementById('um-submit-btn').click();"
                      "})()")
              .catchError((onError) => debugPrint('$onError'));
        }
        // TODO see whats in webview contrller
        print('Page finished loading: $url');
        // currentUrl = (await _webViewController.currentUrl())!;
        print("___[] [] : $currentUrl");
        _webViewController
            .runJavascriptReturningResult("javascript:(function() { " +
                // "var head = document.getElementsByTagName('header')[0];" +
                // "head.parentNode.removeChild(head);" +
                "var footer = document.getElementsByTagName('footer')[0];" +
                "footer.parentNode.removeChild(footer);" +
                "})()")
            .then((value) => debugPrint('Page finished loading Javascript'))
            .catchError((onError) => debugPrint('$onError'));
      },
      gestureNavigationEnabled: true,
    );
  }

  void reloadPage(String newURL) {
    print("------reload $newURL");
    setState(() {
      routeUrl = newURL;
    });
    _webViewController.loadUrl(newURL);
  }

// Always gets submitted twice
  Future<void> _getCurrentUrl() async {
    setState(() async {
      currentUrl = (await _webViewController.currentUrl())!;
    });
  }

  bool areYouLoggedIn() {
    print("-- {} {} -- current url : $currentUrl");

    setState(() {
      // if( currentUrl.contains("login") ){
        loggedIn = !currentUrl.contains("login");
      // }
      // if( currentUrl.contains("logout") ){
      //   loggedIn = !currentUrl.contains("logout");
      // } else {
      //   loggedIn = true;
      // }
    });
    print("------->>> areyouLoggeding webview: $loggedIn");
    return loggedIn;
  }

  void clearCache() {
    print("--- -------- ---------- --------- cleared cache");
    // _webViewController.clearCache();

    reloadPage('https://socialbite.co/logout/');

    setState(() {
      loggedIn = false;
      currentUrl = 'https://socialbite.co/logout/';
    });
    reloadPage('https://socialbite.co/login/');
  }
}
