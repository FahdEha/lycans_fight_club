import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final l10n = AppLocalizations.of(context);
    final userData = appProvider.userData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.accountLabel,
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10.5,
              letterSpacing: 1.5,
              color: Color(AppConstants.goldSoft),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.profileTitle,
            style: TextStyle(
              fontFamily: 'Oswald',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(AppConstants.ink),
            ),
          ),
          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Color(AppConstants.gold).withValues(alpha: 0.22),
                  Color(AppConstants.bgCard),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                  color: Color(AppConstants.gold).withValues(alpha: 0.16)),
            ),
            child: Column(
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(AppConstants.bgCard),
                    border: Border.all(color: Color(AppConstants.gold), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Color(AppConstants.gold).withValues(alpha: 0.25),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      userData?.initials ?? '??',
                      style: TextStyle(
                        fontFamily: 'Oswald',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(AppConstants.goldSoft),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userData?.fullName ?? l10n.loading,
                  style: TextStyle(
                    fontFamily: 'Oswald',
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Color(AppConstants.ink),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.memberSince(
                    DateFormat('MMM yyyy')
                        .format(userData?.joinDate ?? DateTime.now()),
                  ),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(AppConstants.inkDim),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          _buildField(l10n.fullNameField, userData?.fullName ?? ''),
          _buildField(l10n.phoneField, userData?.phone ?? ''),
          _buildField(l10n.emailField, userData?.email ?? ''),
          _buildField(
            l10n.sportLevelField,
            '${userData?.sport ?? ''} — ${userData?.level ?? ''}',
          ),
          _buildField(l10n.weightClassField, userData?.weightClass ?? ''),
          _buildField(
            l10n.emergencyContactField,
            '${userData?.emergencyContact ?? ''} — ${userData?.emergencyPhone ?? ''}',
          ),
          _buildField(
            l10n.guardianField,
            userData?.guardian ?? l10n.notApplicable,
          ),

          const SizedBox(height: 14),

          OutlinedButton(
            onPressed: () {
              _showEditProfileDialog(context, appProvider, userData, l10n);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Color(AppConstants.ink),
              side: BorderSide(
                  color: Color(AppConstants.gold).withValues(alpha: 0.16)),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Color(AppConstants.bgCard2),
            ),
            child: Text(
              l10n.editProfileUpper,
              style: const TextStyle(
                fontFamily: 'Oswald',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () async {
              await appProvider.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppConstants.ember).withValues(alpha: 0.12),
              foregroundColor: Color(AppConstants.emberGlow),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                    color: Color(AppConstants.ember).withValues(alpha: 0.4)),
              ),
            ),
            child: Text(
              l10n.logOutUpper,
              style: const TextStyle(
                fontFamily: 'Oswald',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              letterSpacing: 1,
              color: Color(AppConstants.inkFaint),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: Color(AppConstants.bgCard),
              border: Border.all(
                  color: Color(AppConstants.ink).withValues(alpha: 0.07)),
            ),
            child: Text(
              value,
              style: TextStyle(fontSize: 13.5, color: Color(AppConstants.ink)),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(
      BuildContext context,
      AppProvider appProvider,
      dynamic userData,
      AppLocalizations l10n,
      ) {
    final nameController = TextEditingController(text: userData?.fullName ?? '');
    final phoneController = TextEditingController(text: userData?.phone ?? '');
    final emergencyContactController =
    TextEditingController(text: userData?.emergencyContact ?? '');
    final emergencyPhoneController =
    TextEditingController(text: userData?.emergencyPhone ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Color(AppConstants.bgCard),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: Color(AppConstants.gold).withValues(alpha: 0.16)),
          ),
          title: Text(
            l10n.editProfileTitle,
            style: TextStyle(
              fontFamily: 'Oswald',
              fontSize: 18,
              color: Color(AppConstants.ink),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(nameController, l10n.fullNameField, l10n),
                const SizedBox(height: 12),
                _dialogField(phoneController, l10n.phoneField, l10n),
                const SizedBox(height: 12),
                _dialogField(
                    emergencyContactController, l10n.emergencyContactField, l10n),
                const SizedBox(height: 12),
                _dialogField(
                    emergencyPhoneController, l10n.emergencyPhoneField, l10n),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                l10n.cancel,
                style: TextStyle(color: Color(AppConstants.inkDim)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await appProvider.updateUserData({
                  'fullName': nameController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'emergencyContact': emergencyContactController.text.trim(),
                  'emergencyPhone': emergencyPhoneController.text.trim(),
                });
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.profileUpdated),
                      backgroundColor: Color(AppConstants.green),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppConstants.gold),
                foregroundColor: const Color(0xFF1A1305),
              ),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogField(
      TextEditingController controller,
      String label,
      AppLocalizations l10n,
      ) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Color(AppConstants.ink), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(AppConstants.inkFaint)),
        filled: true,
        fillColor: Color(AppConstants.bgCard2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide:
          BorderSide(color: Color(AppConstants.gold).withValues(alpha: 0.16)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide:
          BorderSide(color: Color(AppConstants.gold).withValues(alpha: 0.16)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: Color(AppConstants.gold)),
        ),
      ),
    );
  }
}