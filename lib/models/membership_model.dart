class MembershipModel {
  final String id;
  final String userId;
  final String planName;
  final String planType;
  final double price;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime renewDate;
  final bool isActive;
  final bool isUnlimited;
  final int maxSessions;
  final int usedSessions;
  final int durationDays;
  final String packageId;
  final int weeklySessions;
  final String groupId;
  final String groupName;

  MembershipModel({
    required this.id,
    required this.userId,
    required this.planName,
    required this.planType,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.renewDate,
    this.isActive = true,
    this.isUnlimited = true,
    this.maxSessions = 0,
    this.usedSessions = 0,
    this.durationDays = 30,
    this.packageId = '',
    this.weeklySessions = 0,
    this.groupId = '',
    this.groupName = '',
  });

  int get daysLeft {
    final now = DateTime.now();
    if (endDate.isBefore(now)) return 0;
    return endDate.difference(now).inDays;
  }

  // Kalan seans sayısı
  int get remainingSessions {
    if (isUnlimited) return 0;
    return (maxSessions - usedSessions).clamp(0, maxSessions);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'planName': planName,
      'planType': planType,
      'price': price,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'renewDate': renewDate.toIso8601String(),
      'isActive': isActive,
      'isUnlimited': isUnlimited,
      'maxSessions': maxSessions,
      'usedSessions': usedSessions,
      'durationDays': durationDays,
      'packageId': packageId,
      'weeklySessions': weeklySessions,
      'groupId': groupId,
      'groupName': groupName,
    };
  }

  factory MembershipModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return MembershipModel(
      id: id,
      userId: map['userId']?.toString() ?? '',
      planName: map['planName']?.toString() ?? '',
      planType: map['planType']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.parse(map['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(map['endDate'] ?? DateTime.now().toIso8601String()),
      renewDate: DateTime.parse(map['renewDate'] ?? DateTime.now().toIso8601String()),
      isActive: map['isActive'] ?? true,
      isUnlimited: map['isUnlimited'] ?? true,
      maxSessions: (map['maxSessions'] as num?)?.toInt() ?? 0,
      usedSessions: (map['usedSessions'] as num?)?.toInt() ?? 0,
      durationDays: (map['durationDays'] as num?)?.toInt() ?? 30,
      packageId: map['packageId']?.toString() ?? '',
      weeklySessions: (map['weeklySessions'] as num?)?.toInt() ?? 0,
      groupId: map['groupId']?.toString() ?? '',
      groupName: map['groupName']?.toString() ?? '',
    );
  }
}