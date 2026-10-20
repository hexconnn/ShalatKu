
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/prayer_schedule.dart';

class PrayerService {
  final http.Client client;

  PrayerService({http.Client? client})
      : client = client ?? http.Client();

  Future<PrayerSchedule> fetchSchedule({
    required String city,
    required DateTime date,
    String country = 'Indonesia',
  }) async {
    final dateString =
        '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';

    final uri = Uri.https(
      'api.aladhan.com',
      '/v1/timingsByCity/$dateString',
      {
        'city': city,
        'country': country,
        'method': '20',
      },
    );

    final response = await client
        .get(uri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil jadwal. HTTP ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic> ||
        decoded['code'] != 200 ||
        decoded['data'] == null) {
      throw Exception('Respons API tidak valid.');
    }

    return PrayerSchedule.fromJson(
      decoded,
      city: city,
    );
  }

  void dispose() {
    client.close();
  }
}
