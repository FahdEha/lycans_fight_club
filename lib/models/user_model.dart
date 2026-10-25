class UserModel {
  final String uid;
  final String fullName;
  final String phone;
  final String email;
  final String sport;
  final String level;
  final String weightClass;
  final String emergencyContact;
  final String emergencyPhone;
  final String guardian;
  final String membershipId;
  final String currentPackageId; // YENİ - Oyuncunun aktif paketi
  final String rank;
  final int wins;
  final int losses;
  final int draws;
  final int winsByKO;
  final int winsByDecision;
  final DateTime joinDate;
  final double weight;
  final double height;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.sport,
    required this.level,
    required this.weightClass,
    required this.emergencyContact,
    required this.emergencyPhone,
    this.guardian = 'Not applicable',
    this.membershipId = '',
    this.currentPackageId = '', // Varsayılan boş
    this.rank = '01',
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.winsByKO = 0,
    this.winsByDecision = 0,
    required this.joinDate,
    this.weight = 0,
    this.height = 0,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'sport': sport,
      'level': level,
      'weightClass': weightClass,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'guardian': guardian,
      'membershipId': membershipId,
      'currentPackageId': currentPackageId, // YENİ
      'rank': rank,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'winsByKO': winsByKO,
      'winsByDecision': winsByDecision,
      'joinDate': joinDate.toIso8601String(),
      'weight': weight,
      'height': height,
      'isActive': isActive,
    };
  }

  factory UserModel.fromMap(String uid, Map<dynamic, dynamic> map) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      sport: map['sport'] ?? '',
      level: map['level'] ?? '',
      weightClass: map['weightClass'] ?? '',
      emergencyContact: map['emergencyContact'] ?? '',
      emergencyPhone: map['emergencyPhone'] ?? '',
      guardian: map['guardian'] ?? 'Not applicable',
      membershipId: map['membershipId']?.toString() ?? '',
      currentPackageId: map['currentPackageId']?.toString() ?? '', // YENİ
      rank: map['rank']?.toString() ?? '01',
      wins: (map['wins'] as num?)?.toInt() ?? 0,
      losses: (map['losses'] as num?)?.toInt() ?? 0,
      draws: (map['draws'] as num?)?.toInt() ?? 0,
      winsByKO: (map['winsByKO'] as num?)?.toInt() ?? 0,
      winsByDecision: (map['winsByDecision'] as num?)?.toInt() ?? 0,
      joinDate: DateTime.parse(map['joinDate'] ?? DateTime.now().toIso8601String()),
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      height: (map['height'] as num?)?.toDouble() ?? 0.0,
      isActive: map['isActive'] ?? true,
    );
  }

  String get initials {
    if (fullName.isEmpty) return '??';
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.substring(0, 2).toUpperCase();
  }
}