import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../providers/locale_provider.dart';
import '../../utils/constants.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  final Color generalGlassDark = const Color(0xFF0F1115).withValues(alpha: 0.5);
  final Color glassBorder = Colors.white.withValues(alpha: 0.04);
  final Color accentRed = const Color(0xFFD61C1F);
  final Color textGrey = const Color(0xFF8C8C8C);

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.login(
        _phoneController.text.trim(),
        _passwordController.text,
      );

      if (mounted && appProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appProvider.error!,
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: accentRed,
          ),
        );
        appProvider.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final l10n = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/signin_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: size.height * 0.51),

                      // Phone Field
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                            cursorColor: accentRed,
                            decoration: InputDecoration(
                              hintText: l10n.phoneNumber,
                              hintStyle: GoogleFonts.inter(color: textGrey, fontSize: 14),
                              filled: true,
                              fillColor: generalGlassDark,
                              contentPadding: const EdgeInsets.symmetric(vertical: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: glassBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: glassBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: accentRed.withValues(alpha: 0.5)),
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(Icons.phone_outlined, color: Colors.white, size: 22),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.phoneRequired;
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                            cursorColor: accentRed,
                            decoration: InputDecoration(
                              hintText: l10n.password,
                              hintStyle: GoogleFonts.inter(color: textGrey, fontSize: 14),
                              filled: true,
                              fillColor: generalGlassDark,
                              contentPadding: const EdgeInsets.symmetric(vertical: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: glassBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: glassBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: accentRed.withValues(alpha: 0.5)),
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(Icons.lock_outline, color: Colors.white, size: 22),
                              ),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: textGrey,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.passwordRequired;
                              }
                              if (value.length < 6) {
                                return l10n.passwordMin6;
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Remember me
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Theme(
                                data: Theme.of(context).copyWith(
                                  unselectedWidgetColor: textGrey,
                                ),
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                    shape: const CircleBorder(),
                                    activeColor: Colors.transparent,
                                    checkColor: accentRed,
                                    side: BorderSide(
                                      color: _rememberMe ? accentRed : textGrey,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.rememberMe,
                                style: GoogleFonts.inter(fontSize: 13, color: textGrey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Login Button
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: const Color(0xFF0F1115),
                          border: Border.all(
                            color: accentRed.withValues(alpha: 0.5),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentRed.withValues(alpha: 0.35),
                              blurRadius: 25,
                              offset: const Offset(0, 0),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: appProvider.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: appProvider.isLoading
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.loginUpper,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.arrow_forward,
                                  color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.dontHaveAccount,
                            style: GoogleFonts.inter(fontSize: 13, color: textGrey),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const RegisterScreen()),
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  l10n.registerLink,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: accentRed,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_forward,
                                    color: accentRed, size: 14),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // ===== LANGUAGE SWITCHER (EN / AR) =====
              Positioned(
                top: 8,
                right: 0,
                left: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: generalGlassDark,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: glassBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildLangBtn(
                                'EN',
                                const Locale('en'),
                                localeProvider,
                                accentRed,
                                textGrey,
                              ),
                              const SizedBox(width: 4),
                              _buildLangBtn(
                                'AR',
                                const Locale('ar'),
                                localeProvider,
                                accentRed,
                                textGrey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangBtn(
      String label,
      Locale locale,
      LocaleProvider provider,
      Color accent,
      Color inactive,
      ) {
    final isActive = provider.locale.languageCode == locale.languageCode;
    return GestureDetector(
      onTap: () => provider.setLocale(locale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isActive ? accent.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: isActive ? accent.withValues(alpha: 0.6) : Colors.transparent,
            width: 1,
          ),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: accent.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 0.5,
            ),
          ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: isActive ? Colors.white : inactive,
          ),
        ),
      ),
    );
  }
}