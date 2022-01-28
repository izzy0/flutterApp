import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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
  final webViewReload = GlobalKey<ChangeRouteState>();
  bool showLogout = false;
  bool isLoggedIn = false;

  Widget showLogoutButton() {
    if (showLogout) {
      return Row(
        children: [
          const SizedBox(
            width: 30.0,
          ),
          TextButton(
              onPressed: () {
                webViewReload.currentState
                    ?.reloadPage('https://socialbite.co/logout/');
                webViewReload.currentState
                    ?.reloadPage('https://socialbite.co/login/');
                // Navigator.pop(context);
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

  // TODO move styles to styles file
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          iconTheme: const IconThemeData(color: Colors.black54),
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
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.white70),
                child: Image.asset(
                  // TODO change image to SVG
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  height: 32,
                ),
              ),
              Visibility(
                  visible: isLoggedIn,
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text("Profle"),
                        leading: const Icon(Icons.account_circle),
                        onTap: () {
                          if (isLoggedIn) {
                            webViewReload.currentState
                                ?.reloadPage('https://www.socialbite.co/user');
                          } else {
                            webViewReload.currentState
                                ?.reloadPage('https://www.socialbite.co/login');
                          }

                          showLogout = false;
                          Navigator.pop(context);
                        },
                      ),
                      const Divider(),
                    ],
                  )),
              Visibility(
                  visible: isLoggedIn,
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text("Settings"),
                        leading: const Icon(Icons.settings),
                        onTap: () {
                          webViewReload.currentState
                              ?.reloadPage('https://socialbite.co/account/');
                          showLogout = true;
                          Navigator.pop(context);
                        },
                      ),
                      const Divider(),
                    ],
                  )),
              ListTile(
                title: const Text("Products"),
                leading: const Icon(Icons.shopping_bag_rounded),
                onTap: () {
                  webViewReload.currentState
                      ?.reloadPage('https://socialbite.co/order-product/');
                  showLogout = false;
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("Support"),
                leading: const Icon(Icons.help_rounded),
                onTap: () {
                  webViewReload.currentState
                      ?.reloadPage('https://socialbite.co/contact/');
                  showLogout = false;
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
        body: Column(
          children: [
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
      onPageStarted: (String url) {
        print('Page started loading: $url');
      },
      onPageFinished: (String url) {
        // If user is not logged in
        // login user
        // if (true) {
        //   print("logging in");
        //   _webViewController.runJavascript("javascript:(function() { " +
        //       " var email = document.getElementById('user_email-70');" +
        //       "var password = document.getElementById('user_password-70');" +
        //       // "document.getElementById('checkbox').checked = true;"+ 
        //       "email.value = 'izharrosman@gmail.com';" +
        //       "password.value = '1p5Hmwp9dt!D';" +
        //       "document.getElementById('um-submit-btn').click();"
        //           "})()");
        // }
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

  void reloadPage(String newURL) {
    print("------reload $newURL");
    setState(() {
      routeUrl = newURL;
    });
    _webViewController.loadUrl(newURL);
  }
}
