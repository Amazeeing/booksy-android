import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    WebViewController controller = WebViewController();
    controller.loadRequest(Uri.parse('http://localhost:8080/progetto_TWeb_war_exploded/#/register'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagina di login'),
      ),
      body: WebViewWidget(
        controller: controller
      ),
    );
  }
}