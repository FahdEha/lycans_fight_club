import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/branch_model.dart';
import '../models/class_model.dart';
import '../providers/app_provider.dart';

class BranchDetailsScreen extends StatefulWidget {
  final BranchModel branch;

  const BranchDetailsScreen({super.key, required this.branch});

  @override
  State<BranchDetailsScreen> createState() => _BranchDetailsScreenState();
}

class _BranchDetailsScreenState extends State<BranchDetailsScreen> {
  int _selectedDayIndex = 0;
  String? _selectedGroupName;

  final Color generalGlassDark = const Color(0xFF0F1115).withOpacity(0.5);
  final Color glassBorder = Colors.white.withOpacity(0.04);

  // Mon → Sun sırası (ClassModel.scheduleDays İngilizce kullanıyor)
  static const List<String> _dayOrderEn = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final l10n = AppLocalizations.of(context);
    final branch = widget.branch;

    // Bu branch'teki tüm class'lar
    final branchClasses = provider.classes
        .where((c) => c.branchId == branch.id)
        .toList();

    // ===== UNIQUE GROUP NAMES (className'ler) =====
    final List<String> groupNames = [];
    for (final c in branchClasses) {
      final name = c.className.trim();
      if (name.isNotEmpty && !groupNames.contains(name)) {
        groupNames.add(name);
      }
    }

    // Aktif grup (state'te yoksa ilk grubu kullan)
    final String? activeGroup = _selectedGroupName != null &&
        groupNames.contains(_selectedGroupName)
        ? _selectedGroupName
        : (groupNames.isNotEmpty ? groupNames.first : null);

    // Seçili grubun class'ları
    final groupClasses = activeGroup == null
        ? <ClassModel>[]
        : branchClasses.where((c) => c.className.trim() == activeGroup).toList();

    // Bu grubun antrenman günleri (sıralı)
    final List<String> groupDays = [];
    for (final day in _dayOrderEn) {
      for (final c in groupClasses) {
        if (c.scheduleDays.contains(day)) {
          groupDays.add(day);
          break;
        }
      }
    }

    // Selected index valid mi?
    final int safeIndex =
    groupDays.isEmpty || _selectedDayIndex >= groupDays.length
        ? 0
        : _selectedDayIndex;

