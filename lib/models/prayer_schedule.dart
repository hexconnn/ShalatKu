
class PrayerSchedule {
  final String city;
  final String date;
  final List<PrayerTime> prayers;

  const PrayerSchedule({
    required this.city,
    required this.date,
    required this.prayers,
  });

  factory PrayerSchedule.fromJson(
      Map<String, dynamic> json, {
        required String city,
      }) {
    final data = json['data'] as Map<String, dynamic>;
    final timings = data['timings'] as Map<String, dynamic>;
    final dateData = data['date'] as Map<String, dynamic>;

    const prayerKeys = <(String, String)>[
      ('Subuh', 'Fajr'),
      ('Dzuhur', 'Dhuhr'),
      ('Ashar', 'Asr'),
      ('Maghrib', 'Maghrib'),
      ('Isya', 'Isha'),
    ];

    final prayers = prayerKeys.map((entry) {
      final rawTime = timings[entry.$2].toString();
      final cleanTime = rawTime.split(' ').first;

      return PrayerTime(
        name: entry.$1,
        time: cleanTime,
      );
    }).toList();

    return PrayerSchedule(
      city: city,
      date: dateData['readable'].toString(),
      prayers: prayers,
    );
  }
}

class PrayerTime {
  final String name;
  final String time;

  const PrayerTime({
    required this.name,
    required this.time,
  });

  int get hour => int.parse(time.split(':')[0]);

  int get minute => int.parse(time.split(':')[1]);

  DateTime onDate(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }
}
