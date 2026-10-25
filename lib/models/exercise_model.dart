class ExerciseModel {
  final String id;
  final String userId;
  final String name;
  final String weekNumber;
  final int sets;
  final int reps;
  final int rounds;
  final int durationMinutes;
  final int restSeconds;
  final bool isCompleted;
  final String category; // shadow, bag, core, sparring, conditioning
  final String coachNote;

  ExerciseModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.weekNumber,
    this.sets = 0,
    this.reps = 0,
    this.rounds = 0,
    this.durationMinutes = 0,
    this.restSeconds = 60,
    this.isCompleted = false,
    this.category = 'shadow',
    this.coachNote = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'weekNumber': weekNumber,
      'sets': sets,
      'reps': reps,
      'rounds': rounds,
      'durationMinutes': durationMinutes,
      'restSeconds': restSeconds,
      'isCompleted': isCompleted,
      'category': category,
      'coachNote': coachNote,
    };
  }

  factory ExerciseModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return ExerciseModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      weekNumber: map['weekNumber'] ?? '',
      sets: map['sets'] ?? 0,
      reps: map['reps'] ?? 0,
      rounds: map['rounds'] ?? 0,
      durationMinutes: map['durationMinutes'] ?? 0,
      restSeconds: map['restSeconds'] ?? 60,
      isCompleted: map['isCompleted'] ?? false,
      category: map['category'] ?? 'shadow',
      coachNote: map['coachNote'] ?? '',
    );
  }
}