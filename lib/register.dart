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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagina di login'),
      ),
      body: WebView(
        initialUrl: 'http://localhost:8080/progetto_TWeb_war_exploded/autentica?action=autenticaUtente' /* sostituire con URL della pagina di login */,
        navigationDelegate: (navigation) {
          final host = Uri.parse(navigation.url).host;
          if (host.contains('localhost' /* sostituire con URL della homepage */)) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                'Blocking navigation to Prenotazioni',
              ),
            ));
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }
}