import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../models/branch_model.dart';
import '../providers/app_provider.dart';
import 'branch_details_screen.dart';

final Color generalGlassDark = const Color(0xFF0F1115).withOpacity(0.5);
final Color glassBorder = Colors.white.withOpacity(0.04);

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final l10n = AppLocalizations.of(context);
    final branches = appProvider.branches
        .where((b) => b.isActive)
        .where((b) =>
    b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        b.address.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.ourUpper,
                          style: GoogleFonts.oswald(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 6,
                            color: Colors.white.withValues(alpha: 0.4),
                            height: 1.2,
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
                              Color(0xFFB0B0B0),
                              Color(0xFF808080),
                            ],
                            stops: [0.0, 0.4, 0.75, 1.0],
                          ).createShader(bounds),
                          child: Text(
                            l10n.branchesTitle,
                            style: GoogleFonts.oswald(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: Colors.white,
                              height: 0.98,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.differentPlaces,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 8.5,
                            letterSpacing: 2.5,
                            color: Colors.white.withValues(alpha: 0.40),
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          l10n.sameSpiritUpper,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 8.5,
                            letterSpacing: 2.5,
                            color: Colors.white.withValues(alpha: 0.40),
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: 21,
                          height: 2.5,
                          color: const Color(0xFFE60023),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
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
                              Icon(
                                Icons.search,
                                color: Colors.white.withValues(alpha: 0.45),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  onChanged: (value) =>
                                      setState(() => _searchQuery = value),
                                  style: GoogleFonts.manrope(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: l10n.searchBranch,
                                    hintStyle: GoogleFonts.manrope(
                                      color: Colors.white
                                          .withValues(alpha: 0.35),
                                      fontSize: 9.5,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (branches.isEmpty)
                    _buildEmptyState(l10n)
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: branches.length,
                      itemBuilder: (context, index) {
                        return _buildBranchCard(
                          branches[index],
                          index: index,
                          isFirst: index == 0,
                          total: branches.length,
                          l10n: l10n,
                        );
                      },
                    ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBranchBg(String branchId) {
    final hash = branchId.codeUnits.fold<int>(0, (prev, curr) => prev + curr);
    final index = (hash % 3) + 1;
    return 'assets/images/branch${index}_card_bg.png';
  }

  Widget _buildBranchCard(
      BranchModel branch, {
        required int index,
        required bool isFirst,
        required int total,
        required AppLocalizations l10n,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFirst
                ? const Color(0xFFE60023).withValues(alpha: 0.65)
                : Colors.white.withValues(alpha: 0.08),
            width: isFirst ? 1.5 : 1,
          ),
          boxShadow: isFirst
              ? [
            BoxShadow(
              color: const Color(0xFFE60023).withValues(alpha: 0.35),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.5),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                _getBranchBg(branch.id),
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF1A1610)),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.95),
                      Colors.black.withValues(alpha: 0.85),
                      Colors.black.withValues(alpha: 0.55),
                      Colors.black.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.3, 0.55, 0.8, 1.0],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 16, 14, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 9,
                                color: isFirst
                                    ? const Color(0xFFE60023)
                                    : Colors.white.withValues(alpha: 0.55),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isFirst ? l10n.mainBranch : l10n.branchLabel,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 7.5,
                                  letterSpacing: 1.8,
                                  fontWeight: FontWeight.w700,
                                  color: isFirst
                                      ? const Color(0xFFE60023)
                                      : Colors.white.withValues(alpha: 0.55),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                branch.name,
                                style: GoogleFonts.oswald(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.0,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 13,
                                    color: Colors.white.withValues(alpha: 0.65),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      branch.address.isNotEmpty
                                          ? branch.address
                                          : l10n.branchSuffix(branch.name),
                                      style: GoogleFonts.manrope(
                                        fontSize: 9.5,
                                        color: Colors.white
                                            .withValues(alpha: 0.55),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => _showBranchDetails(branch),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.black.withValues(alpha: 0.55),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.18),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.viewDetails,
                                    style: GoogleFonts.manrope(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white
                                          .withValues(alpha: 0.62),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 10,
                                    color:
                                    Colors.white.withValues(alpha: 0.92),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showBranchDetails(branch),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 15,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBranchDetails(BranchModel branch) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BranchDetailsScreen(branch: branch),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.03),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 48,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noBranchesAvailable,
            style: GoogleFonts.oswald(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.checkBackSoon,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}