import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CloudFunctionsService {
  CloudFunctionsService(this._functions, this._auth);

  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  static const String region = 'us-central1';

  Future<Map<String, dynamic>> call(
    String name, {
    Map<String, dynamic>? data,
  }) async {
    final callable = _functions.httpsCallable(
      name,
      options: HttpsCallableOptions(
        timeout: const Duration(seconds: 60),
      ),
    );
    final result = await callable.call<Map<String, dynamic>>(data ?? {});
    return Map<String, dynamic>.from(result.data);
  }

  Future<void> ensureAuthToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.getIdToken(true);
    }
  }
}
