import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/menu_overlay.dart';
import 'home_screen.dart';
import 'membership_screen.dart';
import 'qr_checkin_screen.dart';
import 'schedule_screen.dart';
import 'training_screen.dart';
import 'progress_screen.dart';
import 'competition_screen.dart';
import 'notifications_screen.dart';
import 'payments_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _menuOpen = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ScheduleScreen(),
    const QRCheckinScreen(),
    const TrainingScreen(),
    const ProfileScreen(),
  ];

  void _navigateTo(int index) {
    setState(() {
      _currentIndex = index;
      _menuOpen = false;
    });
  }

  void _navigateToScreen(String screenName) {
    setState(() {
      _menuOpen = false;
    });

    switch (screenName) {
      case 'home':
        setState(() => _currentIndex = 0);
        break;
      case 'schedule':
        setState(() => _currentIndex = 1);
        break;
      case 'qr':
        setState(() => _currentIndex = 2);
        break;
      case 'training':
        setState(() => _currentIndex = 3);
        break;
      case 'profile':
        setState(() => _currentIndex = 4);
        break;
      case 'membership':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MembershipScreen()),
        );
        break;
      case 'progress':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProgressScreen()),
        );
        break;
      case 'competition':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CompetitionScreen()),
        );
        break;
      case 'notifications':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        );
        break;
      case 'payments':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaymentsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final userData = appProvider.userData;

    const Color paleGold = Color(0xFFE3D6B0);
    const Color softWatermelon = Color(0xFFD98A8F);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              _currentIndex == 2
                  ? 'assets/images/qr_bg.png'
                  : _currentIndex == 3
                  ? 'assets/images/branches_bg.png'
                  : 'assets/images/lycans_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                if (_currentIndex != 3)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'L Y C A N S',
                              style: TextStyle(
                                fontFamily: 'Pi Sheng',
                                fontSize: 17,
                                color: paleGold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 1,
                                  color: paleGold.withOpacity(0.4),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'FIGHT CLUB',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 6.5,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 3.8,
                                    color: Colors.white.withOpacity(0.55),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 22,
                                  height: 1,
                                  color: paleGold.withOpacity(0.4),
                                ),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _navigateToScreen('notifications'),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.4),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none_rounded,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 20,
                                ),
                                if (appProvider.unreadNotificationsCount > 0)
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: softWatermelon,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _screens,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNav(
              currentIndex: _currentIndex,
              onTap: _navigateTo,
            ),
          ),
          if (_menuOpen)
            MenuOverlay(
              onClose: () => setState(() => _menuOpen = false),
              onNavigate: _navigateToScreen,
              userData: userData,
            ),
        ],
      ),
    );
  }
}