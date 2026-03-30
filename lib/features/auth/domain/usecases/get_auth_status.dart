// lib/features/auth/domain/usecases/get_auth_status.dart

import 'package:firebase_auth/firebase_auth.dart';

class GetAuthStatusUseCase {
  Future<bool> call() async {
    return FirebaseAuth.instance.currentUser != null;
  }
}
