import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';

class QRCheckinScreen extends StatefulWidget {
  const QRCheckinScreen({super.key});

  @override
  State<QRCheckinScreen> createState() => _QRCheckinScreenState();
}

class _QRCheckinScreenState extends State<QRCheckinScreen>
    with TickerProviderStateMixin {
  late AnimationController _enterController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildFadeSlide(Widget child, double start, double end) {
    final animation = CurvedAnimation(
      parent: _enterController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  Widget _buildMetallicText(String text, double fontSize,
      {double letterSpacing = 1.0}) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Color(0xFF4A4A4A),
          Colors.white,
          Color(0xFFC0C0C0),
        ],
        stops: [0.0, 0.6, 1.0],
      ).createShader(bounds),
      child: Text(
        text,
        style: GoogleFonts.bebasNeue(
          fontSize: fontSize,
          color: Colors.white,
          height: 1.1,
          letterSpacing: letterSpacing,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final l10n = AppLocalizations.of(context);
    final userData = appProvider.userData;
    final membership = appProvider.membership;

    final qrData =
        'LYCANS_FIGHT_CLUB|${userData?.uid ?? ''}|${DateTime.now().millisecondsSinceEpoch}';

    final bool isActive = membership?.isActive == true;
    final bool isUnlimited = membership?.isUnlimited == true;
    final String remainingSessions =
    isUnlimited ? '∞' : '${membership?.remainingSessions ?? 0}';
    final String sessionText = isUnlimited
        ? l10n.unlimitedSessions
        : l10n.sessionsRemaining(membership?.remainingSessions ?? 0);

    const Color accentRed = Color(0xFFE52020);
    const Color bloodRed = Color(0xFFA61111);
    const Color textFaded = Color(0xFFA5B2BE);

    final Color glassBorder = Colors.white.withOpacity(0.04);
    final Color generalGlassDark = const Color(0xFF0F1115).withOpacity(0.5);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 5),
                  _buildFadeSlide(
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset('assets/images/lycans_logo.jpeg',
                          height: 60),
                    ),
                    0.0, 0.4,
                  ),
                  const SizedBox(height: 12),
                  _buildFadeSlide(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              l10n.attendanceUpper,
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                letterSpacing: 3,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 16,
                              height: 1.5,
                              decoration: BoxDecoration(
                                color: accentRed,
                                boxShadow: [
                                  BoxShadow(
                                      color: accentRed.withOpacity(0.5),
                                      blurRadius: 4)
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        _buildMetallicText(l10n.checkInUpper, 42,
                            letterSpacing: 1.5),
                        const SizedBox(height: 4),
                        Text(
                          l10n.scanQrDesc,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            color: textFaded,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                    0.1, 0.5,
                  ),
                  const SizedBox(height: 10),

                  _buildFadeSlide(
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: generalGlassDark,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: glassBorder),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '[  ',
                                          style: GoogleFonts.inter(
                                            color: accentRed,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          l10n.scanQrCode,
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 8,
                                            letterSpacing: 2,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Icon(Icons.qr_code_scanner,
                                        color: Colors.white54, size: 16),
                                  ],
                                ),
                                const SizedBox(height: 9),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter:
                                    ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color:
                                        Colors.white.withOpacity(0.02),
                                        borderRadius:
                                        BorderRadius.circular(16),
                                        border: Border.all(
                                            color: Colors.white
                                                .withOpacity(0.04)),
                                      ),
                                      child: SizedBox(
                                        width: 190,
                                        height: 190,
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: Container(
                                                width: 175,
                                                height: 175,
                                                padding:
                                                const EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      6),
                                                ),
                                                child: QrImageView(
                                                  data: qrData,
                                                  version: QrVersions.auto,
                                                  backgroundColor:
                                                  Colors.white,
                                                  eyeStyle:
                                                  const QrEyeStyle(
                                                      eyeShape:
                                                      QrEyeShape
                                                          .square,
                                                      color:
                                                      Colors.black),
                                                  dataModuleStyle:
                                                  const QrDataModuleStyle(
                                                      dataModuleShape:
                                                      QrDataModuleShape
                                                          .square,
                                                      color:
                                                      Colors.black),
                                                ),
                                              ),
                                            ),
                                            _buildCornerBracket(
                                                Alignment.topLeft, accentRed),
                                            _buildCornerBracket(
                                                Alignment.topRight, accentRed),
                                            _buildCornerBracket(
                                                Alignment.bottomLeft,
                                                accentRed),
                                            _buildCornerBracket(
                                                Alignment.bottomRight,
                                                accentRed),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF050608)
                                        .withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Colors.white
                                            .withOpacity(0.03)),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AnimatedBuilder(
                                            animation: _pulseController,
                                            builder: (context, child) {
                                              return Container(
                                                width: 6,
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                      0xFF5CE0C2),
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(
                                                          0xFF5CE0C2)
                                                          .withOpacity(0.5 +
                                                          (_pulseController
                                                              .value *
                                                              0.5)),
                                                      blurRadius: 3 +
                                                          (_pulseController
                                                              .value *
                                                              5),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.readyToCheckin,
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 8,
                                              letterSpacing: 1.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.history,
                                              color: textFaded, size: 10),
                                          const SizedBox(width: 4),
                                          Text(
                                            l10n.codeRefreshes,
                                            style: GoogleFonts.inter(
                                                color: textFaded,
                                                fontSize: 8),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    0.2, 0.6,
                  ),
                  const SizedBox(height: 6),

                  _buildFadeSlide(
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: generalGlassDark,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: glassBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF0F1115),
                                  border: Border.all(
                                      color: isActive
                                          ? accentRed
                                          : Colors.grey,
                                      width: 1.5),
                                  boxShadow: isActive
                                      ? [
                                    BoxShadow(
                                        color: accentRed
                                            .withOpacity(0.2),
                                        blurRadius: 10,
                                        spreadRadius: 1)
                                  ]
                                      : [],
                                ),
                                child: Center(
                                  child: isUnlimited
                                      ? const Icon(Icons.all_inclusive,
                                      color: Colors.white, size: 20)
                                      : Text(remainingSessions,
                                      style: GoogleFonts.bebasNeue(
                                          color: Colors.white,
                                          fontSize: 22)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.membershipUpper,
                                      style: GoogleFonts.inter(
                                          color: textFaded,
                                          fontSize: 7,
                                          letterSpacing: 2,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    _buildMetallicText(
                                        isActive
                                            ? l10n.activeUpper
                                            : l10n.inactiveUpper,
                                        24,
                                        letterSpacing: 1.2),
                                    Text(
                                      sessionText,
                                      style: GoogleFonts.inter(
                                          color: textFaded, fontSize: 9),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.03),
                                  border: Border.all(
                                      color:
                                      Colors.white.withOpacity(0.08)),
                                ),
                                child: const Icon(Icons.chevron_right,
                                    color: Colors.white54, size: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    0.3, 0.7,
                  ),
                  const SizedBox(height: 6),

                  _buildFadeSlide(
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          decoration: BoxDecoration(
                            color: generalGlassDark,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: glassBorder),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              _buildActionItem(Icons.fitness_center,
                                  l10n.trainAction, l10n.buildYourSkills, bloodRed),
                              _buildVerticalDivider(),
                              _buildActionItem(
                                  Icons.calendar_today_outlined,
                                  l10n.scheduleAction,
                                  l10n.viewYourPlan,
                                  bloodRed),
                              _buildVerticalDivider(),
                              _buildActionItem(Icons.list_alt,
                                  l10n.quickActions, l10n.moreOptions, bloodRed),
                            ],
                          ),
                        ),
                      ),
                    ),
                    0.4, 0.8,
                  ),
                  const SizedBox(height: 6),

                  _buildFadeSlide(
                    Container(
                      width: double.infinity,
                      height: 65,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: AssetImage(
                              'assets/images/freedom_card_bg.png'),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                              Colors.black.withOpacity(0.7)
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.disciplineBuilds,
                                style: GoogleFonts.inter(
                                    color: textFaded,
                                    fontSize: 7,
                                    letterSpacing: 3,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 1),
                              _buildMetallicText(l10n.freedom, 26,
                                  letterSpacing: 2.5),
                              const SizedBox(height: 2),
                              Container(
                                width: 16,
                                height: 1.5,
                                decoration: BoxDecoration(
                                  color: accentRed,
                                  boxShadow: [
                                    BoxShadow(
                                        color: accentRed.withOpacity(0.5),
                                        blurRadius: 4)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    0.5, 0.9,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCornerBracket(Alignment alignment, Color color) {
    BorderSide top = (alignment == Alignment.topLeft ||
        alignment == Alignment.topRight)
        ? BorderSide(color: color, width: 1.5)
        : BorderSide.none;
    BorderSide bottom = (alignment == Alignment.bottomLeft ||
        alignment == Alignment.bottomRight)
        ? BorderSide(color: color, width: 1.5)
        : BorderSide.none;
    BorderSide left = (alignment == Alignment.topLeft ||
        alignment == Alignment.bottomLeft)
        ? BorderSide(color: color, width: 1.5)
        : BorderSide.none;
    BorderSide right = (alignment == Alignment.topRight ||
        alignment == Alignment.bottomRight)
        ? BorderSide(color: color, width: 1.5)
        : BorderSide.none;

    BorderRadius radius = BorderRadius.only(
      topLeft: alignment == Alignment.topLeft
          ? const Radius.circular(6)
          : Radius.zero,
      topRight: alignment == Alignment.topRight
          ? const Radius.circular(6)
          : Radius.zero,
      bottomLeft: alignment == Alignment.bottomLeft
          ? const Radius.circular(6)
          : Radius.zero,
      bottomRight: alignment == Alignment.bottomRight
          ? const Radius.circular(6)
          : Radius.zero,
    );

    return Align(
      alignment: alignment,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          border:
          Border(top: top, bottom: bottom, left: left, right: right),
          borderRadius: radius,
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white.withOpacity(0.05),
    );
  }

  Widget _buildActionItem(
      IconData icon, String title, String subtitle, Color iconColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 7.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                color: const Color(0xFFA5B2BE),
                fontSize: 6.5,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}