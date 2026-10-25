import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../models/branch_model.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  String _selectedSport = 'Kickboxing';
  String _selectedLevel = 'N - Beginner';
  String _selectedWeightClass = '63.5 kg';

  // Branch State
  String? _selectedBranchId;
  String? _selectedBranchName;
  List<String> _availableSports = ['Kickboxing', 'MMA', 'Boxing', 'Muay Thai', 'Jiu-Jitsu'];

  List<BranchModel> _branches = [];
  bool _isLoadingBranches = true;

  final List<String> _levels = ['N - Beginner', 'C - Intermediate', 'B - Advanced', 'A - Pro'];
  final List<String> _weightClasses = [
    '55.0 kg', '57.5 kg', '60.0 kg', '63.5 kg', '67.0 kg',
    '70.0 kg', '73.5 kg', '77.0 kg', '81.0 kg', '85.0 kg', '90.0 kg+'
  ];

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  // Branch'leri Firebase'den çekiyoruz (Login gerektirmez)
  Future<void> _fetchBranches() async {
    try {
      final snap = await FirebaseDatabase.instance.ref('branches').get();
      if (snap.exists && snap.value != null) {
        final map = snap.value as Map;
        final list = <BranchModel>[];
        map.forEach((key, value) {
          final data = Map<String, dynamic>.from(value as Map);
          if (data['isActive'] != false) {
            list.add(BranchModel.fromMap(key, data));
          }
        });

        setState(() {
          _branches = list;
          _isLoadingBranches = false;

          if (_branches.isNotEmpty && _selectedBranchId == null) {
            _selectedBranchId = _branches.first.id;
            _selectedBranchName = _branches.first.name;
            _availableSports = _branches.first.sports.isNotEmpty
                ? _branches.first.sports
                : ['Kickboxing', 'MMA', 'Boxing', 'Muay Thai', 'Jiu-Jitsu'];
            if (!_availableSports.contains(_selectedSport)) {
              _selectedSport = _availableSports.first;
            }
          }
        });
      } else {
        setState(() => _isLoadingBranches = false);
      }
    } catch (e) {
      setState(() => _isLoadingBranches = false);
    }
  }

  Future<int> _reserveNextPlayerNumber() async {
    final ref = FirebaseDatabase.instance.ref('counters/player_number');
    final result = await ref.runTransaction((current) {
      final val = (current as num?)?.toInt() ?? 9;
      return Transaction.success(val + 1);
    });
    final value = result.snapshot.value;
    return (value is num) ? value.toInt() : 10;
  }

  String _localizedSport(String sport, AppLocalizations l10n) {
    switch (sport) {
      case 'Kickboxing': return l10n.sportKickboxing;
      case 'MMA': return l10n.sportMma;
      case 'Boxing': return l10n.sportBoxing;
      case 'Muay Thai': return l10n.sportMuayThai;
      case 'Jiu-Jitsu': return l10n.sportJiuJitsu;
      default: return sport;
    }
  }

  String _localizedLevel(String level, AppLocalizations l10n) {
    switch (level) {
      case 'Beginner': return l10n.levelBeginner;
      case 'Intermediate': return l10n.levelIntermediate;
      case 'Advanced': return l10n.levelAdvanced;
      case 'Pro': return l10n.levelPro;
      default: return level;
    }
  }

  void _showBranchPicker(List<BranchModel> branches) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.15))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'SELECT BRANCH',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: branches.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final b = branches[index];
                        final isSelected = b.id == _selectedBranchId;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedBranchId = b.id;
                              _selectedBranchName = b.name;
                              _availableSports = b.sports.isNotEmpty
                                  ? b.sports
                                  : ['Kickboxing', 'MMA', 'Boxing', 'Muay Thai', 'Jiu-Jitsu'];
                              if (!_availableSports.contains(_selectedSport)) {
                                _selectedSport = _availableSports.first;
                              }
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE50914).withOpacity(0.15)
                                  : Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFE50914)
                                    : Colors.white.withOpacity(0.08),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: isSelected ? const Color(0xFFE50914) : Colors.white54,
                                  size: 18,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    b.name,
                                    style: GoogleFonts.inter(
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle, color: Color(0xFFE50914), size: 18),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBranchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a branch', style: GoogleFonts.inter()),
          backgroundColor: Colors.red.shade900,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final l10n = AppLocalizations.of(context);
    final phoneNum = _phoneController.text.trim();
    final email = '$phoneNum@lycans.app';

    try {
      int reservedNumber = 0;
      try {
        reservedNumber = await _reserveNextPlayerNumber();
      } catch (_) {}

      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      );

      final uid = credential.user!.uid;
      final now = DateTime.now();

      await FirebaseDatabase.instance.ref('pending_users/$uid').set({
        'uid': uid,
        'fullName': _fullNameController.text.trim(),
        'phone': phoneNum,
        'email': email,
        'sport': _selectedSport,
        'level': _selectedLevel,
        'weightClass': _selectedWeightClass,
        'emergencyContact': _emergencyContactController.text.trim(),
        'emergencyPhone': _emergencyPhoneController.text.trim(),
        'guardian': 'Not applicable',
        'playerNumber': reservedNumber,
        'branchId': _selectedBranchId,
        'branchName': _selectedBranchName,
        'status': 'pending',
        'requestedAt': now.toIso8601String(),
      });

      await FirebaseAuth.instance.signOut();

      if (mounted) {
        _showPendingSuccessDialog(l10n, reservedNumber, email);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String msg = e.message ?? 'Registration failed';
        if (e.code == 'email-already-in-use') msg = 'This phone number is already registered.';
        if (e.code == 'weak-password') msg = 'Password is too weak.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg, style: GoogleFonts.inter()), backgroundColor: Colors.red.shade900),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e', style: GoogleFonts.inter()), backgroundColor: Colors.red.shade900),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showPendingSuccessDialog(AppLocalizations l10n, int number, String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 30),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE50914).withOpacity(0.4), width: 0.8),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFE50914).withOpacity(0.2), blurRadius: 30, spreadRadius: 2),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE50914).withOpacity(0.12),
                        border: Border.all(color: const Color(0xFFE50914).withOpacity(0.4), width: 1),
                      ),
                      child: const Icon(Icons.hourglass_top_rounded, color: Color(0xFFE50914), size: 32),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'REGISTRATION SUBMITTED',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your account is pending admin approval.\nYou will be able to sign in once activated.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, height: 1.6),
                    ),
                    if (number > 0) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('YOUR NUMBER  ', style: GoogleFonts.montserrat(fontSize: 9, letterSpacing: 1.5, color: Colors.white54, fontWeight: FontWeight.w600)),
                            Text('#$number', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFFE50914))),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE50914),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          elevation: 0,
                        ),
                        child: Text('OK', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'kickboxing': return Icons.sports_martial_arts;
      case 'mma': return Icons.sports_kabaddi;
      case 'boxing': return Icons.sports_mma;
      case 'muay thai': return Icons.sports_martial_arts;
      case 'jiu-jitsu': return Icons.sports_martial_arts;
      default: return Icons.sports_martial_arts;
    }
  }

  IconData _getLevelIcon(String level) {
    switch (level.toLowerCase()) {
      case 'beginner': return Icons.person;
      case 'intermediate': return Icons.directions_run;
      case 'advanced': return Icons.fitness_center;
      case 'pro': return Icons.emoji_events;
      default: return Icons.person;
    }
  }

  void _showEmergencyBottomSheet(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      border: Border(top: BorderSide(color: Colors.white.withOpacity(0.15))),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 3,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(l10n.additionalInfo, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text('/', style: GoogleFonts.montserrat(color: const Color(0xFFE50914), fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Text(l10n.weightClassUpper, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedWeightClass,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF1A1A1A),
                              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 16),
                              items: _weightClasses.map((w) {
                                return DropdownMenuItem(
                                  value: w,
                                  child: Text(w, style: GoogleFonts.inter(color: Colors.white, fontSize: 11)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setModalState(() => _selectedWeightClass = val!);
                                setState(() => _selectedWeightClass = val!);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text('/', style: GoogleFonts.montserrat(color: const Color(0xFFE50914), fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Text(l10n.emergencyContactUpper, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildBottomSheetInput(l10n.contactName, Icons.person_outline, _emergencyContactController),
                        const SizedBox(height: 10),
                        _buildBottomSheetInput(l10n.contactPhone, Icons.phone_outlined, _emergencyPhoneController, keyboardType: TextInputType.phone),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE50914),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              elevation: 0,
                            ),
                            child: Text(l10n.saveAndClose, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomSheetInput(String hint, IconData icon, TextEditingController controller, {TextInputType? keyboardType}) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 11),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(top: 13, bottom: 13, right: 16),
          isDense: true,
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white54, size: 14),
                const SizedBox(width: 8),
                Container(width: 1, height: 14, color: Colors.white.withOpacity(0.15)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/register_bg.png'), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.85),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.createYour, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 11, letterSpacing: 2)),
                    Text(l10n.accountUpper, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    Text(l10n.joinThePack, style: GoogleFonts.inter(color: Colors.white60, fontSize: 10)),
                    const SizedBox(height: 4),
                    Container(height: 2, width: 35, color: const Color(0xFFE50914)),
                    const SizedBox(height: 24),

                    // === BRANCH SEÇİMİ ===
                    Row(
                      children: [
                        Text('/', style: GoogleFonts.montserrat(color: const Color(0xFFE50914), fontSize: 14, fontWeight: FontWeight.w900)),
                        const SizedBox(width: 8),
                        Text('BRANCH', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _isLoadingBranches ? null : () => _showBranchPicker(_branches),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on_outlined, color: Color(0xFFE50914), size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _isLoadingBranches
                                      ? const Center(
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE50914)),
                                    ),
                                  )
                                      : AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                      _selectedBranchName ?? 'Select a branch',
                                      key: ValueKey(_selectedBranchName),
                                      style: GoogleFonts.inter(
                                        color: _selectedBranchName != null ? Colors.white : Colors.white54,
                                        fontSize: 12,
                                        fontWeight: _selectedBranchName != null ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // === DİNAMİK SPORLAR ===
                    Row(
                      children: [
                        Text('/', style: GoogleFonts.montserrat(color: const Color(0xFFE50914), fontSize: 14, fontWeight: FontWeight.w900)),
                        const SizedBox(width: 8),
                        Text(l10n.disciplineUpper, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        children: _availableSports.map((sport) => _buildSportChip(sport, l10n)).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE50914))),
                        const SizedBox(width: 4),
                        Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2))),
                        const SizedBox(width: 4),
                        Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2))),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // === LEVEL ===
                    Row(
                      children: [
                        Text('/', style: GoogleFonts.montserrat(color: const Color(0xFFE50914), fontSize: 14, fontWeight: FontWeight.w900)),
                        const SizedBox(width: 8),
                        Text(l10n.levelUpper, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _levels.map((level) {
                        return SizedBox(
                          width: (MediaQuery.of(context).size.width - 48 - 8) / 2,
                          child: _buildLevelChip(level, l10n),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // === INPUTLAR ===
                    Row(
                      children: [
                        Expanded(child: _buildInput(l10n.fullName, Icons.person_outline, _fullNameController)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildInput(l10n.phoneNumberField, Icons.phone_outlined, _phoneController, keyboardType: TextInputType.phone)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInput(l10n.passwordField, Icons.lock_outline, _passwordController, obscureText: _obscurePassword, isPassword: true),
                    const SizedBox(height: 20),

                    // === EMERGENCY CONTACT ===
                    GestureDetector(
                      onTap: () => _showEmergencyBottomSheet(l10n),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE50914).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFE50914).withOpacity(0.3)),
                                  ),
                                  child: const Icon(Icons.medical_services_outlined, color: Color(0xFFE50914), size: 16),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.emergencyContactUpper, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                      const SizedBox(height: 2),
                                      Text(l10n.addTrustedContact, style: GoogleFonts.inter(color: Colors.white54, fontSize: 9)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // === SUBMIT BUTTON ===
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          shadowColor: Colors.transparent,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF990000), Color(0xFFE50914), Color(0xFF990000)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFFE50914).withOpacity(0.4), blurRadius: 15, spreadRadius: 1, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: _isSubmitting
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.person_add_alt_1, color: Colors.white, size: 16),
                                const SizedBox(width: 12),
                                Container(width: 1, height: 16, color: Colors.white.withOpacity(0.3)),
                                const SizedBox(width: 12),
                                Text(l10n.createAccount, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.alreadyHaveAccount, style: GoogleFonts.inter(fontSize: 10, color: Colors.white54)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(l10n.loginLink, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFE50914))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // === BLUR'LU VE SMOOTH CHIP'LER ===
  Widget _buildSportChip(String sport, AppLocalizations l10n) {
    bool isSelected = _selectedSport == sport;
    return GestureDetector(
      onTap: () => setState(() => _selectedSport = sport),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE50914).withOpacity(0.15) : Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFFE50914) : Colors.white.withOpacity(0.08), width: isSelected ? 1.5 : 1),
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFFE50914).withOpacity(0.2), blurRadius: 8)] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getSportIcon(sport), color: isSelected ? const Color(0xFFE50914) : Colors.white54, size: 14),
            const SizedBox(width: 6),
            Text(_localizedSport(sport, l10n), style: GoogleFonts.inter(color: isSelected ? Colors.white : Colors.white54, fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelChip(String level, AppLocalizations l10n) {
    bool isSelected = _selectedLevel == level;
    return GestureDetector(
      onTap: () => setState(() => _selectedLevel = level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE50914).withOpacity(0.15) : Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFFE50914) : Colors.white.withOpacity(0.08), width: isSelected ? 1.5 : 1),
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFFE50914).withOpacity(0.2), blurRadius: 8)] : [],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getLevelIcon(level), color: isSelected ? const Color(0xFFE50914) : Colors.white54, size: 14),
            const SizedBox(width: 6),
            Text(_localizedLevel(level, l10n), style: GoogleFonts.inter(color: isSelected ? Colors.white : Colors.white54, fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  // === BLUR'LU INPUTLAR ===
  Widget _buildInput(String hint, IconData icon, TextEditingController controller, {bool obscureText = false, bool isPassword = false, TextInputType? keyboardType}) {
    final l10n = AppLocalizations.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword ? _obscurePassword : obscureText,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 10),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 13, bottom: 13, right: 16),
              isDense: true,
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white54, size: 14),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 14, color: Colors.white.withOpacity(0.15)),
                  ],
                ),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white38, size: 14),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              )
                  : null,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return l10n.required;
              return null;
            },
          ),
        ),
      ),
    );
  }
}