    // Seçili günün session'ları
    final String? selectedDayEn =
    groupDays.isEmpty ? null : groupDays[safeIndex];
    final sessionsToday = selectedDayEn == null
        ? <ClassModel>[]
        : groupClasses
        .where((c) => c.scheduleDays.contains(selectedDayEn))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380,
            child: Image.asset(
              'assets/images/branch_details_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: generalGlassDark,
                              border: Border.all(color: glassBorder),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40, height: 40),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.branchUpper,
                          style: GoogleFonts.oswald(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 4,
                            color: const Color(0xFFE60023),
                          ),
                        ),
                        const SizedBox(height: 2),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFFFFFFF),
                              Color(0xFFE8E8E8),
                              Color(0xFFC0C0C0),
                              Color(0xFF909090),
                            ],
                            stops: [0.0, 0.3, 0.7, 1.0],
                          ).createShader(bounds),
                          child: Text(
                            branch.name.toUpperCase(),
                            style: GoogleFonts.oswald(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.sameSpirit,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.5),
                            height: 1.4,
                          ),
                        ),
                        Text(
                          l10n.differentGround,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.5),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (branch.sports.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: branch.sports.asMap().entries.map((e) {
                          final isLast = e.key == branch.sports.length - 1;
                          return Padding(
                            padding: EdgeInsets.only(right: isLast ? 0 : 16),
                            child: _buildSportItem(e.value),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildLocationCard(branch, l10n),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildPhotoCard(),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildAddressCard(branch, l10n)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildPhoneCard(branch, l10n)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildDirectionsCard(branch, l10n)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildScheduleCard(
                      groupNames: groupNames,
                      activeGroup: activeGroup,
                      groupDays: groupDays,
                      sessionsToday: sessionsToday,
                      selectedIndex: safeIndex,
                      l10n: l10n,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildJoinButton(l10n),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSportItem(String sport) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _getSportIcon(sport),
          size: 12,
          color: const Color(0xFFE60023),
        ),
        const SizedBox(width: 4),
        Text(
          sport.toUpperCase(),
          style: GoogleFonts.oswald(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  IconData _getSportIcon(String sport) {
    final s = sport.toLowerCase();
    if (s.contains('mma') ||
        s.contains('boxing') ||
        s.contains('kickboxing') ||
        s.contains('muay') ||
        s.contains('wrestling')) {
      return Icons.sports_mma;
    }
    if (s.contains('bjj') ||
        s.contains('jiu') ||
        s.contains('judo') ||
        s.contains('karate') ||
        s.contains('taekwondo')) {
      return Icons.sports_martial_arts;
    }
    if (s.contains('fitness') ||
        s.contains('strength') ||
        s.contains('crossfit')) {
      return Icons.fitness_center;
    }
    if (s.contains('yoga') || s.contains('pilates')) {
      return Icons.self_improvement;
    }
    return Icons.sports_mma;
  }

  Widget _buildLocationCard(BranchModel branch, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: generalGlassDark,
        border: Border.all(color: glassBorder),
        image: const DecorationImage(
          image: AssetImage('assets/images/this_branch_card_bg.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x3CE60023).withOpacity(0.15),
            ),
            child: const Icon(
              Icons.location_on,
              size: 16,
              color: Color(0xFFE60023),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.branchSuffix(branch.name),
                  style: GoogleFonts.oswald(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.yourTrainingGround(branch.name),
                  style: GoogleFonts.manrope(
                    fontSize: 7.5,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFFE60023).withOpacity(0.1),
              border: Border.all(
                color: const Color(0xFFE60023).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      branch.isActive ? l10n.openStatus : l10n.closedStatus,
                      style: GoogleFonts.oswald(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: branch.isActive
                            ? const Color(0xFFFF6B6B)
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '06:00 - 23:00',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 6.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFFF6B6B).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: glassBorder),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/branch1_card_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: generalGlassDark),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Text(
                '1 / 1',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
            Positioned(
              right: 48,
              bottom: 8,
              child: Row(
                children: [
                  _buildArrowBtn(Icons.arrow_back),
                  const SizedBox(width: 6),
                  _buildArrowBtn(Icons.arrow_forward),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrowBtn(IconData icon) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: generalGlassDark,
        border: Border.all(color: glassBorder),
      ),
      child: Icon(icon, size: 12, color: Colors.white.withOpacity(0.7)),
    );
  }

  Widget _buildAddressCard(BranchModel branch, AppLocalizations l10n) {
    return _buildInfoCardTemplate(
      icon: Icons.map_outlined,
      title: l10n.addressLabel,
      content: branch.address.isNotEmpty ? branch.address : l10n.addressNotSet,
      actionWidget: null,
    );
  }

  Widget _buildPhoneCard(BranchModel branch, AppLocalizations l10n) {
    final hasPhone = branch.phone.isNotEmpty;
    return _buildInfoCardTemplate(
      icon: Icons.phone,
      title: l10n.phoneLabel,
      content: hasPhone ? branch.phone : l10n.notAvailable,
      actionWidget: GestureDetector(
        onTap: hasPhone
            ? () async {
          final uri = Uri.parse('tel:${branch.phone}');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.transparent,
            border: Border.all(color: glassBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone,
                  size: 9, color: Colors.white.withOpacity(0.7)),
              const SizedBox(width: 5),
              Text(
                l10n.callNow,
                style: GoogleFonts.manrope(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionsCard(BranchModel branch, AppLocalizations l10n) {
    final hasLocation = branch.latitude != 0 && branch.longitude != 0;
    final hasLink = branch.locationLink.isNotEmpty;
    final canOpenMaps = hasLocation || hasLink;

    return _buildInfoCardTemplate(
      icon: Icons.send,
      title: l10n.getDirections,
      content: l10n.findEasiestWay,
      actionWidget: GestureDetector(
        onTap: canOpenMaps ? () => _openMaps(branch, l10n) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.transparent,
            border: Border.all(color: glassBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                canOpenMaps ? l10n.openMaps : l10n.noLocation,
                style: GoogleFonts.manrope(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(canOpenMaps ? 0.8 : 0.35),
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.arrow_forward,
                size: 9,
                color: Colors.white.withOpacity(canOpenMaps ? 0.8 : 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCardTemplate({
    required IconData icon,
    required String title,
    required String content,
    Widget? actionWidget,
  }) {
    return Container(
      height: 115,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: generalGlassDark,
        border: Border.all(color: glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFE60023)),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.oswald(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              content,
              style: GoogleFonts.manrope(
                fontSize: 8,
                color: Colors.white.withOpacity(0.5),
                height: 1.2,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actionWidget != null) ...[
            const SizedBox(height: 3),
            actionWidget,
          ]
        ],
      ),
    );
  }

  Future<void> _openMaps(BranchModel branch, AppLocalizations l10n) async {
    try {
      Uri uri;
      if (branch.latitude != 0 && branch.longitude != 0) {
        uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${branch.latitude},${branch.longitude}',
        );
      } else if (branch.locationLink.isNotEmpty) {
        uri = Uri.parse(branch.locationLink);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.locationNotAvailable),
              backgroundColor: const Color(0xFFE60023),
            ),
          );
        }
        return;
      }

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (branch.latitude != 0 && branch.longitude != 0) {
          final fallbackUri = Uri.parse(
            'geo:${branch.latitude},${branch.longitude}?q=${branch.latitude},${branch.longitude}(${Uri.encodeComponent(branch.name)})',
          );
          if (await canLaunchUrl(fallbackUri)) {
            await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
            return;
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.couldNotOpenMaps),
              backgroundColor: const Color(0xFFE60023),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error opening maps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFE60023),
          ),
        );
      }
    }
  }

  // ============================================================
  // ============ TRAINING SCHEDULE (GROUP SPINNER) ============
  // ============================================================
  Widget _buildScheduleCard({
    required List<String> groupNames,
    required String? activeGroup,
    required List<String> groupDays,
    required List<ClassModel> sessionsToday,
    required int selectedIndex,
    required AppLocalizations l10n,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: generalGlassDark,
        border: Border.all(color: glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER: icon + title + group spinner =====
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: Color(0xFFE60023),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.trainingSchedule,
                style: GoogleFonts.oswald(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              _buildGroupSpinner(groupNames, activeGroup, l10n),
            ],
          ),
          const SizedBox(height: 14),

          // ===== DAYS: sadece grubun training günleri =====
          if (groupDays.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  l10n.noSessionsThisDay,
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            )
          else
            Row(
              children: groupDays.asMap().entries.map((e) {
                final idx = e.key;
                final dayEn = e.value;
                final isSelected = idx == selectedIndex;
                final isLast = idx == groupDays.length - 1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedDayIndex = idx),
                    child: Container(
                      margin: EdgeInsets.only(right: isLast ? 0 : 5),
                      padding:
                      const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: isSelected
                            ? const Color(0xFFE60023)
                            : Colors.white.withOpacity(0.03),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFE60023)
                              : glassBorder,
                        ),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: const Color(0xFFE60023)
                                .withOpacity(0.35),
                            blurRadius: 8,
                          ),
                        ]
                            : null,
                      ),
                      child: Text(
                        _localizedDay(dayEn, l10n),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 8.5,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 12),

          // ===== SESSIONS =====
          if (sessionsToday.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  l10n.noSessionsThisDay,
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 75,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: sessionsToday.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  return _buildSessionTile(sessionsToday[i], l10n);
                },
              ),
            ),
        ],
      ),
    );
  }

  // ===== GROUP SPINNER (elegant dropdown) =====
  Widget _buildGroupSpinner(
      List<String> groupNames,
      String? activeGroup,
      AppLocalizations l10n,
      ) {
    if (groupNames.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.03),
          border: Border.all(color: glassBorder),
        ),
        child: Text(
          '—',
          style: GoogleFonts.oswald(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
      );
    }

    final selected = activeGroup ?? groupNames.first;

    return PopupMenuButton<String>(
      onSelected: (val) {
        setState(() {
          _selectedGroupName = val;
          _selectedDayIndex = 0;
        });
      },
      offset: const Offset(0, 34),
      color: const Color(0xFF151515),
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: const Color(0xFFE60023).withOpacity(0.3),
          width: 0.8,
        ),
      ),
      itemBuilder: (context) {
        return groupNames.map((g) {
          final isCurrent = g == selected;
          return PopupMenuItem<String>(
            value: g,
            height: 34,
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrent
                        ? const Color(0xFFE60023)
                        : Colors.white.withOpacity(0.2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    g.toUpperCase(),
                    style: GoogleFonts.oswald(
                      fontSize: 10,
                      fontWeight: isCurrent
                          ? FontWeight.w700
                          : FontWeight.w500,
                      letterSpacing: 0.8,
                      color: isCurrent
                          ? Colors.white
                          : Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
                if (isCurrent)
                  const Icon(
                    Icons.check_rounded,
                    size: 12,
                    color: Color(0xFFE60023),
                  ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFE60023).withOpacity(0.1),
          border: Border.all(
            color: const Color(0xFFE60023).withOpacity(0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE60023).withOpacity(0.15),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.groups_rounded,
              size: 11,
              color: Color(0xFFE60023),
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 90),
              child: Text(
                selected.toUpperCase(),
                style: GoogleFonts.oswald(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Day localized label =====
  String _localizedDay(String en, AppLocalizations l10n) {
    switch (en) {
      case 'Mon':
        return l10n.monShort;
      case 'Tue':
        return l10n.tueShort;
      case 'Wed':
        return l10n.wedShort;
      case 'Thu':
        return l10n.thuShort;
      case 'Fri':
        return l10n.friShort;
      case 'Sat':
        return l10n.satShort;
      case 'Sun':
        return l10n.sunShort;
      default:
        return en;
    }
  }

  Widget _buildSessionTile(ClassModel session, AppLocalizations l10n) {
    final timeStr = session.timeStr.isNotEmpty
        ? session.timeStr
        : DateFormat('HH:mm').format(session.startTime);
    final endStr = DateFormat('HH:mm').format(session.endTime);

    return Container(
      width: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$timeStr - $endStr',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 7.5,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Text(
            session.sport,
            style: GoogleFonts.oswald(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              color: Colors.white,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE60023),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.openSession,
                style: GoogleFonts.manrope(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJoinButton(AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFFE60023), Color(0xFF990012)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.joinThisBranch,
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward,
              size: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }
}