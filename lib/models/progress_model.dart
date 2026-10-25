class ProgressModel {
  final String id;
  final String userId;
  final double weight;
  final double height;
  final double speedScore;
  final double powerScore;
  final double vo2Score;
  final double punchForce;
  final double flexibilityScore;
  final Map<String, int> weeklyAttendance;
  final DateTime lastTestDate;
  final List<FitnessTestResult> testResults;

  ProgressModel({
    required this.id,
    required this.userId,
    this.weight = 0,
    this.height = 0,
    this.speedScore = 0,
    this.powerScore = 0,
    this.vo2Score = 0,
    this.punchForce = 0,
    this.flexibilityScore = 0,
    this.weeklyAttendance = const {},
    required this.lastTestDate,
    this.testResults = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'weight': weight,
      'height': height,
      'speedScore': speedScore,
      'powerScore': powerScore,
      'vo2Score': vo2Score,
      'punchForce': punchForce,
      'flexibilityScore': flexibilityScore,
      'weeklyAttendance': weeklyAttendance,
      'lastTestDate': lastTestDate.toIso8601String(),
      'testResults': testResults.map((t) => t.toMap()).toList(),
    };
  }

  factory ProgressModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return ProgressModel(
      id: id,
      userId: map['userId'] ?? '',
      weight: (map['weight'] ?? 0).toDouble(),
      height: (map['height'] ?? 0).toDouble(),
      speedScore: (map['speedScore'] ?? 0).toDouble(),
      powerScore: (map['powerScore'] ?? 0).toDouble(),
      vo2Score: (map['vo2Score'] ?? 0).toDouble(),
      punchForce: (map['punchForce'] ?? 0).toDouble(),
      flexibilityScore: (map['flexibilityScore'] ?? 0).toDouble(),
      weeklyAttendance: Map<String, int>.from(map['weeklyAttendance'] ?? {}),
      lastTestDate: DateTime.parse(map['lastTestDate'] ?? DateTime.now().toIso8601String()),
      testResults: (map['testResults'] as List? ?? [])
          .map((t) => FitnessTestResult.fromMap(t))
          .toList(),
    );
  }
}

class FitnessTestResult {
  final String testName;
  final String result;
  final String unit;
  final double improvementPercent;
  final DateTime testDate;

  FitnessTestResult({
    required this.testName,
    required this.result,
    required this.unit,
    required this.improvementPercent,
    required this.testDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'testName': testName,
      'result': result,
      'unit': unit,
      'improvementPercent': improvementPercent,
      'testDate': testDate.toIso8601String(),
    };
  }

  factory FitnessTestResult.fromMap(Map<dynamic, dynamic> map) {
    return FitnessTestResult(
      testName: map['testName'] ?? '',
      result: map['result'] ?? '',
      unit: map['unit'] ?? '',
      improvementPercent: (map['improvementPercent'] ?? 0).toDouble(),
      testDate: DateTime.parse(map['testDate'] ?? DateTime.now().toIso8601String()),
    );
  }
}