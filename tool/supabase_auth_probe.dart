import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final client = HttpClient();
  final ts = DateTime.now().millisecondsSinceEpoch;
  final email = 'codex.verify.$ts@gmail.com';

  final signupUri = Uri.parse(
    'https://fkemwsulpfcjwjbpeftx.supabase.co/auth/v1/signup',
  );
  final signupReq = await client.postUrl(signupUri);
  signupReq.headers.set(
    'apikey',
    'sb_publishable_cGbuVUyhB-pW2JCCUJIl0w_UHsiMCcm',
  );
  signupReq.headers.set(
    'Authorization',
    'Bearer sb_publishable_cGbuVUyhB-pW2JCCUJIl0w_UHsiMCcm',
  );
  signupReq.headers.contentType = ContentType.json;
  signupReq.write(jsonEncode({
    'email': email,
    'password': 'TestPass123!',
    'data': {
      'role': 'customer',
      'full_name': 'Codex Verify',
    },
  }));

  final signupRes = await signupReq.close();
  final signupBody = await utf8.decodeStream(signupRes);

  HttpClientResponse? loginRes;
  String? loginBody;
  if (signupRes.statusCode == 200 || signupRes.statusCode == 201) {
    final loginUri = Uri.parse(
      'https://fkemwsulpfcjwjbpeftx.supabase.co/auth/v1/token?grant_type=password',
    );
    final loginReq = await client.postUrl(loginUri);
    loginReq.headers.set(
      'apikey',
      'sb_publishable_cGbuVUyhB-pW2JCCUJIl0w_UHsiMCcm',
    );
    loginReq.headers.set(
      'Authorization',
      'Bearer sb_publishable_cGbuVUyhB-pW2JCCUJIl0w_UHsiMCcm',
    );
    loginReq.headers.contentType = ContentType.json;
    loginReq.write(jsonEncode({
      'email': email,
      'password': 'TestPass123!',
    }));

    loginRes = await loginReq.close();
    loginBody = await utf8.decodeStream(loginRes);
  }

  stdout.write(jsonEncode({
    'email': email,
    'signup_status': signupRes.statusCode,
    'signup_body': signupBody,
    'login_status': loginRes?.statusCode,
    'login_body': loginBody,
  }));
  client.close();
}
