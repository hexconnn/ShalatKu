
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/prayer_schedule.dart';
import '../services/prayer_service.dart';
import '../services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _service = PrayerService();
  final _notifications = NotificationService();

  int _selectedTab = 2;
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());

  String _city = 'Malang';
  bool _remindersEnabled = true;

  late Future<PrayerSchedule> _scheduleFuture;

  bool get _isToday =>
      DateUtils.isSameDay(_selectedDate, DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  void _loadSchedule() {
    final requestedDate = _selectedDate;
    final requestedCity = _city;

    _scheduleFuture = _service.fetchSchedule(
      city: requestedCity,
      date: requestedDate,
    );

    _scheduleFuture.then((schedule) async {
      if (DateUtils.isSameDay(requestedDate, DateTime.now()) &&
          requestedCity == _city &&
          _remindersEnabled) {
        await _notifications.schedulePrayerNotifications(schedule);
      }
    }).catchError((_) {
      // Error ditangani oleh FutureBuilder.
    });
  }

  void _refresh() {
    setState(_loadSchedule);
  }

  void _changeDate(int difference) {
    setState(() {
      _selectedDate = DateUtils.dateOnly(
        _selectedDate.add(Duration(days: difference)),
      );
      _loadSchedule();
    });
  }

  Future<void> _chooseDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (result == null || !mounted) return;

    setState(() {
      _selectedDate = DateUtils.dateOnly(result);
      _loadSchedule();
    });
  }

  String _status(
      PrayerSchedule schedule,
      PrayerTime prayer,
      ) {
    if (!_isToday) {
      return 'Jadwal tanggal pilihan';
    }

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final prayerMinutes = prayer.hour * 60 + prayer.minute;

    if (prayerMinutes > currentMinutes) {
      return 'Akan datang';
    }

    final passed = schedule.prayers.where((item) {
      return item.hour * 60 + item.minute <= currentMinutes;
    }).toList();

    if (passed.isNotEmpty &&
        passed.last.name == prayer.name) {
      return 'Sekarang';
    }

    return 'Sudah lewat';
  }

  String _nextPrayer(PrayerSchedule schedule) {
    if (!_isToday) {
      return 'Jadwal ${schedule.date}';
    }

    final now = DateTime.now();

    for (final prayer in schedule.prayers) {
      if (prayer.onDate(now).isAfter(now)) {
        return '${prayer.name} • ${prayer.time}';
      }
    }

    return 'Berikutnya: Subuh besok';
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedTab,
          children: [
            const CompassPage(),
            const MapsPage(),
            _prayersPage(),
            _settingsPage(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFD7EADF),
        onDestinationSelected: (index) {
          setState(() => _selectedTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Compass',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Maps',
          ),
          NavigationDestination(
            icon: Icon(Icons.access_time),
            selectedIcon: Icon(Icons.access_time_filled),
            label: 'Prayers',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _prayersPage() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
          ),
        ),
        Expanded(
          child: FutureBuilder<PrayerSchedule>(
            future: _scheduleFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'Jadwal shalat gagal dimuat.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _refresh,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final schedule = snapshot.data!;

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB7F0DC),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_active, size: 17),
                            SizedBox(width: 8),
                            Text(
                              'Next Prayer',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _nextPrayer(schedule),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF276C55),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('$_city • ${schedule.date}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => _changeDate(-1),
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: _chooseDate,
                            child: Text(
                              _isToday
                                  ? 'Today'
                                  : '${_selectedDate.day}/'
                                  '${_selectedDate.month}/'
                                  '${_selectedDate.year}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _changeDate(1),
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...schedule.prayers.map((prayer) {
                    final status = _status(schedule, prayer);
                    final current = status == 'Sekarang';

                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 2),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: current
                              ? const Color(0xFF66AA72)
                              : Colors.black12,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE9F0EB),
                          child: Icon(
                            current
                                ? Icons.notifications_active
                                : Icons.access_time,
                            color: const Color(0xFF487C64),
                          ),
                        ),
                        title: Text(
                          prayer.name,
                          style: TextStyle(
                            fontWeight: current
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          current ? 'CURRENT • $status' : status,
                        ),
                        trailing: Text(
                          prayer.time,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _settingsPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        const Text('Kota jadwal shalat'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _city,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          items: const [
            DropdownMenuItem(value: 'Malang', child: Text('Malang')),
            DropdownMenuItem(value: 'Jakarta', child: Text('Jakarta')),
            DropdownMenuItem(value: 'Surabaya', child: Text('Surabaya')),
            DropdownMenuItem(value: 'Bandung', child: Text('Bandung')),
            DropdownMenuItem(
              value: 'Yogyakarta',
              child: Text('Yogyakarta'),
            ),
          ],
          onChanged: (city) {
            if (city == null) return;
            setState(() {
              _city = city;
              _loadSchedule();
            });
          },
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          value: _remindersEnabled,
          title: const Text('Pengingat shalat'),
          subtitle: const Text('Aktifkan notifikasi waktu shalat'),
          onChanged: (enabled) async {
            setState(() => _remindersEnabled = enabled);

            if (!enabled) {
              await _notifications.cancelAll();
            } else if (_isToday) {
              try {
                final schedule = await _scheduleFuture;
                if (mounted && _remindersEnabled && _isToday) {
                  await _notifications
                      .schedulePrayerNotifications(schedule);
                }
              } catch (_) {
                // Jadwal belum tersedia.
              }
            }
          },
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Tentang ShalatKu'),
          subtitle: Text('Jadwal shalat dari AlAdhan API'),
        ),
      ],
    );
  }
}

class CompassPage extends StatelessWidget {
  const CompassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Compass',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            StreamBuilder<CompassEvent>(
              stream: FlutterCompass.events,
              builder: (context, snapshot) {
                final heading = snapshot.data?.heading;

                if (heading == null) {
                  return const Column(
                    children: [
                      Icon(Icons.explore_off, size: 90),
                      SizedBox(height: 12),
                      Text(
                        'Sensor kompas tidak tersedia. '
                            'Coba perangkat fisik yang mendukung sensor.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    Transform.rotate(
                      angle: -heading * (3.1415926535 / 180),
                      child: const Icon(
                        Icons.navigation,
                        size: 150,
                        color: Color(0xFF176B4D),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${heading.toStringAsFixed(0)}°',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Arah utara magnetis'),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Kompas ini belum menunjukkan arah kiblat.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  Future<void> _openMaps() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/masjid/',
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.map,
              size: 90,
              color: Color(0xFF176B4D),
            ),
            const SizedBox(height: 16),
            const Text(
              'Maps',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cari masjid melalui Google Maps.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _openMaps,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Buka Google Maps'),
            ),
          ],
        ),
      ),
    );
  }
}
