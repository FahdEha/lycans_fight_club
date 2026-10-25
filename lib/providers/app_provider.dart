import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // YENİ
import '../models/PlanRequestModel.dart';
import '../models/branch_model.dart';
import '../models/package_model.dart';
import '../models/user_model.dart';
import '../models/membership_model.dart';
import '../models/class_model.dart';
import '../models/fight_model.dart';
import '../models/notification_model.dart';
import '../models/invoice_model.dart';
import '../models/exercise_model.dart';
import '../models/progress_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  User? _firebaseUser;
  UserModel? _userData;
  MembershipModel? _membership;
  List<ClassModel> _classes = [];
  List<ClassModel> _bookedClasses = [];
  List<FightModel> _fights = [];
  List<NotificationModel> _notifications = [];
  List<InvoiceModel> _invoices = [];
  List<ExerciseModel> _exercises = [];
  ProgressModel? _progress;
  List<Map<String, dynamic>> _checkIns = [];
  List<PackageModel> _packages = [];
  List<BranchModel> _branches = [];
  List<PlanRequestModel> _myPlanRequests = [];
  List<Map<String, dynamic>> _dailyCombos = [];

  // Getters
  User? get firebaseUser => _firebaseUser;
  UserModel? get userData => _userData;
  MembershipModel? get membership => _membership;
  List<ClassModel> get classes => _classes;
  List<ClassModel> get bookedClasses => _bookedClasses;
  List<FightModel> get fights => _fights;
  List<NotificationModel> get notifications => _notifications;
  List<InvoiceModel> get invoices => _invoices;
  List<ExerciseModel> get exercises => _exercises;
  ProgressModel? get progress => _progress;
  List<Map<String, dynamic>> get checkIns => _checkIns;
  List<PackageModel> get packages => _packages;
  List<BranchModel> get branches => _branches;
  List<PlanRequestModel> get myPlanRequests => _myPlanRequests;
  List<Map<String, dynamic>> get dailyCombos => _dailyCombos;

  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  // ============ INITIALIZE ============
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _authService.authStateChanges.listen((user) async {
      _firebaseUser = user;

      if (user == null) {
        // Logged out
        _isAuthenticated = false;
        _clearAllData();
        _isLoading = false;
        notifyListeners();
        return;
      }

      // users/{uid} kontrolü
      final userData = await _authService.getUserData(user.uid);

      if (userData == null) {
        // users/{uid} yok → pending veya disabled olabilir
        final pendingSnap =
        await FirebaseDatabase.instance.ref('pending_users/${user.uid}').get();

        String msg = 'Your account is pending admin approval.';
        if (pendingSnap.exists && pendingSnap.value != null) {
          final data = Map<dynamic, dynamic>.from(pendingSnap.value as Map);
          if (data['status'] == 'disabled') {
            msg = 'Your account has been disabled by admin.';
          }
        }

        _error = msg;
        await _authService.logout();
        _firebaseUser = null;
        _isAuthenticated = false;
        _clearAllData();
        _isLoading = false;
        notifyListeners();
        return;
      }

      // === NORMAL AKIŞ — userData var ===
      _userData = userData;
      _isAuthenticated = true;
      _error = null;
      _isLoading = false;
      notifyListeners();

      _loadAllUserData(user.uid);
    });
  }

  // ============ LOAD ALL USER DATA ============
  void _loadAllUserData(String uid) {
    _authService.getUserDataStream(uid).listen((user) {
      _userData = user;
      if (user == null) {
        // Kullanıcı silinmiş
        logout();
      } else {
        notifyListeners();
      }
    });

    _databaseService.getMembershipStream(uid).listen((membership) {
      _membership = membership;
      notifyListeners();
    });

    _databaseService.getClassesStream().listen((classes) {
      _classes = classes;
      notifyListeners();
    });

    _databaseService.getBookedClassesStream(uid).listen((classes) {
      _bookedClasses = classes;
      notifyListeners();
    });

    _databaseService.getFightsStream(uid).listen((fights) {
      _fights = fights;
      notifyListeners();
    });

    _databaseService.getNotificationsStream(uid).listen((notifications) {
      _notifications = notifications;
      notifyListeners();
    });

    _databaseService.getInvoicesStream(uid).listen((invoices) {
      _invoices = invoices;
      notifyListeners();
    });

    _databaseService.getExercisesStream(uid).listen((exercises) {
      _exercises = exercises;
      notifyListeners();
    });

    _databaseService.getProgressStream(uid).listen((progress) {
      _progress = progress;
      notifyListeners();
    });

    _databaseService.getCheckInsStream(uid).listen((checkIns) {
      _checkIns = checkIns;
      notifyListeners();
    });

    _databaseService.getPackagesStream().listen((packages) {
      _packages = packages;
      notifyListeners();
    });

    _databaseService.getBranchesStream().listen((branches) {
      _branches = branches;
      notifyListeners();
    });

    _databaseService.getMyPlanRequestsStream(uid).listen((requests) {
      _myPlanRequests = requests;
      notifyListeners();
    });

    _databaseService.getDailyCombosStream().listen((combos) {
      _dailyCombos = combos;
      notifyListeners();
    });
  }

  // Pending check
  bool hasPendingRequestFor(String packageId) {
    return _myPlanRequests.any((r) => r.requestedPackageId == packageId);
  }

  // ============ CLEAR ALL DATA ============
  void _clearAllData() {
    _userData = null;
    _membership = null;
    _classes = [];
    _bookedClasses = [];
    _fights = [];
    _notifications = [];
    _invoices = [];
    _exercises = [];
    _progress = null;
    _checkIns = [];
    _packages = [];
    _branches = [];          // YENİ
    _myPlanRequests = [];    // YENİ
  }

  // ============ LOGIN ============
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.loginUser(email: email, password: password);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _isLoading = false;
    notifyListeners();
  }

  // ============ REGISTER ============
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String sport,
    required String level,
    required String weightClass,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.registerUser(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        sport: sport,
        level: level,
        weightClass: weightClass,
      );
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _isLoading = false;
    notifyListeners();
  }

  // ============ LOGOUT ============
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _authService.logout();
    _firebaseUser = null;
    _isAuthenticated = false;
    _clearAllData();
    _isLoading = false;
    notifyListeners();
  }

  // ============ RESET PASSWORD ============
  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _isLoading = false;
    notifyListeners();
  }

  // ============ GET USER DATA (public helper) ============
  Future<UserModel?> getUserData(String uid) async {
    try {
      final user = await _authService.getUserData(uid);
      if (user != null) {
        _userData = user;
        notifyListeners();
      }
      return user;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<String> checkUserStatus(String uid) async {
    return _authService.checkUserStatus(uid);
  }

  // ============ MEMBERSHIP ============
  Future<void> renewMembership() async {
    if (_userData == null || _membership == null) return;
    _isLoading = true;
    notifyListeners();
    await _databaseService.renewMembership(_userData!.uid, _membership!);
    _isLoading = false;
    notifyListeners();
  }

  // ============ BOOK CLASS ============
  Future<void> bookClass(ClassModel classModel) async {
    if (_userData == null) return;
    _isLoading = true;
    notifyListeners();
    await _databaseService.bookClass(
        _userData!.uid, classModel.id, classModel);
    _isLoading = false;
    notifyListeners();
  }

  // ============ EXERCISES ============
  Future<void> toggleExercise(String exerciseId, bool isCompleted) async {
    await _databaseService.toggleExerciseCompletion(exerciseId, isCompleted);
  }

  // ============ NOTIFICATIONS ============
  Future<void> markNotificationRead(String notificationId) async {
    await _databaseService.markNotificationAsRead(notificationId);
  }

  Future<void> markAllNotificationsRead() async {
    if (_userData == null) return;
    await _databaseService.markAllNotificationsAsRead(_userData!.uid);
  }

  // ============ REMAINING SESSIONS ============
  int get remainingSessions {
    if (_membership == null) return 0;
    if (_membership!.isUnlimited) return 0;
    return _membership!.remainingSessions;
  }

  // ============ CHECK IN ============
  Future<void> checkIn(String classId, String className) async {
    if (_userData == null) return;

    await _databaseService.checkIn(
      userId: _userData!.uid,
      classId: classId,
      className: className,
    );

    notifyListeners();
  }

  // ============ UPDATE USER ============
  Future<void> updateUserData(Map<String, dynamic> data) async {
    if (_userData == null) return;
    await _databaseService.updateUser(_userData!.uid, data);
  }

  Future<void> updateProgressData(Map<String, dynamic> data) async {
    if (_progress == null) return;
    await _databaseService.updateProgress(_progress!.id, data);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ============ SUBSCRIBE TO PACKAGE ============
  Future<void> subscribeToPackage(
      String packageId,
      String packageName,
      double price,
      int durationDays, {
        bool isUnlimited = true,
        int maxSessions = 0,
        int weeklySessions = 0,
      }) async {
    if (_userData == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.subscribeToPackage(
        userId: _userData!.uid,
        packageId: packageId,
        packageName: packageName,
        price: price,
        durationDays: durationDays,
        isUnlimited: isUnlimited,
        maxSessions: maxSessions,
        weeklySessions: weeklySessions,
      );
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ============ REQUEST PLAN CHANGE ============
  Future<void> requestPlanChange({
    required PackageModel requestedPackage,
    required String type,
  }) async {
    if (_userData == null) return;

    final currentPkg = _membership;
    final request = PlanRequestModel(
      id: '',
      userId: _userData!.uid,
      playerName: _userData!.fullName,
      currentPackageId: currentPkg?.packageId ?? '',
      currentPackageName: currentPkg?.planName ?? '',
      currentPackagePrice: currentPkg?.price ?? 0,
      requestedPackageId: requestedPackage.id,
      requestedPackageName: requestedPackage.name,
      requestedPackagePrice: requestedPackage.price,
      requestedPackageDurationDays: requestedPackage.durationDays,
      requestedIsUnlimited: requestedPackage.isUnlimited,
      requestedMaxSessions: requestedPackage.maxSessions,
      requestedWeeklySessions: requestedPackage.weeklySessions,
      type: type,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await _databaseService.createPlanRequest(request);
  }
}