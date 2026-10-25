import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
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
import '../utils/constants.dart';

class DatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Map<String, dynamic> _convertMap(Map<Object?, Object?> map) {
    return Map<String, dynamic>.from(map);
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _database.ref('${AppConstants.usersPath}/$uid').onValue.map((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        final data = _convertMap(snapshot.value as Map);
        return UserModel.fromMap(uid, data);
      }
      return null;
    });
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _database.ref('${AppConstants.usersPath}/$uid').update(data);
  }

  Stream<MembershipModel?> getMembershipStream(String userId) {
    return _database
        .ref(AppConstants.membershipsPath)
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .map((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        final map = _convertMap(snapshot.value as Map);
        final entries = map.entries.toList();
        if (entries.isNotEmpty) {
          entries.sort((a, b) {
            final aDate = DateTime.parse(a.value['endDate'] ?? DateTime.now().toIso8601String());
            final bDate = DateTime.parse(b.value['endDate'] ?? DateTime.now().toIso8601String());
            return bDate.compareTo(aDate);
          });
          return MembershipModel.fromMap(
            entries.first.key,
            entries.first.value as Map<dynamic, dynamic>,
          );
        }
      }
      return null;
    });
  }

  Future<void> renewMembership(String userId, MembershipModel currentMembership) async {
    final now = DateTime.now();
    final membershipRef = _database.ref(AppConstants.membershipsPath).push();

    await membershipRef.set({
      'id': membershipRef.key,
      'userId': userId,
      'planName': currentMembership.planName,
      'planType': currentMembership.planType,
      'price': currentMembership.price,
      'startDate': now.toIso8601String(),
      'endDate': now.add(Duration(days: currentMembership.durationDays)).toIso8601String(),
      'renewDate': now.add(Duration(days: currentMembership.durationDays)).toIso8601String(),
      'isActive': true,
      'isUnlimited': currentMembership.isUnlimited,
      'maxSessions': currentMembership.maxSessions,
      'usedSessions': 0,
      'packageId': currentMembership.packageId,
    });

    await _database.ref('${AppConstants.usersPath}/$userId').update({
      'membershipId': membershipRef.key,
    });

    final invoiceRef = _database.ref(AppConstants.invoicesPath).push();
    await invoiceRef.set({
      'id': invoiceRef.key,
      'userId': userId,
      'invoiceNumber': 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      'description': '${currentMembership.planName} — Renewal',
      'amount': currentMembership.price,
      'date': now.toIso8601String(),
      'isPaid': true,
      'paymentMethod': 'Cash',
    });
  }

  Stream<List<ClassModel>> getClassesStream() {
    return _database.ref(AppConstants.classesPath).onValue.map((event) {
      final snapshot = event.snapshot;
      final List<ClassModel> classes = [];
      if (snapshot.exists && snapshot.value != null) {
        final map = _convertMap(snapshot.value as Map);
        map.forEach((key, value) {
          classes.add(ClassModel.fromMap(key, _convertMap(value as Map)));
        });
      }
      classes.sort((a, b) => a.startTime.compareTo(b.startTime));
      return classes;
    });
  }

  Future<void> bookClass(String userId, String classId, ClassModel classModel) async {
    await _database.ref('${AppConstants.classesPath}/$classId').update({
      'bookedCount': classModel.bookedCount + 1,
    });

    final bookingRef = _database.ref('${AppConstants.schedulesPath}/$userId').push();
    await bookingRef.set({
      'id': bookingRef.key,
      'userId': userId,
      'classId': classId,
      'className': classModel.className,
      'coachName': classModel.coachName,
      'location': classModel.location,
      'startTime': classModel.startTime.toIso8601String(),
      'endTime': classModel.endTime.toIso8601String(),
      'isBooked': true,
      'bookedAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<ClassModel>> getBookedClassesStream(String userId) {
    return _database.ref('${AppConstants.schedulesPath}/$userId').onValue.map((event) {
      final snapshot = event.snapshot;
      final List<ClassModel> classes = [];
      if (snapshot.exists && snapshot.value != null) {
        final map = _convertMap(snapshot.value as Map);
        map.forEach((key, value) {
          final data = _convertMap(value as Map);
          classes.add(ClassModel(
            id: data['classId'] ?? key,
            className: data['className'] ?? '',
            coachName: data['coachName'] ?? '',
            location: data['location'] ?? '',
            startTime: DateTime.parse(data['startDate'] ?? DateTime.now().toIso8601String()),
            endTime: DateTime.parse(data['endDate'] ?? DateTime.now().toIso8601String()),
            isBooked: data['isBooked'] ?? false,
          ));
        });
      }
      classes.sort((a, b) => a.startTime.compareTo(b.startTime));
      return classes;
    });
  }

  Stream<List<FightModel>> getFightsStream(String userId) {
    return _database.ref(AppConstants.fightsPath).orderByChild('userId').equalTo(userId).onValue.map((event) {
      final snapshot = event.snapshot;
      final List<FightModel> fights = [];
      if (snapshot.exists && snapshot.value != null) {
        final map = _convertMap(snapshot.value as Map);
        map.forEach((key, value) {
          fights.add(FightModel.fromMap(key, _convertMap(value as Map)));
        });
      }
      fights.sort((a, b) => b.fightDate.compareTo(a.fightDate));
      return fights;
    });
  }

  Future<void> addFight(FightModel fight) async {
    final fightRef = _database.ref(AppConstants.fightsPath).push();
    await fightRef.set(fight.toMap());
  }

  Future<void> updateFightResult(String fightId, String result, String winType) async {
    await _database.ref('${AppConstants.fightsPath}/$fightId').update({
      'result': result,
      'winType': winType,
      'isUpcoming': false,
    });
  }

  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _database.ref(AppConstants.notificationsPath).orderByChild('userId').equalTo(userId).onValue.map((event) {
      final snapshot = event.snapshot;
      final List<NotificationModel> notifications = [];
      if (snapshot.exists && snapshot.value != null) {
        final map = _convertMap(snapshot.value as Map);
        map.forEach((key, value) {
          notifications.add(NotificationModel.fromMap(key, _convertMap(value as Map)));
        });
      }
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return notifications;
    });
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _database.ref('${AppConstants.notificationsPath}/$notificationId').update({'isRead': true});
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    final snapshot = await _database.ref(AppConstants.notificationsPath).orderByChild('userId').equalTo(userId).get();
    if (snapshot.exists && snapshot.value != null) {
      final map = _convertMap(snapshot.value as Map);
      map.forEach((key, value) async {
        await _database.ref('${AppConstants.notificationsPath}/$key').update({'isRead': true});
      });
    }
  }

  Stream<List<InvoiceModel>> getInvoicesStream(String userId) {
    return _database.ref(AppConstants.invoicesPath).orderByChild('userId').equalTo(userId).onValue.map((event) {
      final snapshot = event.snapshot;
      final List<InvoiceModel> invoices = [];
      if (snapshot.exists && snapshot.value != null) {
        final map = _convertMap(snapshot.value as Map);
        map.forEach((key, value) {
          invoices.add(InvoiceModel.fromMap(key, _convertMap(value as Map)));
        });
      }
      invoices.sort((a, b) => b.date.compareTo(a.date));
      return invoices;
    });
  }

  Stream<List<ExerciseModel>> getExercisesStream(String userId) {
    return _database.ref(AppConstants.exercisesPath).orderByChild('userId').equalTo(userId).onValue.map((event) {
      final snapshot = event.snapshot;
      final List<ExerciseModel> exercises = [];
      if (snapshot.exists && snapshot.value != null) {
        final map = _convertMap(snapshot.value as Map);
        map.forEach((key, value) {
          exercises.add(ExerciseModel.fromMap(key, _convertMap(value as Map)));
        });
      }
      return exercises;
    });
  }

  Future<void> toggleExerciseCompletion(String exerciseId, bool isCompleted) async {
    await _database.ref('${AppConstants.exercisesPath}/$exerciseId').update({'isCompleted': isCompleted});
  }

  Stream<ProgressModel?> getProgressStream(String userId) {
    return _database.ref(AppConstants.progressPath).orderByChild('userId').equalTo(userId).onValue.map((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        final map = _convertMap(snapshot.value as Map);
        final entries = map.entries.toList();
        if (entries.isNotEmpty) {
          entries.sort((a, b) {
            final aDate = DateTime.parse(a.value['lastTestDate'] ?? DateTime.now().toIso8601String());
            final bDate = DateTime.parse(b.value['lastTestDate'] ?? DateTime.now().toIso8601String());
            return bDate.compareTo(aDate);
          });
          return ProgressModel.fromMap(entries.first.key, _convertMap(entries.first.value as Map));
        }
      }
      return null;
    });
  }

  Future<void> updateProgress(String progressId, Map<String, dynamic> data) async {
    await _database.ref('${AppConstants.progressPath}/$progressId').update(data);
  }

  // ============ ATTENDANCE METHODS ============
  Future<void> checkIn({
    required String userId,
    required String classId,
    required String className,
  }) async {
    final now = DateTime.now();

    // Check-in kaydı oluştur
    final checkInRef = _database.ref(AppConstants.checkInsPath).push();
    await checkInRef.set({
      'id': checkInRef.key,
      'userId': userId,
      'classId': classId,
      'className': className,
      'timestamp': now.toIso8601String(),
      'date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
    });

    // Attendance kaydı
    final attendanceRef = _database.ref('${AppConstants.attendancePath}/$userId').push();
    await attendanceRef.set({
      'id': attendanceRef.key,
      'userId': userId,
      'classId': classId,
      'className': className,
      'date': now.toIso8601String(),
    });

    // ===== USED SESSIONS +1 İŞLEMİ =====
    // Kullanıcının membership'ini bul (userId ile)
    final membershipSnapshot = await _database
        .ref(AppConstants.membershipsPath)
        .orderByChild('userId')
        .equalTo(userId)
        .get();

    debugPrint('=== SESSION UPDATE ===');
    debugPrint('User ID: $userId');
    debugPrint('Membership exists: ${membershipSnapshot.exists}');

    if (membershipSnapshot.exists && membershipSnapshot.value != null) {
      final membershipsMap = _convertMap(membershipSnapshot.value as Map);
      final entries = membershipsMap.entries.toList();

      // En güncel membership'i bul (endDate'e göre sırala)
      entries.sort((a, b) {
        final aDate = DateTime.parse(a.value['endDate'] ?? DateTime.now().toIso8601String());
        final bDate = DateTime.parse(b.value['endDate'] ?? DateTime.now().toIso8601String());
        return bDate.compareTo(aDate);
      });

      final membershipId = entries.first.key;
      final membershipData = _convertMap(entries.first.value as Map);

      debugPrint('Membership ID: $membershipId');
      debugPrint('Plan Name: ${membershipData['planName']}');
      debugPrint('isUnlimited: ${membershipData['isUnlimited']}');
      debugPrint('Current usedSessions: ${membershipData['usedSessions']}');
      debugPrint('maxSessions: ${membershipData['maxSessions']}');

      final bool isUnlimited = membershipData['isUnlimited'] ?? true;
      final int currentUsedSessions = (membershipData['usedSessions'] as num?)?.toInt() ?? 0;
      final int maxSessions = (membershipData['maxSessions'] as num?)?.toInt() ?? 0;

      // Unlimited değilse usedSessions'ı artır
      if (!isUnlimited) {
        final int newUsedSessions = currentUsedSessions + 1;

        debugPrint('New usedSessions: $newUsedSessions');

        await _database.ref('${AppConstants.membershipsPath}/$membershipId').update({
          'usedSessions': newUsedSessions,
        });

        debugPrint('usedSessions updated to: $newUsedSessions');
      } else {
        debugPrint('Unlimited membership - no session tracking');
      }
    } else {
      debugPrint('No membership found for user: $userId');
    }
    debugPrint('=== END SESSION UPDATE ===');
  }

  Stream<List<Map<String, dynamic>>> getCheckInsStream(String userId) {
    return _database
        .ref(AppConstants.checkInsPath)
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .map((event) {
      final snapshot = event.snapshot;
      final List<Map<String, dynamic>> checkIns = [];
      if (snapshot.exists && snapshot.value != null) {
        final map = _convertMap(snapshot.value as Map);
        map.forEach((key, value) {
          checkIns.add(_convertMap(value as Map));
        });
      }
      checkIns.sort((a, b) => DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));
      return checkIns;
    });
  }

  Stream<List<BranchModel>> getBranchesStream() {
    return _database.ref(AppConstants.branchesPath).onValue.map((event) {
      final snapshot = event.snapshot;
      final List<BranchModel> branches = [];
      if (snapshot.exists && snapshot.value != null) {
        final map = _convertMap(snapshot.value as Map);
        map.forEach((key, value) {
          branches.add(BranchModel.fromMap(key, _convertMap(value as Map)));
        });
      }
      // Sadece aktif branch'ler
      final active = branches.where((b) => b.isActive).toList();
      active.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return active;
    });
  }

  // ============ PACKAGE & SUBSCRIPTION METHODS ============
  // ============ PACKAGES & SUBSCRIPTIONS ============
  Stream<List<PackageModel>> getPackagesStream() {
    return _database.ref(AppConstants.packagesPath).onValue.map((event) {
      final snapshot = event.snapshot;
      final List<PackageModel> packages = [];

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value;

        if (data is Map) {
          final map = _convertMap(data);
          map.forEach((key, value) {
            if (value is Map) {
              packages.add(PackageModel.fromMap(key, _convertMap(value)));
            }
          });
        }
      }

      // Sıralama: Önce fiyata göre
      packages.sort((a, b) => a.price.compareTo(b.price));

      return packages;
    });
  }

  // database_service.dart içindeki subscribeToPackage metodu
  Future<void> subscribeToPackage({
    required String userId,
    required String packageId,
    required String packageName,
    required double price,
    required int durationDays,
    required bool isUnlimited,
    required int maxSessions,
    required int weeklySessions,
  }) async {
    final now = DateTime.now();

    final membershipRef = _database.ref(AppConstants.membershipsPath).push();
    final newMembershipId = membershipRef.key;

    await membershipRef.set({
      'id': newMembershipId,
      'userId': userId,
      'planName': packageName,
      'planType': packageName,
      'price': price,
      'startDate': now.toIso8601String(),
      'endDate': now.add(Duration(days: durationDays)).toIso8601String(),
      'renewDate': now.add(Duration(days: durationDays)).toIso8601String(),
      'isActive': true,
      'isUnlimited': isUnlimited,
      'maxSessions': maxSessions,
      'usedSessions': 0,
      'durationDays': durationDays,
      'packageId': packageId,
      'weeklySessions': weeklySessions,
    });

    await _database.ref('${AppConstants.usersPath}/$userId').update({
      'membershipId': newMembershipId,
      'currentPackageId': packageId,
    });

    final invoiceRef = _database.ref(AppConstants.invoicesPath).push();
    await invoiceRef.set({
      'id': invoiceRef.key,
      'userId': userId,
      'invoiceNumber': 'INV-${now.millisecondsSinceEpoch.toString().substring(5)}',
      'description': '$packageName — $durationDays Days',
      'amount': price,
      'date': now.toIso8601String(),
      'isPaid': true,
      'paymentMethod': 'Card',
    });
  }

  Future<String> createPlanRequest(PlanRequestModel request) async {
    final ref = _database.ref(AppConstants.planRequestsPath).push();
    final newId = ref.key ?? DateTime.now().millisecondsSinceEpoch.toString();
    await ref.set(request.copyWith(id: newId).toMap());
    return newId;
  }

  Stream<List<PlanRequestModel>> getMyPlanRequestsStream(String userId) {
    return _database
        .ref(AppConstants.planRequestsPath)
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .map((event) {
      final snapshot = event.snapshot;
      final List<PlanRequestModel> requests = [];
      if (snapshot.exists && snapshot.value != null) {
        final map = _convertMap(snapshot.value as Map);
        map.forEach((key, value) {
          final r = PlanRequestModel.fromMap(key, _convertMap(value as Map));
          // Sadece pending olanlar
          if (r.status == 'pending') requests.add(r);
        });
      }
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  // ============ DAILY COMBOS ============
  Stream<List<Map<String, dynamic>>> getDailyCombosStream() {
    // Eğer oyuncu uygulamasında AppConstants.dailyCombosPath tanımlıysa onu kullan,
    // yoksa direkt 'daily_combos' string'ini kullanabilirsin.
    return _database.ref(AppConstants.dailyCombosPath).onValue.map((event) {
      final snapshot = event.snapshot;
      final List<Map<String, dynamic>> combos = [];

      if (snapshot.exists && snapshot.value != null) {
        final map = _convertMap(snapshot.value as Map);
        map.forEach((key, value) {
          final data = _convertMap(value as Map);
          data['id'] = key;
          combos.add(data);
        });
      }

      // Tarihe göre yeniden eskiye sırala
      combos.sort((a, b) {
        final aDate = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.now();
        final bDate = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime.now();
        return bDate.compareTo(aDate);
      });

      return combos;
    });
  }
}