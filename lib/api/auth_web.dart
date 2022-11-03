import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:cyrel/api/token.dart';
import 'package:cyrel/constants.dart';
import 'package:http/http.dart';
import 'package:http/src/client.dart';
import 'package:universal_html/html.dart' as html;

class WebAuth {
  static void login() {
    final random = Random.secure();
    String state = html.window
        .btoa((random.nextDouble() * random.nextDouble()).toString());
    String codeVerifier =
        base64UrlEncode(List.generate(96, (_) => random.nextInt(256)))
            .split('=')[0];
    String codeChallenge =
        base64UrlEncode(sha256.convert(ascii.encode(codeVerifier)).bytes)
            .split('=')[0];
    html.window.sessionStorage.clear();
    html.window.sessionStorage
        .addAll({"state": state, "code_verifier": codeVerifier});
    html.window.location.href =
        "$baseRealm/auth?response_type=code&client_id=$clientId&state=$state&redirect_uri=${Uri.encodeQueryComponent(html.window.location.origin!)}%2F&scope=openid%20profile%20email%20offline_access&code_challenge=$codeChallenge&code_challenge_method=S256&nonce=$state";
  }

  static Future<Token?> resumeLogin(Client httpClient) async {
    if (html.window.sessionStorage.containsKey("code")) {
      Response response = await httpClient.post(Uri.parse("$baseRealm/token"),
          body: _buildQuery({
            "client_id": clientId,
            "grant_type": "authorization_code",
            "state": html.window.sessionStorage["state"]!,
            "code": html.window.sessionStorage["code"]!,
            "code_verifier": html.window.sessionStorage["code_verifier"]!,
            "redirect_uri": "${html.window.location.origin!}/"
          }),
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            "Accept": "application/json"
          });
      html.window.sessionStorage.clear();
      if (response.statusCode != 200) return null;
      Map<String, dynamic> json = jsonDecode(response.body);
      return Token.fromJsonLegacy(json);
    }
    return null;
  }

  static String _buildQuery(Map<String, String> params) {
    List<String> list = List.empty(growable: true);
    params.forEach((key, value) {
      list.add(
          "${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(value)}");
    });
    return list.join("&");
  }

  static String buildQuery(Map<String, String> params) => _buildQuery(params);
}
