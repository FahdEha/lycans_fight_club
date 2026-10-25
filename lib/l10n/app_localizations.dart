import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  bool get isAr => locale.languageCode == 'ar';

  String _t(String en, String ar) => isAr ? ar : en;

  // ===== NAV =====
  String get navHome => _t('Home', 'الرئيسية');
  String get navSchedule => _t('Schedule', 'الجدول');
  String get navBranches => _t('Branches', 'الفروع');
  String get navProfile => _t('Profile', 'الملف الشخصي');

  // ===== COMMON =====
  String get cancel => _t('Cancel', 'إلغاء');
  String get confirm => _t('Confirm', 'تأكيد');
  String get save => _t('Save', 'حفظ');
  String get close => _t('Close', 'إغلاق');
  String get required => _t('Required', 'مطلوب');
  String get loading => _t('Loading...', 'جاري التحميل...');
  String get error => _t('Error', 'خطأ');
  String get ok => _t('OK', 'موافق');

  // ===== LOGIN =====
  String get phoneNumber => _t('Phone Number', 'رقم الهاتف');
  String get phoneRequired => _t('Phone number is required', 'رقم الهاتف مطلوب');
  String get password => _t('Password', 'كلمة المرور');
  String get passwordRequired => _t('Password is required', 'كلمة المرور مطلوبة');
  String get passwordMin6 => _t('Minimum 6 characters', '6 أحرف على الأقل');
  String get rememberMe => _t('Remember me', 'تذكرني');
  String get forgotPassword => _t('Forgot password?', 'نسيت كلمة المرور؟');
  String get loginUpper => _t('LOGIN', 'تسجيل الدخول');
  String get dontHaveAccount => _t("Don't have an account? ", 'ليس لديك حساب؟ ');
  String get registerLink => _t('Register', 'إنشاء حساب');

  // ===== REGISTER =====
  String get createYour => _t('CREATE YOUR', 'أنشئ');
  String get accountUpper => _t('ACCOUNT', 'حسابك');
  String get joinThePack => _t('Join the pack. Become stronger.', 'انضم إلى الفريق. كن أقوى.');
  String get disciplineUpper => _t('DISCIPLINE', 'التخصص');
  String get levelUpper => _t('LEVEL', 'المستوى');
  String get fullName => _t('Full Name', 'الاسم الكامل');
  String get phoneNumberField => _t('Phone Number', 'رقم الهاتف');
  String get passwordField => _t('Password', 'كلمة المرور');
  String get additionalInfo => _t('ADDITIONAL INFO', 'معلومات إضافية');
  String get weightClassUpper => _t('WEIGHT CLASS', 'فئة الوزن');
  String get emergencyContactUpper => _t('EMERGENCY CONTACT', 'جهة اتصال الطوارئ');
  String get contactName => _t('Contact Name', 'اسم جهة الاتصال');
  String get contactPhone => _t('Contact Phone', 'هاتف جهة الاتصال');
  String get saveAndClose => _t('SAVE & CLOSE', 'حفظ وإغلاق');
  String get addTrustedContact => _t('Add a trusted contact', 'أضف جهة اتصال موثوقة');
  String get createAccount => _t('CREATE ACCOUNT', 'إنشاء الحساب');
  String get alreadyHaveAccount => _t('Already have an account? ', 'لديك حساب بالفعل؟ ');
  String get loginLink => _t('Login', 'تسجيل الدخول');
  String get registrationSuccess =>
      _t('Registration successful! Welcome to the pack.', 'تم التسجيل بنجاح! مرحبًا بك في الفريق.');

  String get sportKickboxing => _t('Kickboxing', 'الكيك بوكسينغ');
  String get sportMma => _t('MMA', 'MMA');
  String get sportBoxing => _t('Boxing', 'الملاكمة');
  String get sportMuayThai => _t('Muay Thai', 'المواي تاي');
  String get sportJiuJitsu => _t('Jiu-Jitsu', 'الجيو جيتسو');

  String get levelBeginner => _t('Beginner', 'مبتدئ');
  String get levelIntermediate => _t('Intermediate', 'متوسط');
  String get levelAdvanced => _t('Advanced', 'متقدم');
  String get levelPro => _t('Pro', 'محترف');

  // ===== HOME =====
  String get rank01 => _t('RANK 01', 'الترتيب 01');
  String get kickboxingMma => _t('Kickboxing  •  MMA', 'كيك بوكسينغ  •  MMA');
  String get daysLeftUpper => _t('DAYS LEFT', 'الأيام المتبقية');
  String get attendanceUpper => _t('ATTENDANCE', 'الحضور');
  String get recordUpper => _t('RECORD', 'السجل');
  String get membershipCard => _t('Membership', 'العضوية');
  String get yourJourneyStartsHere =>
      _t('YOUR JOURNEY\nSTARTS HERE.', 'رحلتك\nتبدأ هنا.');
  String get scheduleCard => _t('Schedule', 'الجدول');
  String get planYourTrainingSessions =>
      _t('PLAN YOUR\nTRAINING SESSIONS.', 'خطط\nلجلساتك التدريبية.');
  String get progressCard => _t('Progress', 'التقدم');
  String get trackYourImprovement =>
      _t('TRACK YOUR\nIMPROVEMENT.', 'تابع\nتطورك.');
  String get fightsCard => _t('Fights', 'المبارزات');
  String get stepIntoTheCage => _t('STEP INTO\nTHE CAGE.', 'ادخل\nإلى القفص.');
  String get coachsNote => _t("Coach's Note", 'ملاحظة المدرب');
  String get coachNoteText => _t(
    'Keep your guard tighter on the counter — footwork drills paid off this week. Ready to move up a weight bracket for Cairo Open.',
    'حافظ على حمايتك بإحكام أكبر في الهجمات المرتدة — تدريبات حركة القدم أثمرت هذا الأسبوع. جاهز للانتقال إلى فئة وزن أعلى في بطولة القاهرة المفتوحة.',
  );
  String get fearlessFighters => _t('FEARLESS  FIGHTERS', 'مقاتلون بلا خوف');

  // ===== SCHEDULE =====
  String get fearlessFightersSpaced =>
      _t('F E A R L E S S   F I G H T E R S', 'م ق ا ت ل و ن   ب ل ا   خ و ف');
  String get trainingUpper => _t('TRAINING', 'التدريب');
  String get scheduleTitle => _t('SCHEDULE', 'الجدول');
  String get scheduleSubtitle => _t(
    'Pick your session for the week, lock in your spot, get\nring ready.',
    'اختر جلستك لهذا الأسبوع، احجز مكانك،\nواستعد للحلبة.',
  );
  String get sessionsFor => _t('SESSIONS FOR', 'جلسات يوم');
  String get restDay => _t('REST DAY', 'يوم راحة');
  String get restDayDesc => _t(
    "Your body is recovering. Pick another day when you're ready to lock in a session.",
    'جسمك في مرحلة التعافي. اختر يومًا آخر عندما تكون مستعدًا لحجز جلسة.',
  );
  String get amLabel => _t('AM', 'ص');
  String get pmLabel => _t('PM', 'م');
  String minSuffix(int m) => isAr ? '$m دقيقة' : '$m min';
  String get bookASession => _t('BOOK A SESSION', 'احجز جلسة');
  String get availableClasses => _t('AVAILABLE CLASSES', 'الفصول المتاحة');
  String get noOpenClasses => _t('No open classes', 'لا توجد فصول مفتوحة');
  String get chooseClass => _t('Choose the class you want to join', 'اختر الفصل الذي تريد الانضمام إليه');
  String get noClassesAvailable =>
      _t('No classes available at the moment.', 'لا توجد فصول متاحة حاليًا.');
  String spotLockedIn(String name) => isAr
      ? 'تم تأمين مكانك في $name'
      : 'Your spot is locked in for $name';

  // ===== MEMBERSHIP =====
  String get membershipTitle => _t('MEMBERSHIP', 'العضوية');
  String get yourSubscription => _t('YOUR\nSUBSCRIPTION', 'اشتراكك');
  String get subscriptionSubtitle => _t(
    'Manage your active plan and\nexplore exclusive packages.',
    'أدر خطتك النشطة\nواستكشف الباقات الحصرية.',
  );
  String get currentPlanUpper => _t('CURRENT PLAN', 'الخطة الحالية');
  String get noActivePlan => _t('NO ACTIVE PLAN', 'لا توجد خطة نشطة');
  String get daysLeftCap => _t('DAYS LEFT', 'الأيام المتبقية');
  String get sessionsCap => _t('SESSIONS', 'الجلسات');
  String get renewsCap => _t('RENEWS', 'التجديد');
  String get durationCap => _t('DURATION', 'المدة');
  String sessionsLeft(int n) => isAr ? '$n متبقية' : '$n Left';
  String get noneLabel => _t('None', 'لا شيء');
  String daysSuffix(int n) => isAr ? '$n يوم' : '$n Days';
  String get activeStatus => _t('ACTIVE', 'نشط');
  String get expiredStatus => _t('EXPIRED', 'منتهي');
  String get changePlan => _t('CHANGE PLAN', 'تغيير الخطة');
  String get renewNow => _t('RENEW NOW', 'جدد الآن');
  String get renewSubscription => _t('Renew Subscription', 'تجديد الاشتراك');
  String renewPlanConfirm(int d) => isAr
      ? 'تجديد الخطة الحالية لمدة $d يوم؟'
      : 'Renew current plan for $d days?';
  String get planRenewed => _t('Plan renewed!', 'تم تجديد الخطة!');
  String get paymentHistory => _t('PAYMENT HISTORY', 'سجل المدفوعات');
  String receiptsCount(int n) => isAr ? '$n إيصال' : '$n RECEIPTS';
  String get noReceiptsYet => _t('No receipts yet.', 'لا توجد إيصالات بعد.');
  String get packagesUpper => _t('PACKAGES', 'الباقات');
  String get chooseYourPlan => _t('CHOOSE YOUR PLAN', 'اختر خطتك');
  String get upgradePlan => _t('UPGRADE PLAN', 'ترقية الخطة');
  String get unlockMoreFeatures => _t('Unlock more features', 'افتح المزيد من الميزات');
  String get downgradePlan => _t('DOWNGRADE PLAN', 'خفض الخطة');
  String get switchToLighterPlan => _t('Switch to lighter plan', 'التبديل إلى خطة أخف');
  String downgradeInfo(String date) => isAr
      ? 'سيتم تطبيق التخفيض بعد انتهاء خطتك الحالية في $date.'
      : 'Downgrading will take effect after your current plan ends on $date.';
  String get yourCurrentPlan => _t('YOUR CURRENT PLAN', 'خطتك الحالية');
  String sessionsPerMonth(int n) => isAr ? '$n جلسة / شهر' : '$n SESSIONS / MO';
  String get bestValue => _t('BEST VALUE', 'أفضل قيمة');
  String get upgradeLabel => _t('UPGRADE', 'ترقية');
  String get downgradeLabel => _t('DOWNGRADE', 'خفض');
  String get pendingLabel => _t('PENDING', 'قيد الانتظار');
  String get confirmPlan => _t('Confirm Plan', 'تأكيد الخطة');
  String switchToPlanConfirm(String name, String price) => isAr
      ? 'التبديل إلى $name مقابل $price جنيه؟'
      : 'Switch to $name for $price EGP?';
  String get requestSent => _t('Request sent to admin for approval', 'تم إرسال الطلب إلى المشرف للموافقة');
  String daysLeftShort(int n) => isAr ? '$n يوم' : '$n D';

  // ===== COMPETITION =====
  String get lycansFightClub => _t('LYCANS FIGHT CLUB', 'نادي ليكانز للقتال');
  String get everyFight => _t('Every Fight', 'كل مبارزة');
  String get tellsAStory => _t('Tells a Story', 'تروي قصة');
  String get trainFightImprove => _t('TRAIN  /  FIGHT  /  IMPROVE', 'تدرّب / قاتل / تطوّر');
  String get overallRecord => _t('OVERALL RECORD', 'السجل الإجمالي');
  String get winsLabel => _t('Wins', 'فوز');
  String get lossesLabel => _t('Losses', 'خسارة');
  String get drawsLabel => _t('Draws', 'تعادل');
  String get winsByKo => _t('Wins by KO', 'فوز بالضربة القاضية');
  String get winsByDecision => _t('Wins by Decision', 'فوز بالقرار');
  String get latestFight => _t('LATEST FIGHT', 'أحدث مبارزة');
  String roundWithDate(int round, String date) =>
      isAr ? 'الجولة $round  •  $date' : 'Round $round  •  $date';
  String get winLabel => _t('WIN', 'فوز');
  String get lossLabel => _t('LOSS', 'خسارة');
  String get noFightsRecorded => _t('No fights recorded yet', 'لم يتم تسجيل أي مبارزات بعد');
  String get disciplineTodayFreedomTomorrow =>
      _t('Discipline today,\nfreedom tomorrow.', 'الانضباط اليوم،\nالحرية غدًا.');

  // ===== PROGRESS =====
  String get keepGoing => _t('Keep Going', 'استمر');
  String get warrior => _t('Warrior', 'محارب');
  String get weightLabel => _t('Weight', 'الوزن');
  String get heightLabel => _t('Height', 'الطول');
  String get speedLabel => _t('Speed', 'السرعة');
  String get powerLabel => _t('Power', 'القوة');
  String get kgUnit => _t('kg', 'كجم');
  String get cmUnit => _t('cm', 'سم');
  String get outOf10 => _t('/ 10', '/ 10');
  String get strongerEveryDay => _t('Stronger\nEvery Day', 'أقوى\nكل يوم');
  String get progressBuiltInSmallSteps =>
      _t('Progress is built\nin the small steps.', 'التقدم يُبنى\nبالخطوات الصغيرة.');
  String get attendanceBtn => _t('Attendance', 'الحضور');
  String get last4Weeks => _t('Last 4 Weeks', 'آخر 4 أسابيع');
  String get progressBtn => _t('Progress', 'التقدم');
  String get viewYourResults => _t('View your results', 'اعرض نتائجك');
  String get attendanceTitleUpper => _t('ATTENDANCE', 'الحضور');
  String get unlimitedPlan => _t('Unlimited Plan', 'خطة غير محدودة');
  String targetPerWeek(int n) => isAr ? 'الهدف: $n / أسبوع' : 'Target: $n / week';
  String get thisWeek => _t('This Week', 'هذا الأسبوع');
  String get lastWeek => _t('Last Week', 'الأسبوع الماضي');
  String get twoWeeksAgo => _t('2 Weeks Ago', 'منذ أسبوعين');
  String get threeWeeksAgo => _t('3 Weeks Ago', 'منذ 3 أسابيع');
  String sessionsCount(int n) => isAr ? '$n جلسة' : '$n sessions';
  String countOverTarget(int a, int t) => '$a / $t';
  String get goalMet => _t('GOAL MET', 'تحقق الهدف');

  // ===== QR CHECKIN =====
  String get checkInUpper => _t('CHECK-IN', 'تسجيل الحضور');
  String get scanQrDesc => _t(
    "Scan your QR code at reception\nto log today's session.",
    'امسح رمز QR الخاص بك في الاستقبال\nلتسجيل جلسة اليوم.',
  );
  String get scanQrCode => _t('SCAN QR CODE', 'امسح رمز QR');
  String get readyToCheckin => _t('READY TO CHECK-IN', 'جاهز لتسجيل الحضور');
  String get codeRefreshes => _t('Code refreshes in 60 seconds', 'يتحدث الرمز خلال 60 ثانية');
  String get membershipUpper => _t('MEMBERSHIP', 'العضوية');
  String get activeUpper => _t('ACTIVE', 'نشط');
  String get inactiveUpper => _t('INACTIVE', 'غير نشط');
  String get unlimitedSessions => _t('Unlimited Sessions', 'جلسات غير محدودة');
  String sessionsRemaining(int n) => isAr ? '$n جلسة متبقية' : '$n Sessions Remaining';
  String get trainAction => _t('TRAIN', 'تدرب');
  String get buildYourSkills => _t('Build Your Skills', 'طوّر مهاراتك');
  String get scheduleAction => _t('SCHEDULE', 'الجدول');
  String get viewYourPlan => _t('View Your Plan', 'اعرض خطتك');
  String get quickActions => _t('QUICK ACTIONS', 'إجراءات سريعة');
  String get moreOptions => _t('More Options', 'خيارات إضافية');
  String get disciplineBuilds => _t('DISCIPLINE BUILDS', 'الانضباط يبني');
  String get freedom => _t('FREEDOM', 'الحرية');

  // ===== BRANCH DETAILS =====
  String get branchUpper => _t('BRANCH', 'الفرع');
  String get sameSpirit => _t('SAME SPIRIT.', 'نفس الروح.');
  String get differentGround => _t('DIFFERENT GROUND.', 'أرض مختلفة.');
  String branchSuffix(String name) => isAr ? 'فرع $name' : '$name Branch';
  String yourTrainingGround(String name) => isAr
      ? 'ساحة تدريبك في $name.'
      : 'Your training ground in $name.';
  String get openStatus => _t('OPEN', 'مفتوح');
  String get closedStatus => _t('CLOSED', 'مغلق');
  String get addressLabel => _t('Address', 'العنوان');
  String get addressNotSet => _t('Address not set', 'لم يتم تعيين العنوان');
  String get phoneLabel => _t('Phone', 'الهاتف');
  String get notAvailable => _t('Not available', 'غير متاح');
  String get callNow => _t('Call Now', 'اتصل الآن');
  String get getDirections => _t('Get Directions', 'احصل على الاتجاهات');
  String get findEasiestWay => _t('Find the easiest way to reach our branch.', 'اعثر على أسهل طريق للوصول إلى فرعنا.');
  String get openMaps => _t('Open Maps', 'افتح الخرائط');
  String get noLocation => _t('No Location', 'لا يوجد موقع');
  String get noSessionsThisDay => _t('No sessions this day', 'لا توجد جلسات في هذا اليوم');
  String get openSession => _t('Open', 'مفتوح');
  String get trainingSchedule => _t('Training Schedule', 'جدول التدريب');
  String get viewFullSchedule => _t('View Full Schedule', 'عرض الجدول الكامل');
  String get joinThisBranch => _t('Join This Branch', 'انضم إلى هذا الفرع');
  String get locationNotAvailable => _t('Location not available for this branch', 'الموقع غير متاح لهذا الفرع');
  String get couldNotOpenMaps => _t('Could not open maps app', 'تعذر فتح تطبيق الخرائط');

  // Days short
  String get monShort => _t('Mon', 'الإث');
  String get tueShort => _t('Tue', 'الث');
  String get wedShort => _t('Wed', 'الأر');
  String get thuShort => _t('Thu', 'الخ');
  String get friShort => _t('Fri', 'الج');
  String get satShort => _t('Sat', 'الس');
  String get sunShort => _t('Sun', 'الأح');

  // ===== TRAINING =====
  String get ourUpper => _t('OUR', 'فروعنا');
  String get branchesTitle => _t('BRANCHES', 'الفروع');
  String get differentPlaces => _t('DIFFERENT PLACES', 'أماكن مختلفة');
  String get sameSpiritUpper => _t('SAME SPIRIT', 'نفس الروح');
  String get searchBranch => _t('Search branch...', 'ابحث عن فرع...');
  String get mainBranch => _t('MAIN BRANCH', 'الفرع الرئيسي');
  String get branchLabel => _t('BRANCH', 'فرع');
  String get viewDetails => _t('View Details', 'عرض التفاصيل');
  String get noBranchesAvailable => _t('No branches available', 'لا توجد فروع متاحة');
  String get checkBackSoon => _t('Check back soon for more locations', 'تفقدنا قريبًا لمزيد من المواقع');

  // ===== NOTIFICATIONS =====
  String get notificationsTitle => _t('Notifications', 'الإشعارات');
  String get markAllRead => _t('Mark all read', 'تحديد الكل كمقروء');
  String get justNow => _t('Just now', 'الآن');
  String minAgo(int n) => isAr ? 'منذ $n دقيقة' : '$n min ago';
  String hoursAgo(int n) => isAr ? 'منذ $n ساعة' : '$n hours ago';
  String daysAgo(int n) => isAr ? 'منذ $n يوم' : '$n days ago';

  // ===== PAYMENTS =====
  String get paymentsTitle => _t('Payments', 'المدفوعات');
  String get outstandingBalance => _t('Outstanding Balance', 'الرصيد المستحق');
  String get fullyPaid => _t('Fully Paid', 'مدفوع بالكامل');
  String get invoicesTitle => _t('Invoices', 'الفواتير');
  String get downloadAllReceipts => _t('DOWNLOAD ALL RECEIPTS', 'تحميل جميع الإيصالات');

  // ===== PROFILE =====
  String get accountLabel => _t('ACCOUNT', 'الحساب');
  String get profileTitle => _t('Profile', 'الملف الشخصي');
  String memberSince(String date) => isAr ? 'عضو منذ $date' : 'Member since $date';
  String get fullNameField => _t('Full Name', 'الاسم الكامل');
  String get phoneField => _t('Phone', 'الهاتف');
  String get emailField => _t('Email', 'البريد الإلكتروني');
  String get sportLevelField => _t('Sport / Level', 'الرياضة / المستوى');
  String get weightClassField => _t('Weight Class', 'فئة الوزن');
  String get emergencyContactField => _t('Emergency Contact', 'جهة اتصال الطوارئ');
  String get guardianField => _t('Guardian (if minor)', 'ولي الأمر (إذا كان قاصرًا)');
  String get notApplicable => _t('Not applicable', 'لا ينطبق');
  String get editProfileUpper => _t('EDIT PROFILE', 'تعديل الملف الشخصي');
  String get logOutUpper => _t('LOG OUT', 'تسجيل الخروج');
  String get editProfileTitle => _t('Edit Profile', 'تعديل الملف الشخصي');
  String get emergencyPhoneField => _t('Emergency Phone', 'هاتف الطوارئ');
  String get profileUpdated => _t('Profile updated successfully', 'تم تحديث الملف الشخصي بنجاح');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}