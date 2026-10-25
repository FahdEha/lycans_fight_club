class FightModel {
  final String id;
  final String userId;
  final String opponentName;
  final String eventName;
  final String eventType;
  final DateTime fightDate;
  final String result; // win, loss, draw, upcoming
  final String winType; // KO, Decision
  final int round;
  final double userWeight;
  final double opponentWeight;
  final String weightClass;
  final bool isUpcoming;
  final String venue;

  FightModel({
    required this.id,
    required this.userId,
    required this.opponentName,
    required this.eventName,
    required this.eventType,
    required this.fightDate,
    this.result = 'upcoming',
    this.winType = '',
    this.round = 0,
    this.userWeight = 0,
    this.opponentWeight = 0,
    this.weightClass = '',
    this.isUpcoming = false,
    this.venue = '',
  });

  int get daysUntil => fightDate.difference(DateTime.now()).inDays;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'opponentName': opponentName,
      'eventName': eventName,
      'eventType': eventType,
      'fightDate': fightDate.toIso8601String(),
      'result': result,
      'winType': winType,
      'round': round,
      'userWeight': userWeight,
      'opponentWeight': opponentWeight,
      'weightClass': weightClass,
      'isUpcoming': isUpcoming,
      'venue': venue,
    };
  }

  factory FightModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return FightModel(
      id: id,
      userId: map['userId'] ?? '',
      opponentName: map['opponentName'] ?? '',
      eventName: map['eventName'] ?? '',
      eventType: map['eventType'] ?? '',
      fightDate: DateTime.parse(map['fightDate'] ?? DateTime.now().toIso8601String()),
      result: map['result'] ?? 'upcoming',
      winType: map['winType'] ?? '',
      round: map['round'] ?? 0,
      userWeight: (map['userWeight'] ?? 0).toDouble(),
      opponentWeight: (map['opponentWeight'] ?? 0).toDouble(),
      weightClass: map['weightClass'] ?? '',
      isUpcoming: map['isUpcoming'] ?? false,
      venue: map['venue'] ?? '',
    );
  }
}