import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.resetPassword(_emailController.text.trim());

      if (mounted) {
        if (appProvider.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appProvider.error!),
              backgroundColor: Color(AppConstants.ember),
            ),
          );
          appProvider.clearError();
        } else {
          setState(() => _emailSent = true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(AppConstants.ink)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.lock_reset,
                  size: 48,
                  color: Color(AppConstants.goldSoft),
                ),
                const SizedBox(height: 16),
                Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontFamily: 'Oswald',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(AppConstants.ink),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(AppConstants.inkDim),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                if (_emailSent) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Color(AppConstants.green).withValues(alpha: 0.1),
                      border: Border.all(color: Color(AppConstants.green).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Color(AppConstants.green), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Password reset link sent to ${_emailController.text}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(AppConstants.green),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                Text(
                  'EMAIL',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: Color(AppConstants.inkFaint),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: Color(AppConstants.ink), fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'your@email.com',
                    hintStyle: TextStyle(color: Color(AppConstants.inkFaint)),
                    filled: true,
                    fillColor: Color(AppConstants.bgCard),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(AppConstants.gold).withValues(alpha: 0.16)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(AppConstants.gold).withValues(alpha: 0.16)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(AppConstants.gold)),
                    ),
                    prefixIcon: Icon(Icons.email_outlined, color: Color(AppConstants.goldSoft), size: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email is required';
                    if (!value.contains('@')) return 'Enter valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: appProvider.isLoading ? null : _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppConstants.gold),
                      foregroundColor: Color(0xFF1A1305),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: appProvider.isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF1A1305),
                      ),
                    )
                        : Text(
                      'SEND RESET LINK',
                      style: TextStyle(
                        fontFamily: 'Oswald',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}