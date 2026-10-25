import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../models/package_model.dart';
import '../models/progress_model.dart';
import '../models/user_model.dart';
import '../providers/app_provider.dart';

const Color _kRed = Color(0xFFFF2A2A);
const Color _kCardBg = Color(0xFF131313);

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final l10n = AppLocalizations.of(context);
    final progress = appProvider.progress;
    final userData = appProvider.userData;
    final checkIns = appProvider.checkIns;
    final membership = appProvider.membership;
    final packages = appProvider.packages;

    PackageModel? playerPackage;

    final String? currentPackageId = userData?.currentPackageId;
    if (currentPackageId != null && currentPackageId.isNotEmpty) {
      playerPackage =
          packages.where((p) => p.id == currentPackageId).firstOrNull;
    }

    if (playerPackage == null &&
        membership != null &&
        membership.packageId.isNotEmpty) {
      playerPackage =
          packages.where((p) => p.id == membership.packageId).firstOrNull;
    }

    if (playerPackage == null &&
        membership != null &&
        membership.planName.isNotEmpty) {
      playerPackage = packages
          .where((p) =>
      p.name.toLowerCase() == membership.planName.toLowerCase())
          .firstOrNull;
    }

    int weeklyTarget = 3;
    bool isUnlimited = true;

    if (playerPackage != null) {
      isUnlimited = playerPackage.isUnlimited;
      if (!isUnlimited && playerPackage.weeklySessions > 0) {
        weeklyTarget = playerPackage.weeklySessions;
      } else if (!isUnlimited && playerPackage.maxSessions > 0) {
        weeklyTarget = (playerPackage.maxSessions / 4).ceil();
      }
    } else if (membership != null) {
      isUnlimited = membership.isUnlimited;
      if (!isUnlimited && membership.maxSessions > 0) {
        weeklyTarget = (membership.maxSessions / 4).ceil();
      }
    }

    final double? weight = userData?.weight != null && userData!.weight > 0
        ? userData.weight
        : null;
    final double? height = userData?.height != null && userData!.height > 0
        ? userData.height
        : null;
    final double? speedScore =
    progress?.speedScore != null && progress!.speedScore > 0
        ? progress.speedScore
        : null;
    final double? powerScore =
    progress?.powerScore != null && progress!.powerScore > 0
        ? progress.powerScore
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/progress_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _kRed.withOpacity(0.55),
                          blurRadius: 35,
                          spreadRadius: 1,
                        )
                      ],
                      image: const DecorationImage(
                        image: AssetImage('assets/images/lycans_logo.jpeg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.keepGoing,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    l10n.warrior,
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.disciplineTodayFreedomTomorrow,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Colors.white54,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 21),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.lock,
                          title: l10n.weightLabel,
                          value: weight != null
                              ? weight.toStringAsFixed(1)
                              : '--',
                          unit: l10n.kgUnit,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.person,
                          title: l10n.heightLabel,
                          value: height != null
                              ? height.toStringAsFixed(0)
                              : '--',
                          unit: l10n.cmUnit,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.speed,
                          title: l10n.speedLabel,
                          value: speedScore != null
                              ? speedScore.toStringAsFixed(1)
                              : '--',
                          unit: l10n.outOf10,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.bolt,
                          title: l10n.powerLabel,
                          value: powerScore != null
                              ? powerScore.toStringAsFixed(1)
                              : '--',
                          unit: l10n.outOf10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildMotivationCard(l10n),
                  const SizedBox(height: 10),
                  _buildActionBtn(
                    title: l10n.attendanceBtn,
                    subtitle: l10n.last4Weeks,
                    icon: Icons.calendar_today_outlined,
                    onTap: () => _showAttendanceSwipeSheet(
                      context,
                      checkIns,
                      weeklyTarget: weeklyTarget,
                      isUnlimited: isUnlimited,
                      planName:
                      playerPackage?.name ?? membership?.planName ?? '',
                    ),
                  ),
                  _buildActionBtn(
                    title: l10n.progressBtn,
                    subtitle: l10n.viewYourResults,
                    icon: Icons.bar_chart,
                    onTap: () {
                      Navigator.pushNamed(context, '/competition_screen');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kCardBg.withOpacity(0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
              width: 1,
            ),
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.5,
              colors: [
                _kRed.withOpacity(0.12),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white70, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    unit,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotivationCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        image: const DecorationImage(
          image: AssetImage('assets/images/motivation_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(
                    text: '${l10n.warrior}\n',
                    style: const TextStyle(color: Colors.white)),
                TextSpan(
                    text: l10n.progressBtn, style: const TextStyle(color: _kRed)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.progressBuiltInSmallSteps,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.white54,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          image: const DecorationImage(
            image: AssetImage('assets/images/progress_btn_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(
                    color: _kRed.withOpacity(0.6), width: 1.2),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
              child: const Icon(Icons.chevron_right,
                  color: Colors.white54, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttendanceSwipeSheet(
      BuildContext context,
      List<Map<String, dynamic>> checkIns, {
        required int weeklyTarget,
        required bool isUnlimited,
        required String planName,
      }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _AttendanceBottomSheet(
          checkIns: checkIns,
          weeklyTarget: weeklyTarget,
          isUnlimited: isUnlimited,
          planName: planName,
        );
      },
    );
  }
}

class _AttendanceBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> checkIns;
  final int weeklyTarget;
  final bool isUnlimited;
  final String planName;

  const _AttendanceBottomSheet({
    required this.checkIns,
    required this.weeklyTarget,
    required this.isUnlimited,
    required this.planName,
  });

  @override
  State<_AttendanceBottomSheet> createState() =>
      _AttendanceBottomSheetState();
}

class _AttendanceBottomSheetState extends State<_AttendanceBottomSheet>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late List<int> _attendanceCounts;
  late List<double> _progressValues;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _attendanceCounts = _calculateAttendanceCounts();
    _progressValues = _calculateProgress();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<int> _calculateAttendanceCounts() {
    final now = DateTime.now();
    List<int> counts = [];
    for (int i = 0; i < 4; i++) {
      final weekMonday = now
          .subtract(Duration(days: now.weekday - 1))
          .subtract(Duration(days: i * 7));
      final weekMondayDate =
      DateTime(weekMonday.year, weekMonday.month, weekMonday.day);
      final weekSunday = weekMondayDate.add(const Duration(days: 7));
      final count = widget.checkIns.where((c) {
        final ts =
            DateTime.tryParse(c['timestamp']?.toString() ?? '') ?? now;
        final tsDate = DateTime(ts.year, ts.month, ts.day);
        return (tsDate.isAfter(weekMondayDate) ||
            tsDate.isAtSameMomentAs(weekMondayDate)) &&
            tsDate.isBefore(weekSunday);
      }).length;
      counts.add(count);
    }
    return counts;
  }

  List<double> _calculateProgress() {
    if (widget.isUnlimited || widget.weeklyTarget <= 0) {
      return List.generate(4, (_) => 1.0);
    }
    return _attendanceCounts.map((count) {
      return (count / widget.weeklyTarget).clamp(0.0, 1.0);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = [
      l10n.thisWeek,
      l10n.lastWeek,
      l10n.twoWeeksAgo,
      l10n.threeWeeksAgo,
    ];

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: _kCardBg.withOpacity(0.85),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.attendanceTitleUpper,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _kRed.withOpacity(0.1),
                  border: Border.all(color: _kRed.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isUnlimited
                          ? Icons.all_inclusive
                          : Icons.flag_outlined,
                      size: 11,
                      color: _kRed,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.isUnlimited
                          ? l10n.unlimitedPlan
                          : l10n.targetPerWeek(widget.weeklyTarget),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _kRed,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 220,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (idx) {
                    setState(() => _currentPage = idx);
                    _animController.reset();
                    _animController.forward();
                  },
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return _buildSwipePage(
                      labels[index],
                      _progressValues[index],
                      _attendanceCounts[index],
                      l10n,
                      delay: index == _currentPage ? 0.0 : 0.15,
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color:
                      _currentPage == index ? _kRed : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipePage(
      String label,
      double progress,
      int attendanceCount,
      AppLocalizations l10n, {
        double delay = 0.0,
      }) {
    final percent = (progress * 100).toInt();
    final isComplete = percent >= 100;
    final Color primaryColor =
    isComplete ? const Color(0xFF4CAF50) : _kRed;
    final Color secondaryColor =
    isComplete ? const Color(0xFF81C784) : const Color(0xFFFF6B6B);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 15),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 140,
          height: 140,
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final animProgress = Curves.easeOutCubic.transform(
                ((_animController.value - delay) / (1 - delay))
                    .clamp(0.0, 1.0),
              );
              final animatedValue = progress * animProgress;
              final animatedPercent = (animatedValue * 100).toInt();

              return Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(140, 140),
                    painter: _GradientCircularProgressPainter(
                      progress: animatedValue,
                      strokeWidth: 10,
                      primaryColor: primaryColor,
                      secondaryColor: secondaryColor,
                      trackColor: Colors.white.withOpacity(0.06),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$animatedPercent%",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.isUnlimited
                            ? l10n.sessionsCount(attendanceCount)
                            : l10n.countOverTarget(
                            attendanceCount, widget.weeklyTarget),
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (isComplete && animProgress > 0.9) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFF4CAF50)
                                .withOpacity(0.15),
                            border: Border.all(
                              color: const Color(0xFF4CAF50)
                                  .withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            l10n.goalMet,
                            style: GoogleFonts.inter(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF81C784),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GradientCircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color primaryColor;
  final Color secondaryColor;
  final Color trackColor;

  _GradientCircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.primaryColor,
    required this.secondaryColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + (2 * math.pi),
      colors: [primaryColor, secondaryColor, primaryColor],
      stops: const [0.0, 0.5, 1.0],
      transform: const GradientRotation(-math.pi / 2),
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = primaryColor.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, glowPaint);
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, progressPaint);

    final endAngle = -math.pi / 2 + sweepAngle;
    final endPoint = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );

    canvas.drawCircle(
      endPoint,
      strokeWidth * 0.6,
      Paint()
        ..color = secondaryColor.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.drawCircle(
      endPoint,
      strokeWidth * 0.35,
      Paint()..color = Colors.white,
    );

    if (progress > 0.02) {
      final startPoint = Offset(
        center.dx + radius * math.cos(-math.pi / 2),
        center.dy + radius * math.sin(-math.pi / 2),
      );

      canvas.drawCircle(
        startPoint,
        strokeWidth * 0.35,
        Paint()..color = Colors.white.withOpacity(0.9),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GradientCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}