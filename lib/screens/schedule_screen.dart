import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../models/class_model.dart';
import '../providers/app_provider.dart';

class _C {
  static const bg = Color(0xFF030303);
  static const panel = Color(0xFF0A0A0A);
  static const panel2 = Color(0xFF121212);
  static const red = Color(0xFFE50914);
  static const redDeep = Color(0xFF8A050C);
  static const cream = Color(0xFFF5F5F5);
  static const muted = Color(0xFF8A8A8A);
  static const mutedDim = Color(0xFF555555);
  static const green = Color(0xFF4ADE80);
  static const whatsappGreen = Color(0xFF25D366);
  static const transparentWhite = Colors.white10;
}

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _activeTab = 0;
  int _activeDay = 0;

  // === FİLTRE STATE'LERİ ===
  String _comboFilterMode = 'This Week'; // Today, This Week, This Month, Custom, All
  DateTimeRange? _customDateRange;
  String? _selectedCoach;

  List<ClassModel> _filteredClasses(AppProvider appProvider) {
    final membership = appProvider.membership;
    final groupId = membership?.groupId ?? '';
    final groupName = membership?.groupName ?? '';

    if (groupId.isEmpty && groupName.isEmpty) {
      return appProvider.classes;
    }

    return appProvider.classes.where((c) {
      if (groupId.isNotEmpty && c.id == groupId) return true;
      if (groupName.isNotEmpty && c.className == groupName) return true;
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final l10n = AppLocalizations.of(context);
    final classes = _filteredClasses(appProvider);
    final bookedClasses = appProvider.bookedClasses;

    final Set<String> bookedIds = bookedClasses.map((c) => c.id).toSet();

    final now = DateTime.now();
    final List<Map<String, dynamic>> allDays = [];
    for (int i = 0; i < 10; i++) {
      final date = now.add(Duration(days: i));
      allDays.add({
        'date': date,
        'dayShort': DateFormat('EEE').format(date).substring(0, 3).toUpperCase(),
        'dayNumber': date.day,
        'month': DateFormat('MMM').format(date).toUpperCase(),
      });
    }

    final Map<String, List<ClassModel>> sessionsByDay = {};
    for (final classModel in classes) {
      final days = classModel.scheduleDays;
      if (days.isEmpty) {
        final dayShort = DateFormat('EEE').format(classModel.startTime).substring(0, 3).toUpperCase();
        sessionsByDay.putIfAbsent(dayShort, () => []);
        sessionsByDay[dayShort]!.add(classModel);
      } else {
        for (final day in days) {
          final upperDay = day.toUpperCase();
          sessionsByDay.putIfAbsent(upperDay, () => []);
          if (!sessionsByDay[upperDay]!.any((c) => c.id == classModel.id)) {
            sessionsByDay[upperDay]!.add(classModel);
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/schedule_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderLogo(context, l10n),
                  const SizedBox(height: 24),
                  _buildHero(l10n),
                  const SizedBox(height: 16),
                  _buildGroupBadge(appProvider, l10n, classes),
                  const SizedBox(height: 20),

                  _buildTopTabs(),
                  const SizedBox(height: 20),

                  // === İÇERİK ANIMASYONLU GEÇİŞ ===
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _activeTab == 0
                        ? _buildScheduleTab(allDays, sessionsByDay, bookedIds, l10n)
                        : _buildCombosTab(appProvider),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ YENİ: TAB YAPISI ============
  Widget _buildTopTabs() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: _C.panel.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.transparentWhite),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _activeTab == 0 ? _C.red : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _activeTab == 0
                      ? [BoxShadow(color: _C.red.withValues(alpha: 0.4), blurRadius: 8)]
                      : [],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month_rounded, size: 14, color: _activeTab == 0 ? Colors.white : _C.muted),
                    const SizedBox(width: 6),
                    Text(
                      'SCHEDULE',
                      style: GoogleFonts.manrope(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: _activeTab == 0 ? Colors.white : _C.muted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _activeTab == 1 ? _C.red : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _activeTab == 1
                      ? [BoxShadow(color: _C.red.withValues(alpha: 0.4), blurRadius: 8)]
                      : [],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_mma_rounded, size: 14, color: _activeTab == 1 ? Colors.white : _C.muted),
                    const SizedBox(width: 6),
                    Text(
                      'DAILY COMBOS',
                      style: GoogleFonts.manrope(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: _activeTab == 1 ? Colors.white : _C.muted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ TAB 1: SCHEDULE ============
  Widget _buildScheduleTab(List<Map<String, dynamic>> allDays, Map<String, List<ClassModel>> sessionsByDay, Set<String> bookedIds, AppLocalizations l10n) {
    return Column(
      key: const ValueKey('schedule_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDayStrip(allDays),
        const SizedBox(height: 24),
        _buildSectionLabel(allDays, l10n),
        const SizedBox(height: 12),
        _buildSessionsSection(allDays, sessionsByDay, bookedIds, l10n),
        const SizedBox(height: 24),
        _buildCtaButton(l10n),
      ],
    );
  }

  // ============ TAB 2: COMBOS (YENİ VE PROFESYONEL) ============
  Widget _buildCombosTab(AppProvider appProvider) {
    final allCombos = appProvider.dailyCombos ?? [];

    // 1. Koç listesini çıkar (Tekrarlananları al)
    final Set<String> coachSet = {};
    for (var c in allCombos) {
      if (c['coachName'] != null) coachSet.add(c['coachName'].toString());
    }
    final coaches = coachSet.toList()..sort();

    // 2. Filtreleme İşlemi
    final now = DateTime.now();
    final todayKey = DateFormat('yyyy-MM-dd').format(now);
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = now.subtract(const Duration(days: 30));

    final filteredCombos = allCombos.where((combo) {
      // Tarih parse
      final dateStr = combo['date']?.toString() ?? '';
      final date = DateTime.tryParse(dateStr);
      if (date == null) return false;

      // Koç Filtresi
      if (_selectedCoach != null && combo['coachName'] != _selectedCoach) {
        return false;
      }

      // Tarih Filtresi
      switch (_comboFilterMode) {
        case 'Today':
          return dateStr == todayKey;
        case 'This Week':
          return date.isAfter(weekAgo) || date.isAtSameMomentAs(weekAgo);
        case 'This Month':
          return date.isAfter(monthAgo) || date.isAtSameMomentAs(monthAgo);
        case 'Custom':
          if (_customDateRange != null) {
            final start = _customDateRange!.start.subtract(const Duration(seconds: 1));
            final end = _customDateRange!.end.add(const Duration(days: 1));
            return date.isAfter(start) && date.isBefore(end);
          }
          return true;
        default:
          return true; // All
      }
    }).toList();

    // Yeniden eskiye sırala
    filteredCombos.sort((a, b) {
      final aDate = DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime.now();
      final bDate = DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime.now();
      return bDate.compareTo(aDate);
    });

    return Column(
      key: const ValueKey('combos_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === FİLTRE ALANI ===
        _buildComboFilters(coaches),

        const SizedBox(height: 16),

        // === LİSTE ===
        if (filteredCombos.isEmpty)
          _buildEmptyCombosState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredCombos.length,
            itemBuilder: (context, index) {
              final combo = filteredCombos[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 400)), // Gecikmeli animasyon
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: _buildComboCard(combo, index),
              );
            },
          ),
      ],
    );
  }

  // Filtre Çubuğu (Tarih ve Koç)
  Widget _buildComboFilters(List<String> coaches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tarih Filtreleri
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip('Today', 'Today'),
              const SizedBox(width: 8),
              _filterChip('This Week', 'This Week'),
              const SizedBox(width: 8),
              _filterChip('This Month', 'This Month'),
              const SizedBox(width: 8),
              _filterChip('All', 'All'),
              const SizedBox(width: 8),
              // Custom Tarih Butonu
              GestureDetector(
                onTap: _pickCustomDateRange,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _comboFilterMode == 'Custom' ? _C.red.withValues(alpha: 0.15) : _C.panel.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _comboFilterMode == 'Custom' ? _C.red : _C.transparentWhite,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, size: 12, color: _comboFilterMode == 'Custom' ? _C.red : _C.muted),
                      const SizedBox(width: 4),
                      Text(
                        _comboFilterMode == 'Custom' && _customDateRange != null
                            ? '${DateFormat('dd MMM').format(_customDateRange!.start)} - ${DateFormat('dd MMM').format(_customDateRange!.end)}'
                            : 'Custom',
                        style: GoogleFonts.manrope(
                          fontSize: 9.5,
                          fontWeight: _comboFilterMode == 'Custom' ? FontWeight.w800 : FontWeight.w600,
                          color: _comboFilterMode == 'Custom' ? _C.red : _C.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Koç Filtresi (Dropdown)
        if (coaches.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _C.panel.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.transparentWhite),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCoach,
                hint: Row(
                  children: [
                    Icon(Icons.person_search, size: 14, color: _C.muted),
                    const SizedBox(width: 8),
                    Text('Filter by Coach', style: GoogleFonts.manrope(fontSize: 11, color: _C.muted)),
                  ],
                ),
                isExpanded: true,
                dropdownColor: _C.panel2,
                icon: Icon(Icons.keyboard_arrow_down, size: 16, color: _C.muted),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text('All Coaches', style: GoogleFonts.manrope(fontSize: 11, color: _C.cream)),
                  ),
                  ...coaches.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c, style: GoogleFonts.manrope(fontSize: 11, color: _C.cream)),
                  )),
                ],
                onChanged: (val) => setState(() => _selectedCoach = val),
              ),
            ),
          ),
      ],
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _comboFilterMode == value;
    return GestureDetector(
      onTap: () => setState(() {
        _comboFilterMode = value;
        _customDateRange = null; // Reset custom range if another chip is selected
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _C.red.withValues(alpha: 0.15) : _C.panel.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _C.red : _C.transparentWhite,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 9.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? _C.red : _C.muted,
          ),
        ),
      ),
    );
  }

  Future<void> _pickCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange: _customDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _C.red,
              onPrimary: Colors.white,
              surface: _C.panel2,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: _C.bg,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _comboFilterMode = 'Custom';
        _customDateRange = picked;
      });
    }
  }

  // === PROFESYONEL COMBO KARTI ===
  Widget _buildComboCard(Map<String, dynamic> combo, int index) {
    final date = DateTime.tryParse(combo['date']?.toString() ?? '') ?? DateTime.now();
    final now = DateTime.now();
    final isToday = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(now);

    final dayStr = DateFormat('dd').format(date);
    final monthStr = DateFormat('MMM').format(date).toUpperCase();
    final dayName = DateFormat('EEEE').format(date);
    final coachName = combo['coachName']?.toString() ?? 'Unknown Coach';
    final branchName = combo['branchName']?.toString() ?? '';
    final comboText = combo['combo']?.toString().toUpperCase() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            _C.panel2,
            _C.panel.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: isToday ? _C.red.withValues(alpha: 0.4) : _C.transparentWhite),
        boxShadow: [
          BoxShadow(
            color: isToday ? _C.red.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Arka plan dev ikon (Estetik)
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(Icons.sports_martial_arts, size: 90, color: _C.cream.withValues(alpha: 0.02)),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sol Taraf: Tarih Kutusu
                  Container(
                    width: 50,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isToday ? _C.red : _C.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isToday ? _C.redDeep : _C.transparentWhite),
                    ),
                    child: Column(
                      children: [
                        Text(
                          monthStr,
                          style: GoogleFonts.manrope(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: isToday ? Colors.white70 : _C.muted,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          dayStr,
                          style: GoogleFonts.bebasNeue(
                            fontSize: 22,
                            color: isToday ? Colors.white : _C.cream,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          dayName.substring(0, 3),
                          style: GoogleFonts.manrope(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: isToday ? Colors.white70 : _C.mutedDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Sağ Taraf: İçerik
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Üst Bilgi Satırı
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person_outline, size: 10, color: _C.muted),
                                const SizedBox(width: 4),
                                Text(
                                  coachName.toUpperCase(),
                                  style: GoogleFonts.manrope(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    color: _C.muted,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            if (branchName.isNotEmpty)
                              Text(
                                branchName.toUpperCase(),
                                style: GoogleFonts.manrope(
                                  fontSize: 8,
                                  color: _C.mutedDim,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Combo Metni
                        Text(
                          comboText,
                          style: GoogleFonts.oswald(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _C.cream,
                            letterSpacing: 0.8,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Alt Bilgi
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _C.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'DAILY COMBO',
                                style: GoogleFonts.manrope(
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.w800,
                                  color: _C.red,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCombosState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: _C.panel.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.transparentWhite),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _C.red.withValues(alpha: 0.05),
              border: Border.all(color: _C.red.withValues(alpha: 0.1)),
            ),
            child: const Icon(Icons.sports_mma, color: _C.redDeep, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'No Combos Found',
            style: GoogleFonts.oswald(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _C.cream,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try changing your filters or date range to see past combos.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(fontSize: 11, color: _C.muted, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ============ MEVCUT SCHEDULE METODLARI (AYNEN KORUNDU) ============

  Widget _buildGroupBadge(AppProvider appProvider, AppLocalizations l10n, List<ClassModel> filteredClasses) {
    final membership = appProvider.membership;
    final groupName = membership?.groupName ?? '';

    if (groupName.isEmpty && filteredClasses.isEmpty) return const SizedBox.shrink();

    String whatsappUrl = '';
    if (filteredClasses.isNotEmpty) {
      final match = filteredClasses.firstWhere(
              (c) => c.whatsappGroupUrl.isNotEmpty,
          orElse: () => filteredClasses.first
      );
      whatsappUrl = match.whatsappGroupUrl;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (groupName.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _C.red.withValues(alpha: 0.08),
              border: Border.all(color: _C.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.groups_rounded, size: 12, color: _C.red),
                const SizedBox(width: 6),
                Text(
                  'YOUR GROUP · ',
                  style: GoogleFonts.manrope(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: _C.muted,
                    letterSpacing: 1.5,
                  ),
                ),
                Flexible(
                  child: Text(
                    groupName.toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _C.red,
                      letterSpacing: 0.8,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

        if (whatsappUrl.isNotEmpty)
          GestureDetector(
            onTap: () async {
              final uri = Uri.parse(whatsappUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _C.whatsappGreen.withValues(alpha: 0.15),
                border: Border.all(color: _C.whatsappGreen.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: _C.whatsappGreen.withValues(alpha: 0.2),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chat_bubble_rounded, color: _C.whatsappGreen, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'JOIN GROUP',
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: _C.whatsappGreen,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeaderLogo(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/images/lycans_logo.jpeg',
          width: 90,
          height: 90,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 6),
        Text(
          l10n.fearlessFightersSpaced,
          style: GoogleFonts.manrope(
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            color: _C.cream.withValues(alpha: 0.8),
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _C.bg.withValues(alpha: 0.5),
              border: Border.all(color: _C.transparentWhite),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: _C.cream, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildHero(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 2,
              decoration: BoxDecoration(
                color: _C.red,
                boxShadow: [BoxShadow(color: _C.red.withValues(alpha: 0.6), blurRadius: 4)],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.trainingUpper,
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _C.muted,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          l10n.scheduleTitle,
          style: GoogleFonts.permanentMarker(
            fontSize: 46,
            color: _C.cream,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.scheduleSubtitle,
          style: GoogleFonts.manrope(fontSize: 12, color: _C.muted, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildDayStrip(List<Map<String, dynamic>> allDays) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allDays.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final day = allDays[index];
          final dayShort = day['dayShort'] as String;
          final isActive = index == _activeDay;

          return GestureDetector(
            onTap: () => setState(() => _activeDay = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isActive ? _C.bg : _C.panel.withValues(alpha: 0.6),
                border: Border.all(
                  color: isActive ? _C.red : _C.transparentWhite,
                  width: isActive ? 1.5 : 1,
                ),
                boxShadow: isActive
                    ? [BoxShadow(color: _C.red.withValues(alpha: 0.25), blurRadius: 15, offset: const Offset(0, 4))]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayShort,
                    style: GoogleFonts.manrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isActive ? _C.red : _C.muted,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day['dayNumber']}',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 22,
                      color: isActive ? _C.cream : _C.muted,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionLabel(List<Map<String, dynamic>> allDays, AppLocalizations l10n) {
    if (_activeDay >= allDays.length) return const SizedBox();
    final day = allDays[_activeDay];
    final dayShort = day['dayShort'] as String;
    final dayNumber = day['dayNumber'];
    final month = day['month'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(width: 8, height: 1.5, color: _C.redDeep),
        const SizedBox(width: 8),
        Text(
          l10n.sessionsFor,
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: _C.muted,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$dayShort $dayNumber $month',
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: _C.cream,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionsSection(
      List<Map<String, dynamic>> allDays,
      Map<String, List<ClassModel>> sessionsByDay,
      Set<String> bookedIds,
      AppLocalizations l10n,
      ) {
    if (_activeDay >= allDays.length) return _buildRestDayState(l10n);
    final day = allDays[_activeDay];
    final dayShort = day['dayShort'] as String;
    final sessions = sessionsByDay[dayShort] ?? [];
    if (sessions.isEmpty) return _buildRestDayState(l10n);

    return Column(
      children: List.generate(sessions.length, (i) {
        final session = sessions[i];
        final isBooked = bookedIds.contains(session.id) || session.isBooked;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _buildSessionCard(session, isBooked, l10n),
        );
      }),
    );
  }

  Widget _buildRestDayState(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _C.panel.withValues(alpha: 0.5),
        border: Border.all(color: _C.transparentWhite),
      ),
      child: Column(
        children: [
          Icon(Icons.nightlight_round, color: _C.mutedDim, size: 24),
          const SizedBox(height: 12),
          Text(
            l10n.restDay,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _C.muted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.restDayDesc,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(fontSize: 11.5, color: _C.mutedDim, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(ClassModel session, bool isBooked, AppLocalizations l10n) {
    final badgeLabel = session.sport.toUpperCase();
    final timeStr = session.timeStr.isNotEmpty
        ? session.timeStr
        : DateFormat('HH:mm').format(session.startTime);
    final ampm = session.startTime.hour >= 12 ? l10n.pmLabel : l10n.amLabel;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.transparentWhite),
        color: _C.bg,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/session_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _C.bg,
                    _C.bg.withValues(alpha: 0.9),
                    _C.bg.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.0, 0.45, 0.75, 1.0],
                ),
              ),
            ),
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: _C.red,
                    boxShadow: [BoxShadow(color: _C.red.withValues(alpha: 0.8), blurRadius: 10)],
                  ),
                ),
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time_rounded, color: _C.red, size: 14),
                      const SizedBox(height: 6),
                      Text(
                        timeStr,
                        style: GoogleFonts.bebasNeue(
                          fontSize: 24,
                          color: _C.cream,
                          letterSpacing: 1,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ampm,
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: _C.muted,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  color: _C.transparentWhite,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _C.red.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            badgeLabel,
                            style: GoogleFonts.manrope(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: _C.red,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                session.className.toUpperCase(),
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 18,
                                  color: _C.cream,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isBooked) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.check_circle_rounded, size: 14, color: _C.green),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            _metaItem(Icons.person_outline_rounded, session.coachName),
                            _metaItem(Icons.location_on_outlined, session.location),
                            _metaItem(Icons.access_time_rounded, l10n.minSuffix(session.duration)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: _C.muted),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: _C.muted,
          ),
        ),
      ],
    );
  }

  Widget _buildCtaButton(AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => _openBookingSheet(context, l10n),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: _C.bg,
          border: Border.all(color: _C.red.withValues(alpha: 0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _C.red.withValues(alpha: 0.25),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, color: _C.cream, size: 18),
            const SizedBox(width: 8),
            Text(
              l10n.bookASession,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _C.cream,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openBookingSheet(BuildContext context, AppLocalizations l10n) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final classes = _filteredClasses(appProvider);
    final bookedClasses = appProvider.bookedClasses;
    final Set<String> bookedIds = bookedClasses.map((c) => c.id).toSet();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _BookingSheet(
          classes: classes,
          bookedIds: bookedIds,
          onBook: (classModel) async {
            await appProvider.bookClass(classModel);
          },
        );
      },
    );
  }
}

// _BookingSheet sınıfı ve diğer yardımcı sınıflar aynen kalıyor (Değiştirmedim)
class _BookingSheet extends StatefulWidget {
  final List<ClassModel> classes;
  final Set<String> bookedIds;
  final Function(ClassModel) onBook;

  const _BookingSheet({
    required this.classes,
    required this.bookedIds,
    required this.onBook,
  });

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  late Set<String> _localBooked;
  final Set<String> _loadingBooked = {};

  @override
  void initState() {
    super.initState();
    _localBooked = Set<String>.from(widget.bookedIds);
  }

  Future<void> _handleBook(ClassModel classModel) async {
    if (_localBooked.contains(classModel.id) || _loadingBooked.contains(classModel.id)) return;
    setState(() => _loadingBooked.add(classModel.id));
    await widget.onBook(classModel);
    if (!mounted) return;
    setState(() {
      _loadingBooked.remove(classModel.id);
      _localBooked.add(classModel.id);
    });
    final l10n = AppLocalizations.of(context);
    _showRedToast(context, l10n.spotLockedIn(classModel.className));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: _C.panel2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: _C.red.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: _C.red.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _C.transparentWhite,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Text(
            l10n.availableClasses,
            style: GoogleFonts.bebasNeue(fontSize: 24, color: _C.cream, letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          Text(
            widget.classes.isEmpty ? l10n.noOpenClasses : l10n.chooseClass,
            style: GoogleFonts.manrope(fontSize: 11, color: _C.muted),
          ),
          const SizedBox(height: 16),
          if (widget.classes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                l10n.noClassesAvailable,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(fontSize: 12, color: _C.muted),
              ),
            )
          else
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: List.generate(widget.classes.length, (i) {
                  final classModel = widget.classes[i];
                  final isBooked = _localBooked.contains(classModel.id);
                  final isLoading = _loadingBooked.contains(classModel.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildPickCard(classModel, isBooked, isLoading, l10n,
                            () => _handleBook(classModel)),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPickCard(
      ClassModel session,
      bool isBooked,
      bool isLoading,
      AppLocalizations l10n,
      VoidCallback onTap,
      ) {
    final timeStr = session.timeStr.isNotEmpty
        ? session.timeStr
        : DateFormat('HH:mm').format(session.startTime);
    final ampm = session.startTime.hour >= 12 ? l10n.pmLabel : l10n.amLabel;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _C.bg,
          border: Border.all(
            color: isBooked ? _C.green.withValues(alpha: 0.4) : _C.transparentWhite,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              child: Column(
                children: [
                  Text(timeStr, style: GoogleFonts.bebasNeue(fontSize: 18, color: _C.red)),
                  Text(ampm,
                      style: GoogleFonts.manrope(
                          fontSize: 8.5, color: _C.mutedDim, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Container(
                width: 1,
                height: 24,
                color: _C.transparentWhite,
                margin: const EdgeInsets.symmetric(horizontal: 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.className.toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _C.cream,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${session.coachName} • ${session.location} • ${l10n.minSuffix(session.duration)}',
                    style: GoogleFonts.manrope(fontSize: 9.5, color: _C.muted),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isBooked ? _C.green.withValues(alpha: 0.1) : _C.red.withValues(alpha: 0.1),
                border: Border.all(
                  color: isBooked
                      ? _C.green.withValues(alpha: 0.4)
                      : _C.red.withValues(alpha: 0.3),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: _C.red),
              )
                  : Icon(
                isBooked ? Icons.check_rounded : Icons.add_rounded,
                size: 16,
                color: isBooked ? _C.green : _C.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showRedToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _RedToast(message: message, onDismissed: () => entry.remove()),
  );
  overlay.insert(entry);
}

class _RedToast extends StatefulWidget {
  final String message;
  final VoidCallback onDismissed;
  const _RedToast({required this.message, required this.onDismissed});

  @override
  State<_RedToast> createState() => _RedToastState();
}

class _RedToastState extends State<_RedToast> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2200), () async {
      if (!mounted) return;
      await _controller.reverse();
      widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 28,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _C.panel,
                border: Border.all(color: _C.red.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: _C.red.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: _C.green, size: 18),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      widget.message,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _C.cream,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}