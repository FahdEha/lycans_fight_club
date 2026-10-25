import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/package_model.dart';
import '../models/membership_model.dart';
import '../models/invoice_model.dart';
import '../providers/app_provider.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({Key? key}) : super(key: key);

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _plansKey = GlobalKey();

  late AnimationController _arcAnimController;
  late Animation<double> _arcAnimation;

  static const Color colorVoid = Color(0xFF050505);
  static const Color colorCardBg = Color(0xFF101012);
  static const Color colorSurface = Color(0xFF161618);
  static const Color colorLine = Color(0xFF2A2A2E);
  static const Color colorTextPrimary = Color(0xFFF0F0F0);
  static const Color colorTextDim = Color(0xFF8E8E93);
  static const Color colorTextMuted = Color(0xFF5C5C60);

  static const Color colorRed = Color(0xFFE31E24);
  static const Color colorRedGlow = Color(0x40E31E24);
  static const Color colorActiveGreen = Color(0xFF34C759);

  bool _showUpgrade = false;
  bool _showDowngrade = false;

  @override
  void initState() {
    super.initState();
    _arcAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _arcAnimation = CurvedAnimation(
      parent: _arcAnimController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    );
    _arcAnimController.forward();
  }

  @override
  void dispose() {
    _arcAnimController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToPlans() {
    final context = _plansKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _toggleUpgrade() {
    setState(() {
      _showUpgrade = !_showUpgrade;
      if (_showUpgrade) _showDowngrade = false;
    });
    Future.delayed(const Duration(milliseconds: 100), _scrollToPlans);
  }

  void _toggleDowngrade() {
    setState(() {
      _showDowngrade = !_showDowngrade;
      if (_showDowngrade) _showUpgrade = false;
    });
    Future.delayed(const Duration(milliseconds: 100), _scrollToPlans);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final l10n = AppLocalizations.of(context);
    final MembershipModel? currentMembership = provider.membership;
    final List<PackageModel> packages = provider.packages;
    final List<InvoiceModel> invoices = provider.invoices;

    return Scaffold(
      backgroundColor: colorVoid,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/membership_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: colorVoid),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 1.0],
                  colors: [
                    colorVoid.withOpacity(0.3),
                    colorVoid.withOpacity(0.85),
                    colorVoid,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 100, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(l10n),
                  const SizedBox(height: 24),
                  _buildMainTicketCard(currentMembership, l10n),
                  const SizedBox(height: 16),
                  _buildActions(currentMembership, provider, l10n),
                  const SizedBox(height: 12),
                  _buildPaymentHistory(invoices, l10n),
                  const SizedBox(height: 10),
                  _buildPackagesSection(
                      packages, currentMembership, provider, l10n),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.membershipTitle,
          style: GoogleFonts.inter(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.5,
            color: colorRed,
          ),
        ),
        const SizedBox(height: 4),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFF808080),
              Color(0xFFC0C0C0),
              Colors.white,
            ],
            stops: [0.0, 0.4, 1.0],
          ).createShader(bounds),
          child: Text(
            l10n.yourSubscription,
            style: GoogleFonts.anton(
              fontSize: 42,
              height: 1.0,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.subscriptionSubtitle,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: colorTextDim,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildMainTicketCard(
      MembershipModel? membership, AppLocalizations l10n) {
    final int daysLeft = membership?.daysLeft ?? 0;
    final int duration = membership?.durationDays ?? 30;
    final double progressRatio =
    duration > 0 ? (daysLeft / duration).clamp(0.0, 1.0) : 0.0;
    final int daysElapsed = duration - daysLeft;

    final String planTitle = (membership?.planName.isNotEmpty ?? false)
        ? membership!.planName.toUpperCase()
        : l10n.noActivePlan;

    final String renewFormatted = membership != null
        ? DateFormat('dd MMM').format(membership.renewDate)
        : '—';

    final String sessionsVal = membership != null
        ? (membership.isUnlimited
        ? '∞'
        : l10n.sessionsLeft(membership.remainingSessions))
        : l10n.noneLabel;

    return Container(
      decoration: BoxDecoration(
        color: colorCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorLine, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 24,
            bottom: 24,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: colorRed,
                boxShadow: const [
                  BoxShadow(
                    color: colorRed,
                    blurRadius: 12,
                    spreadRadius: 1.5,
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.currentPlanUpper,
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              letterSpacing: 1.5,
                              color: colorTextMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            planTitle,
                            style: GoogleFonts.anton(
                              fontSize: 18,
                              letterSpacing: 0.5,
                              color: colorTextPrimary,
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildActiveStamp(membership?.isActive ?? false, l10n),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      width: 95,
                      height: 95,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _arcAnimation,
                            builder: (context, child) {
                              return CustomPaint(
                                size: const Size(95, 95),
                                painter: _ClockArcPainter(
                                  progress:
                                  progressRatio * _arcAnimation.value,
                                ),
                              );
                            },
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$daysLeft',
                                style: GoogleFonts.anton(
                                  fontSize: 28,
                                  height: 1,
                                  color: colorTextPrimary,
                                ),
                              ),
                              Text(
                                l10n.daysLeftCap,
                                style: GoogleFonts.inter(
                                  fontSize: 7,
                                  letterSpacing: 1.0,
                                  color: colorTextDim,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          _buildStatRow(Icons.all_inclusive_rounded,
                              sessionsVal, l10n.sessionsCap),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Divider(color: colorLine, height: 1),
                          ),
                          _buildStatRow(Icons.calendar_today_outlined,
                              renewFormatted, l10n.renewsCap),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Divider(color: colorLine, height: 1),
                          ),
                          _buildStatRow(Icons.access_time_rounded,
                              l10n.daysSuffix(duration), l10n.durationCap),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: colorLine,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: daysElapsed,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorRed,
                                  borderRadius: BorderRadius.circular(1.5),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: colorRedGlow,
                                      blurRadius: 4,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: daysLeft,
                              child: const SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$daysElapsed / $duration ${l10n.daysLeftCap}',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        letterSpacing: 1.0,
                        color: colorTextDim,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 12, color: colorTextDim),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colorTextPrimary,
            ),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 8,
            letterSpacing: 1.0,
            color: colorTextMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveStamp(bool isActive, AppLocalizations l10n) {
    final dotColor = isActive ? colorActiveGreen : colorTextMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorCardBg,
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            colorCardBg,
            Colors.black.withOpacity(0.5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.03),
            offset: const Offset(-1, -1),
            blurRadius: 2,
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.02), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                BoxShadow(
                    color: dotColor.withOpacity(0.6), blurRadius: 4)
              ]
                  : [],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? l10n.activeStatus : l10n.expiredStatus,
            style: GoogleFonts.inter(
              fontSize: 8,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: colorTextDim,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(MembershipModel? membership, AppProvider provider,
      AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _scrollToPlans,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: colorCardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorLine),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt_rounded, size: 14, color: colorRed),
                  const SizedBox(width: 6),
                  Text(
                    l10n.changePlan,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: colorTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () {
              if (membership == null) return _scrollToPlans();
              _showConfirmDialog(
                title: l10n.renewSubscription,
                content: l10n.renewPlanConfirm(membership.durationDays),
                onConfirm: () async {
                  await provider.renewMembership();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.planRenewed)),
                    );
                  }
                },
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: colorCardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorLine),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sync_rounded,
                      size: 14, color: colorTextDim),
                  const SizedBox(width: 6),
                  Text(
                    l10n.renewNow,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: colorTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistory(
      List<InvoiceModel> invoices, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              l10n.paymentHistory,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: colorTextPrimary,
              ),
            ),
            Text(
              l10n.receiptsCount(invoices.length),
              style: GoogleFonts.inter(
                fontSize: 8,
                letterSpacing: 1.5,
                color: colorTextMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: colorCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorLine, width: 1),
          ),
          child: invoices.isEmpty
              ? Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                l10n.noReceiptsYet,
                style: GoogleFonts.inter(
                    fontSize: 10, color: colorTextDim),
              ),
            ),
          )
              : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: invoices.length,
            separatorBuilder: (context, index) =>
            const Divider(color: colorLine, height: 1),
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colorVoid,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorLine),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        size: 14,
                        color: colorTextDim,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoice.description,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colorTextPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('dd MMM yyyy')
                                .format(invoice.date),
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: colorTextDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Text(
                          invoice.amount <= 0
                              ? '0'
                              : NumberFormat('#,###')
                              .format(invoice.amount),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colorRed,
                          ),
                        ),
                        Text(
                          ' EGP',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: colorRed,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded,
                            size: 14, color: colorTextMuted),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPackagesSection(
      List<PackageModel> packages,
      MembershipModel? currentMembership,
      AppProvider provider,
      AppLocalizations l10n,
      ) {
    final activePackages = packages.where((p) => p.isActive).toList();
    activePackages.sort((a, b) => a.price.compareTo(b.price));

    PackageModel? currentPkg;
    List<PackageModel> upgrades = [];
    List<PackageModel> downgrades = [];

    if (currentMembership != null) {
      try {
        currentPkg = activePackages.firstWhere(
              (p) =>
          p.id == currentMembership.packageId ||
              p.name.trim().toLowerCase() ==
                  currentMembership.planName.trim().toLowerCase(),
        );
        upgrades =
            activePackages.where((p) => p.price > currentPkg!.price).toList();
        downgrades =
            activePackages.where((p) => p.price < currentPkg!.price).toList();
      } catch (e) {
        // Fallback
      }
    }

    return Column(
      key: _plansKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              l10n.packagesUpper,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: colorTextPrimary,
              ),
            ),
            Text(
              l10n.chooseYourPlan,
              style: GoogleFonts.inter(
                fontSize: 8,
                letterSpacing: 1.5,
                color: colorTextMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (currentPkg != null) ...[
          _buildPlanCard(
            package: currentPkg,
            isCurrent: true,
            provider: provider,
            l10n: l10n,
            hasPendingRequest: provider.hasPendingRequestFor(currentPkg.id),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildExpandButton(
                  title: l10n.upgradePlan,
                  subtitle: l10n.unlockMoreFeatures,
                  icon: Icons.arrow_upward_rounded,
                  isActive: _showUpgrade,
                  onTap: _toggleUpgrade,
                  enabled: upgrades.isNotEmpty,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildExpandButton(
                  title: l10n.downgradePlan,
                  subtitle: l10n.switchToLighterPlan,
                  icon: Icons.arrow_downward_rounded,
                  isActive: _showDowngrade,
                  onTap: _toggleDowngrade,
                  enabled: downgrades.isNotEmpty,
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Column(
              children: [
                if (_showUpgrade) ...[
                  const SizedBox(height: 10),
                  ...upgrades.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildPlanCard(
                        package: p,
                        isCurrent: false,
                        provider: provider,
                        l10n: l10n,
                        type: 'upgrade'),
                  )),
                ],
                if (_showDowngrade) ...[
                  const SizedBox(height: 10),
                  ...downgrades.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildPlanCard(
                        package: p,
                        isCurrent: false,
                        provider: provider,
                        l10n: l10n,
                        type: 'downgrade'),
                  )),
                  if (downgrades.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorCardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colorLine),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 12, color: colorTextDim),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.downgradeInfo(
                                DateFormat('dd MMM yyyy').format(
                                    currentMembership!.renewDate),
                              ),
                              style: GoogleFonts.inter(
                                  fontSize: 8,
                                  color: colorTextDim,
                                  height: 1.4),
                            ),
                          )
                        ],
                      ),
                    )
                  ]
                ],
              ],
            ),
          ),
        ] else ...[
          ...activePackages.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildPlanCard(
                package: p,
                isCurrent: false,
                provider: provider,
                l10n: l10n,
                type: 'upgrade'),
          )),
        ]
      ],
    );
  }

  Widget _buildExpandButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: colorCardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? colorRed : colorLine),
          boxShadow: isActive
              ? [const BoxShadow(color: colorRedGlow, blurRadius: 6)]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                Border.all(color: enabled ? colorTextDim : colorLine),
              ),
              child: Icon(icon,
                  size: 10,
                  color: enabled ? colorTextPrimary : colorLine),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: enabled ? colorTextPrimary : colorTextMuted,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 7,
                      color: enabled ? colorTextDim : colorLine,
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

  Widget _buildPlanCard({
    required PackageModel package,
    required bool isCurrent,
    required AppProvider provider,
    required AppLocalizations l10n,
    String type = '',
    bool hasPendingRequest = false,
  }) {
    String badgeText = '';
    if (isCurrent) badgeText = l10n.bestValue;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorVoid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent ? colorRed.withOpacity(0.6) : colorLine,
          width: isCurrent ? 1.2 : 1.0,
        ),
        boxShadow: isCurrent
            ? [
          BoxShadow(
            color: colorRed.withOpacity(0.12),
            blurRadius: 15,
            spreadRadius: 1,
          )
        ]
            : [],
        image: DecorationImage(
          image: AssetImage(isCurrent
              ? 'assets/images/current_bg.png'
              : 'assets/images/plan_bg.png'),
          fit: BoxFit.cover,
          alignment: Alignment.centerLeft,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: isCurrent ? 80 : 70),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorCardBg.withOpacity(0.97),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  border: Border(
                    left: BorderSide(
                        color: isCurrent
                            ? colorRed.withOpacity(0.3)
                            : Colors.white10),
                  ),
                ),
                padding: const EdgeInsets.only(
                    left: 14, right: 10, top: 10, bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCurrent) ...[
                            Text(
                              l10n.yourCurrentPlan,
                              style: GoogleFonts.inter(
                                fontSize: 7,
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.w600,
                                color: colorRed,
                                height: 1.0,
                              ),
                              maxLines: 1,
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            package.name.toUpperCase(),
                            style: GoogleFonts.anton(
                              fontSize: 14,
                              letterSpacing: 0.5,
                              color: colorTextPrimary,
                              height: 1.1,
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  NumberFormat('#,###')
                                      .format(package.price),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: colorRed,
                                  ),
                                ),
                                Text(
                                  ' EGP ',
                                  style: GoogleFonts.inter(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: colorRed,
                                  ),
                                ),
                                Text(
                                  '/ ${l10n.daysLeftShort(package.durationDays)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 7,
                                    color: colorTextDim,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (package.maxSessions > 0) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorVoid,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: colorLine),
                              ),
                              child: Text(
                                l10n.sessionsPerMonth(package.maxSessions),
                                style: GoogleFonts.inter(
                                  fontSize: 6,
                                  fontWeight: FontWeight.w600,
                                  color: colorTextDim,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: package.features
                            .take(3)
                            .map((feat) => Padding(
                          padding:
                          const EdgeInsets.only(bottom: 2),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 1),
                                child: Icon(Icons.check_rounded,
                                    size: 8, color: colorRed),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  feat,
                                  style: GoogleFonts.inter(
                                    fontSize: 7.5,
                                    color: colorTextPrimary,
                                    height: 1.1,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isCurrent && badgeText.isNotEmpty)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorRed.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: colorRed.withOpacity(0.5)),
                            ),
                            child: Text(
                              badgeText,
                              style: GoogleFonts.inter(
                                fontSize: 6,
                                fontWeight: FontWeight.w700,
                                color: colorRed,
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (!isCurrent)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildActionCircle(
                            type: type,
                            l10n: l10n,
                            onTap: () {
                              _showConfirmDialog(
                                title: l10n.confirmPlan,
                                content: l10n.switchToPlanConfirm(
                                  package.name,
                                  NumberFormat('#,###')
                                      .format(package.price),
                                ),
                                onConfirm: () async {
                                  await provider.requestPlanChange(
                                    requestedPackage: package,
                                    type: type,
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.requestSent),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    if (hasPendingRequest)
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.orange.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.pendingLabel,
                              style: GoogleFonts.inter(
                                fontSize: 6.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.orange,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCircle({
    required String type,
    required AppLocalizations l10n,
    required VoidCallback onTap,
  }) {
    IconData icon = type == 'upgrade'
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;
    String label =
    type == 'upgrade' ? l10n.upgradeLabel : l10n.downgradeLabel;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorRed, width: 1.0),
              color: colorVoid,
            ),
            child: Icon(icon, color: colorRed, size: 12),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 6.5,
              fontWeight: FontWeight.w700,
              color: colorRed,
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext);
        return AlertDialog(
          backgroundColor: colorCardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: colorLine),
          ),
          title: Text(
            title,
            style: GoogleFonts.anton(color: colorTextPrimary, fontSize: 16),
          ),
          content: Text(
            content,
            style: GoogleFonts.inter(color: colorTextDim, fontSize: 11),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                l10n.cancel,
                style: GoogleFonts.inter(
                    color: colorTextMuted, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                onConfirm();
              },
              child: Text(
                l10n.confirm,
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ==========================================
// CUSTOM PAINTERS
// ==========================================

class _ClockArcPainter extends CustomPainter {
  final double progress;

  _ClockArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;

    final trackPaint = Paint()
      ..color = const Color(0xFF2A2A2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;
    canvas.drawCircle(center, radius, trackPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepAngle = 2 * math.pi * progress;

    final arcPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE31E24), Color(0xFFFF5A5A)],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ClockArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}