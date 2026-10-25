import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final items = <_NavItemData>[
      _NavItemData(icon: Icons.home_rounded, label: l10n.navHome),
      _NavItemData(icon: Icons.calendar_today_rounded, label: l10n.navSchedule),
      _NavItemData(icon: Icons.add, label: ''),
      _NavItemData(icon: Icons.location_on_sharp, label: l10n.navBranches),
      _NavItemData(icon: Icons.person_outline_rounded, label: l10n.navProfile),
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
                width: 1,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF151515).withOpacity(0.9),
                  const Color(0xFF000000).withOpacity(0.95),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isCenter = index == 2;
                final isActive = currentIndex == index;

                if (isCenter) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(index),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                        border: Border.all(
                            color: const Color(0xFFFF0000).withOpacity(0.8),
                            width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF0000).withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Image.asset(
                            'assets/images/scratch_icon.png',
                            width: 45,
                            height: 45,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: SizedBox(
                    width: 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 18,
                          color: isActive
                              ? const Color(0xFFFF0000)
                              : Colors.white.withOpacity(0.35),
                          shadows: isActive
                              ? [const Shadow(color: Color(0xFFFF0000), blurRadius: 10)]
                              : null,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: GoogleFonts.montserrat(
                            fontSize: 7,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                            color: isActive
                                ? const Color(0xFFFF0000)
                                : Colors.white.withOpacity(0.35),
                            shadows: isActive
                                ? [const Shadow(color: Color(0xFFFF0000), blurRadius: 8)]
                                : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isActive ? 14 : 0,
                          height: 2,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF0000),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData({required this.icon, required this.label});
}