import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';

class MenuOverlay extends StatelessWidget {
  final VoidCallback onClose;
  final Function(String) onNavigate;
  final UserModel? userData;

  const MenuOverlay({
    super.key,
    required this.onClose,
    required this.onNavigate,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Color(0xFF060503).withValues(alpha: 0.88),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Features',
                      style: TextStyle(
                        fontFamily: 'Oswald',
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: Color(AppConstants.ink),
                      ),
                    ),
                    GestureDetector(
                      onTap: onClose,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          color: Color(AppConstants.bgCard),
                          border: Border.all(color: Color(AppConstants.ink).withValues(alpha: 0.07)),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Color(AppConstants.ink),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _buildMenuItem(Icons.home, 'Dashboard', 'home'),
                      _buildMenuItem(Icons.credit_card, 'Membership', 'membership'),
                      _buildMenuItem(Icons.qr_code, 'QR Check-in', 'qr'),
                      _buildMenuItem(Icons.calendar_today, 'Schedule', 'schedule'),
                      _buildMenuItem(Icons.fitness_center, 'My Training', 'training'),
                      _buildMenuItem(Icons.bar_chart, 'Progress', 'progress'),
                      _buildMenuItem(Icons.sports_mma, 'Competition', 'competition'),
                      _buildMenuItem(Icons.payment, 'Payments', 'payments'),
                      _buildMenuItem(Icons.notifications, 'Notifications', 'notifications'),
                      _buildMenuItem(Icons.person, 'Profile', 'profile'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, String screenName) {
    return GestureDetector(
      onTap: () => onNavigate(screenName),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Color(AppConstants.bgCard),
          border: Border.all(color: Color(AppConstants.ink).withValues(alpha: 0.07)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(AppConstants.gold).withValues(alpha: 0.1),
              ),
              child: Icon(icon, color: Color(AppConstants.goldSoft), size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                letterSpacing: 0.5,
                color: Color(AppConstants.inkDim),
              ),
            ),
          ],
        ),
      ),
    );
  }
}