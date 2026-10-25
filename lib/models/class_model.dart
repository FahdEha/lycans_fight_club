class ClassModel {
  final String id;
  final String className;
  final String coachName;
  final String branch;      // ← Bu olmalı
  final String branchId;    // ← Bu olmalı
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final int bookedCount;
  final String level;
  final String sport;
  final int duration;
  final String schedule;
  final String timeStr;
  final bool isBooked;
  final String whatsappGroupUrl; // YENİ

  ClassModel({
    required this.id,
    required this.className,
    required this.coachName,
    this.branch = '',      // ← Varsayılan boş
    this.branchId = '',    // ← Varsayılan boş
    this.location = '',
    required this.startTime,
    required this.endTime,
    this.capacity = 20,
    this.bookedCount = 0,
    this.level = 'All',
    this.sport = 'Kickboxing',
    this.duration = 60,
    this.schedule = '',
    this.timeStr = '',
    this.isBooked = false,
    this.whatsappGroupUrl = '', // YENİ
  });

  // schedule alanından günleri çıkar
  List<String> get scheduleDays {
    if (schedule.isEmpty) return [];
    if (schedule == 'Daily') return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final parts = schedule.split('·');
    return parts.map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
  }

  double get fillPercent {
    if (capacity == 0) return 0;
    return bookedCount / capacity;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'className': className,
      'coachName': coachName,
      'branch': branch,
      'branchId': branchId,
      'location': location,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'capacity': capacity,
      'bookedCount': bookedCount,
      'level': level,
      'sport': sport,
      'duration': duration,
      'schedule': schedule,
      'timeStr': timeStr,
      'isBooked': isBooked,
      'whatsappGroupUrl': whatsappGroupUrl, // YENİ
    };
  }

  factory ClassModel.fromMap(String id, Map<String, dynamic> map) {
    return ClassModel(
      id: id,
      className: map['className']?.toString() ?? '',
      coachName: map['coachName']?.toString() ?? '',
      branch: map['branch']?.toString() ?? '',
      branchId: map['branchId']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      startTime: DateTime.parse(map['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(map['endTime'] ?? DateTime.now().toIso8601String()),
      capacity: (map['capacity'] as num?)?.toInt() ?? 20,
      bookedCount: (map['bookedCount'] as num?)?.toInt() ?? 0,
      level: map['level']?.toString() ?? 'All',
      sport: map['sport']?.toString() ?? 'Kickboxing',
      duration: (map['duration'] as num?)?.toInt() ?? 60,
      schedule: map['schedule']?.toString() ?? '',
      timeStr: map['timeStr']?.toString() ?? '',
      isBooked: map['isBooked'] == true,
      whatsappGroupUrl: map['whatsappGroupUrl']?.toString() ?? '', // YENİ
    );
  }
}