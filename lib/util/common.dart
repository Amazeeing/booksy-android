import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prenotazioni/model/utente.dart';

Future<Utente?> authenticateUser() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  /* Ottengo gli username e password salvati in precedenza */
  String? username = prefs.getString('username');
  String? password = prefs.getString('password');

  /* Faccio una chiamata HTTP per autenticare l'utente */
  final response = await http.post(Uri.parse(
      'http://localhost:8080/progetto_TWeb_war_exploded/autentica?action=autenticaUtente'
          '&username=$username&password=$password'));
  String userData = response.body;

  /* Converto la risposta da formato JSON a un oggetto di tipo Utente */
  return _parseUserData(userData);
}

Utente _parseUserData(String responseBody) {
  Map<String, dynamic> parsed = jsonDecode(responseBody);

  return Utente.fromJson(parsed);
}