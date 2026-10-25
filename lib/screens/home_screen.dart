import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import 'membership_screen.dart';
import 'schedule_screen.dart';
import 'progress_screen.dart';
import 'competition_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final l10n = AppLocalizations.of(context);
    final userData = appProvider.userData;
    final membership = appProvider.membership;
    final classes = appProvider.classes;
    final checkIns = appProvider.checkIns;

    final attendancePercent = classes.isEmpty
        ? 0
        : ((checkIns.length / classes.length) * 100).clamp(0, 100).round();

    // ===== SESSIONS LEFT =====
    final String sessionsLeftLabel;
    if (membership == null) {
      sessionsLeftLabel = '0';
    } else if (membership.isUnlimited) {
      sessionsLeftLabel = '∞';
    } else {
      sessionsLeftLabel = '${membership.remainingSessions}';
    }

    const Color darkRed = Color(0xFF990000);
    const Color elegantGold = Color(0xFFE3D6B0);
    const Color mutedGrey = Color(0xFFA0A0A0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 18, right: 18, top: 14, bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ===== PROFİL BÖLÜMÜ =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: elegantGold.withOpacity(0.8), width: 1.5),
                  ),
                  child: ClipOval(
                    child: Image.asset('assets/images/lycans_logo.jpeg',
                        fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData?.fullName ?? '??',
                      style: GoogleFonts.cinzel(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: darkRed, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.change_history,
                              color: darkRed, size: 11),
                          const SizedBox(width: 6),
                          Text(
                            l10n.rank01,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              color: darkRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      l10n.kickboxingMma,
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: mutedGrey,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ===== ISTATISTIKLER =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // === SESSIONS LEFT (eski: Days Left) ===
              _buildStatItem(
                Icons.event_repeat_outlined,
                sessionsLeftLabel,
                'SESSIONS LEFT',
                elegantGold,
              ),
              _buildVerticalDivider(),
              _buildStatItem(Icons.gps_fixed, '$attendancePercent%',
                  l10n.attendanceUpper, elegantGold),
              _buildVerticalDivider(),
              _buildStatItem(Icons.bar_chart_rounded,
                  '${userData?.wins ?? 0}-${userData?.losses ?? 0}',
                  l10n.recordUpper, darkRed),
            ],
          ),
          const SizedBox(height: 22),

          // ===== 4'LÜ KART GRID =====
          Row(
            children: [
              Expanded(
                child: _buildImageCard(
                  title: l10n.membershipCard,
                  subtitle: l10n.yourJourneyStartsHere,
                  icon: Icons.person_outline,
                  bgImage: 'assets/images/membership_card_bg.png',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MembershipScreen())),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildImageCard(
                  title: l10n.scheduleCard,
                  subtitle: l10n.planYourTrainingSessions,
                  icon: Icons.calendar_today_outlined,
                  bgImage: 'assets/images/schedule_card_bg.png',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ScheduleScreen())),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildImageCard(
                  title: l10n.progressCard,
                  subtitle: l10n.trackYourImprovement,
                  icon: Icons.trending_up,
                  bgImage: 'assets/images/progress_card_bg.png',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProgressScreen())),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildImageCard(
                  title: l10n.fightsCard,
                  subtitle: l10n.stepIntoTheCage,
                  icon: Icons.hexagon_outlined,
                  bgImage: 'assets/images/fight_card_bg.png',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CompetitionScreen())),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ===== COACH'S NOTE =====
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.06), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.2)),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/lycans_logo.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.coachsNote,
                            style: GoogleFonts.cinzel(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.coachNoteText,
                            style: GoogleFonts.montserrat(
                              fontSize: 8,
                              height: 1.35,
                              color: mutedGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white.withOpacity(0.3), size: 12),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 26),

          // ===== FOOTER =====
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: 26,
                  height: 1,
                  color: elegantGold.withOpacity(0.4)),
              const SizedBox(width: 14),
              Text(
                l10n.fearlessFighters,
                style: GoogleFonts.cinzel(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  color: elegantGold.withOpacity(0.55),
                  letterSpacing: 4.4,
                ),
              ),
              const SizedBox(width: 14),
              Container(
                  width: 26,
                  height: 1,
                  color: elegantGold.withOpacity(0.4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.cinzel(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 8,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withOpacity(0.12),
    );
  }

  Widget _buildImageCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String bgImage,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 132,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFCC0000).withOpacity(0.14),
              blurRadius: 18,
              spreadRadius: 0.5,
            ),
          ],
          gradient: const LinearGradient(
            colors: [Color(0xFFB30000), Colors.black, Color(0xFF8B0000)],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(1.2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.black,
            image: DecorationImage(
              image: AssetImage(bgImage),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.0),
                BlendMode.darken,
              ),
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF8B0000), width: 1),
                      ),
                      child: Center(
                        child:
                        Icon(icon, color: Colors.white, size: 13),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.cinzel(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: GoogleFonts.montserrat(
                            fontSize: 7,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                            letterSpacing: 0.3,
                            color: const Color(0xFFA0A0A0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.3),
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}