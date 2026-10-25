import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../models/fight_model.dart';

class CompetitionScreen extends StatelessWidget {
  const CompetitionScreen({super.key});

  static const Color _green = Color(0xFF3ED598);
  static const Color _red = Color(0xFFE0142B);
  static const Color _redGlow = Color(0xFFFF2033);
  static const Color _greyText = Color(0xFFA0A0A0);

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final l10n = AppLocalizations.of(context);
    final userData = appProvider.userData;
    final fights = appProvider.fights;

    final pastFights = fights.where((f) => !f.isUpcoming).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopLogo(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(l10n),
                        const SizedBox(height: 24),
                        _buildOverallRecord(userData, l10n),
                        const SizedBox(height: 20),
                        if (pastFights.isNotEmpty)
                          _buildLatestFightsBanner(pastFights, l10n)
                        else
                          _buildEmptyHistory(l10n),
                        const SizedBox(height: 32),
                        _buildBottomQuote(l10n),
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

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/competition_bg.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => Container(color: Colors.black),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, 0.1),
                radius: 0.85,
                colors: [
                  Colors.black.withValues(alpha: 0.95),
                  Colors.black.withValues(alpha: 0.80),
                  Colors.black.withValues(alpha: 0.40),
                  Colors.transparent,
                ],
                stops: const [0.2, 0.5, 0.8, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopLogo() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4, bottom: 8),
      child: Image.asset(
        'assets/images/lycans_logo.jpeg',
        width: 90,
        height: 90,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.lycansFightClub,
          style: GoogleFonts.montserrat(
            fontSize: 7,
            letterSpacing: 2.0,
            fontWeight: FontWeight.w400,
            color: _greyText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.everyFight,
          style: GoogleFonts.montserrat(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        Text(
          l10n.tellsAStory,
          style: GoogleFonts.montserrat(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: _redGlow,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        Container(width: 24, height: 1.5, color: _red),
        const SizedBox(height: 12),
        Text(
          l10n.trainFightImprove,
          style: GoogleFonts.montserrat(
            fontSize: 6,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w500,
            color: _greyText,
          ),
        ),
      ],
    );
  }

  Widget _buildOverallRecord(dynamic userData, AppLocalizations l10n) {
    final wins = userData?.wins ?? 0;
    final losses = userData?.losses ?? 0;
    final draws = 0;
    final winsByKO = userData?.winsByKO ?? 0;
    final winsByDecision = userData?.winsByDecision ?? 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('assets/images/stats_bg.png'),
          fit: BoxFit.cover,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(color: Colors.black.withValues(alpha: 0.6)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.overallRecord,
                    style: GoogleFonts.montserrat(
                      fontSize: 7,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w200,
                      color: _greyText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatItem('$wins', l10n.winsLabel, _green)),
                      Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.1)),
                      Expanded(child: _buildStatItem('$losses', l10n.lossesLabel, _red)),
                      Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.1)),
                      Expanded(child: _buildStatItem('$draws', l10n.drawsLabel, _greyText)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withValues(alpha: 0.1), thickness: 1, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$winsByKO',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  l10n.winsByKo,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 9,
                                    color: _greyText,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Icon(
                              Icons.sentiment_very_dissatisfied,
                              color: Colors.white.withValues(alpha: 0.2),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.1)),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$winsByDecision',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  l10n.winsByDecision,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 9,
                                    color: _greyText,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.white.withValues(alpha: 0.2),
                              size: 16,
                            ),
                          ],
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
    );
  }

  Widget _buildStatItem(String value, String label, Color underlineColor) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: underlineColor == _greyText ? Colors.white : underlineColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Container(width: 20, height: 1.5, color: underlineColor),
      ],
    );
  }

  Widget _buildLatestFightsBanner(List<FightModel> pastFights, AppLocalizations l10n) {
    return SizedBox(
      height: 140,
      child: PageView.builder(
        physics: const BouncingScrollPhysics(),
        controller: PageController(viewportFraction: 1.0),
        itemCount: pastFights.length,
        itemBuilder: (context, index) {
          return _buildLatestFightCard(pastFights[index], l10n);
        },
      ),
    );
  }

  Widget _buildLatestFightCard(FightModel fight, AppLocalizations l10n) {
    final isWin = fight.result == 'win';

    return Container(
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('assets/images/recent_bg.png'),
          fit: BoxFit.cover,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: _redGlow,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.latestFight,
                        style: GoogleFonts.montserrat(
                          fontSize: 7,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fight.eventName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${fight.opponentName} .vs',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      color: _greyText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.roundWithDate(
                      fight.round,
                      DateFormat('dd MMM yyyy').format(fight.fightDate),
                    ),
                    style: GoogleFonts.montserrat(
                      fontSize: 8,
                      color: _greyText,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isWin ? l10n.winLabel : l10n.lossLabel,
                          style: GoogleFonts.montserrat(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: isWin ? _green : _red,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          width: 1,
                          height: 9,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          fight.winType,
                          style: GoogleFonts.montserrat(
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
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

  Widget _buildEmptyHistory(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        color: Colors.black.withValues(alpha: 0.4),
      ),
      child: Center(
        child: Text(
          l10n.noFightsRecorded,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomQuote(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '"',
          style: GoogleFonts.montserrat(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: _redGlow,
            height: 0.5,
          ),
        ),
        Text(
          l10n.disciplineTodayFreedomTomorrow,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Container(width: 20, height: 1.5, color: _red),
      ],
    );
  }
}