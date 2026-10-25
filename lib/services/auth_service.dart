import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // ============ REGISTER → PENDING USERS ============
  // Oyuncu kayıt olunca users/ altına DEĞİL, pending_users/ altına yazılır.
  // Hesap admin onayına kadar pasif kalır.
  Future<UserModel?> registerUser({
    required String fullName,
    required String email, // AppProvider tarafında hata vermemesi için imzada bırakıldı
    required String phone,
    required String password,
    required String sport,
    required String level,
    required String weightClass,
    String emergencyContact = '',
    String emergencyPhone = '',
    int playerNumber = 0,
  }) async {
    try {
      // Arkaplanda telefon numarasını Auth için mail adresine dönüştürüyoruz
      final String authEmail = "${phone.trim()}@lycans.app";

      final UserCredential credential =
      await _auth.createUserWithEmailAndPassword(
        email: authEmail,
        password: password,
      );

      final String uid = credential.user!.uid;
      final DateTime now = DateTime.now();

      // === pending_users/{uid} altına yaz — users/ DEĞİL ===
      await _database.ref('pending_users/$uid').set({
        'uid': uid,
        'fullName': fullName,
        'phone': phone.trim(),
        'email': authEmail,
        'sport': sport,
        'level': level,
        'weightClass': weightClass,
        'emergencyContact':
        emergencyContact.isNotEmpty ? emergencyContact : fullName,
        'emergencyPhone':
        emergencyPhone.isNotEmpty ? emergencyPhone : phone.trim(),
        'guardian': 'Not applicable',
        'playerNumber': playerNumber,
        'status': 'pending',
        'requestedAt': now.toIso8601String(),
      });

      // Hemen sign-out — hesap aktif değil
      await _auth.signOut();

      // Model döndürüyoruz ki caller tarafı kullanabilsin (opsiyonel)
      return UserModel(
        uid: uid,
        fullName: fullName,
        phone: phone.trim(),
        email: authEmail,
        sport: sport,
        level: level,
        weightClass: weightClass,
        emergencyContact:
        emergencyContact.isNotEmpty ? emergencyContact : fullName,
        emergencyPhone:
        emergencyPhone.isNotEmpty ? emergencyPhone : phone.trim(),
        joinDate: now,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // ============ LOGIN (Pending/Disabled check) ============
  Future<User?> loginUser({
    required String email, // UI'dan telefon numarası gelecek
    required String password,
  }) async {
    try {
      // Girilen bilginin sonuna otomatik @lycans.app ekleniyor (eğer yoksa)
      String loginEmail = email.trim();
      if (!loginEmail.contains('@')) {
        loginEmail = '$loginEmail@lycans.app';
      }

      final UserCredential credential =
      await _auth.signInWithEmailAndPassword(
        email: loginEmail,
        password: password,
      );

      final uid = credential.user!.uid;

      // === users/{uid} var mı? Yoksa pending kontrolü ===
      final userSnap = await _database
          .ref('${AppConstants.usersPath}/$uid')
          .get();

      if (!userSnap.exists) {
        // users altında kayıt yok → pending veya disabled olabilir
        final pendingSnap =
        await _database.ref('pending_users/$uid').get();

        String errorMessage = 'Your account is pending admin approval.';

        if (pendingSnap.exists && pendingSnap.value != null) {
          final data = Map<dynamic, dynamic>.from(
              pendingSnap.value as Map);
          final status = (data['status'] ?? 'pending').toString();
          if (status == 'disabled') {
            errorMessage =
            'Your account has been disabled. Please contact the admin.';
          }
        }

        // Hemen sign-out — hesap aktif değil
        await _auth.signOut();
        throw Exception(errorMessage);
      }

      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      // Pending / disabled hatası zaten yukarıda fırlatıldı — direkt geçir
      final msg = e.toString().replaceFirst('Exception: ', '');
      throw Exception(msg);
    }
  }

  // ============ LOGOUT ============
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ============ RESET PASSWORD ============
  Future<void> resetPassword(String email) async {
    try {
      String resetEmail = email.trim();
      if (!resetEmail.contains('@')) {
        resetEmail = '$resetEmail@lycans.app';
      }
      await _auth.sendPasswordResetEmail(email: resetEmail);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    }
  }

  // ============ GET USER DATA ============
  Future<UserModel?> getUserData(String uid) async {
    try {
      final DataSnapshot snapshot = await _database
          .ref('${AppConstants.usersPath}/$uid')
          .get();

      if (snapshot.exists && snapshot.value != null) {
        return UserModel.fromMap(
            uid, Map<dynamic, dynamic>.from(snapshot.value as Map));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============ USER DATA STREAM ============
  Stream<UserModel?> getUserDataStream(String uid) {
    return _database
        .ref('${AppConstants.usersPath}/$uid')
        .onValue
        .map((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        return UserModel.fromMap(
            uid, Map<dynamic, dynamic>.from(snapshot.value as Map));
      }
      return null;
    });
  }

  // ============ PENDING / STATUS CHECK ============
  // Login ekranından önce çağrılabilir — kullanıcının durumunu döner.
  // 'active'  → users/{uid} var
  // 'pending' → pending_users/{uid} var, status pending
  // 'disabled'→ pending_users/{uid} var, status disabled
  // 'none'    → hiçbiri yok
  Future<String> checkUserStatus(String uid) async {
    try {
      final userSnap = await _database
          .ref('${AppConstants.usersPath}/$uid')
          .get();
      if (userSnap.exists) return 'active';

      final pendingSnap =
      await _database.ref('pending_users/$uid').get();
      if (pendingSnap.exists && pendingSnap.value != null) {
        final data =
        Map<dynamic, dynamic>.from(pendingSnap.value as Map);
        final status = (data['status'] ?? 'pending').toString();
        return status == 'disabled' ? 'disabled' : 'pending';
      }
      return 'none';
    } catch (_) {
      return 'none';
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this number.';
      case 'wrong-password':
        return 'Wrong password. Please try again.';
      case 'email-already-in-use':
        return 'Phone number is already registered.';
      case 'invalid-email':
        return 'Invalid phone format.';
      case 'weak-password':
        return 'Password is too weak. Minimum 6 characters required.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication error: $code';
    }
  }
}