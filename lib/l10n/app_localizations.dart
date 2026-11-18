import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'هايدرا مايند'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In ar, this message translates to:
  /// **'ترطيب ذكي لحياة أكثر صحة'**
  String get tagline;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @history.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get history;

  /// No description provided for @coach.
  ///
  /// In ar, this message translates to:
  /// **'المساعد الذكي'**
  String get coach;

  /// No description provided for @analytics.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get analytics;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @welcome.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك في هايدرا مايند'**
  String get welcome;

  /// No description provided for @intro.
  ///
  /// In ar, this message translates to:
  /// **'ابنِ عادات مريحة تناسب يومك. بياناتك محفوظة على جهازك، والتتبع يعمل دون إنترنت.'**
  String get intro;

  /// No description provided for @basics.
  ///
  /// In ar, this message translates to:
  /// **'لنتعرّف عليك'**
  String get basics;

  /// No description provided for @routine.
  ///
  /// In ar, this message translates to:
  /// **'إيقاع يومك'**
  String get routine;

  /// No description provided for @healthFirst.
  ///
  /// In ar, this message translates to:
  /// **'صحتك أولاً'**
  String get healthFirst;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get back;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @start.
  ///
  /// In ar, this message translates to:
  /// **'لنبدأ'**
  String get start;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @undo.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get undo;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @saved.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ'**
  String get saved;

  /// No description provided for @error.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إكمال العملية. راجع الاتصال والإعدادات وحاول مجدداً.'**
  String get error;

  /// No description provided for @invalid.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من القيم المدخلة'**
  String get invalid;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'الإنجليزية'**
  String get english;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// No description provided for @name.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get name;

  /// No description provided for @age.
  ///
  /// In ar, this message translates to:
  /// **'العمر'**
  String get age;

  /// No description provided for @weight.
  ///
  /// In ar, this message translates to:
  /// **'الوزن (كغ)'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In ar, this message translates to:
  /// **'الطول (سم)'**
  String get height;

  /// No description provided for @sex.
  ///
  /// In ar, this message translates to:
  /// **'المرجع السكاني للتقدير'**
  String get sex;

  /// No description provided for @unspecified.
  ///
  /// In ar, this message translates to:
  /// **'أفضل عدم التحديد'**
  String get unspecified;

  /// No description provided for @female.
  ///
  /// In ar, this message translates to:
  /// **'أنثى'**
  String get female;

  /// No description provided for @male.
  ///
  /// In ar, this message translates to:
  /// **'ذكر'**
  String get male;

  /// No description provided for @activity.
  ///
  /// In ar, this message translates to:
  /// **'مستوى النشاط'**
  String get activity;

  /// No description provided for @light.
  ///
  /// In ar, this message translates to:
  /// **'خفيف'**
  String get light;

  /// No description provided for @moderate.
  ///
  /// In ar, this message translates to:
  /// **'متوسط'**
  String get moderate;

  /// No description provided for @active.
  ///
  /// In ar, this message translates to:
  /// **'مرتفع'**
  String get active;

  /// No description provided for @wake.
  ///
  /// In ar, this message translates to:
  /// **'وقت الاستيقاظ'**
  String get wake;

  /// No description provided for @bed.
  ///
  /// In ar, this message translates to:
  /// **'وقت النوم'**
  String get bed;

  /// No description provided for @exercise.
  ///
  /// In ar, this message translates to:
  /// **'دقائق التمرين المعتادة يومياً'**
  String get exercise;

  /// No description provided for @outdoor.
  ///
  /// In ar, this message translates to:
  /// **'دقائق التعرض للخارج يومياً'**
  String get outdoor;

  /// No description provided for @environment.
  ///
  /// In ar, this message translates to:
  /// **'بيئة العمل'**
  String get environment;

  /// No description provided for @indoor.
  ///
  /// In ar, this message translates to:
  /// **'داخل المبنى'**
  String get indoor;

  /// No description provided for @outside.
  ///
  /// In ar, this message translates to:
  /// **'في الخارج'**
  String get outside;

  /// No description provided for @mixed.
  ///
  /// In ar, this message translates to:
  /// **'مختلطة'**
  String get mixed;

  /// No description provided for @sweating.
  ///
  /// In ar, this message translates to:
  /// **'التعرق المعتاد'**
  String get sweating;

  /// No description provided for @normal.
  ///
  /// In ar, this message translates to:
  /// **'معتاد'**
  String get normal;

  /// No description provided for @heavy.
  ///
  /// In ar, this message translates to:
  /// **'غزير'**
  String get heavy;

  /// No description provided for @low.
  ///
  /// In ar, this message translates to:
  /// **'قليل'**
  String get low;

  /// No description provided for @medicalCaution.
  ///
  /// In ar, this message translates to:
  /// **'حالة تؤثر في توازن السوائل'**
  String get medicalCaution;

  /// No description provided for @pregnancy.
  ///
  /// In ar, this message translates to:
  /// **'حمل'**
  String get pregnancy;

  /// No description provided for @breastfeeding.
  ///
  /// In ar, this message translates to:
  /// **'رضاعة طبيعية'**
  String get breastfeeding;

  /// No description provided for @medicalNotes.
  ///
  /// In ar, this message translates to:
  /// **'حالة صحية أو ملاحظة للطبيب (اختياري)'**
  String get medicalNotes;

  /// No description provided for @medications.
  ///
  /// In ar, this message translates to:
  /// **'أدوية تؤثر في السوائل (اختياري)'**
  String get medications;

  /// No description provided for @fluidLimit.
  ///
  /// In ar, this message translates to:
  /// **'حد السوائل الذي وصفه الطبيب (مل/يوم، اختياري)'**
  String get fluidLimit;

  /// No description provided for @sensitiveWhy.
  ///
  /// In ar, this message translates to:
  /// **'هذه المعلومات اختيارية، وتساعد على تعليق التقديرات العامة عند الحاجة إلى إرشاد طبي. لا نرسلها للمساعد السحابي. يمكنك التتبع دون إدخالها.'**
  String get sensitiveWhy;

  /// No description provided for @consent.
  ///
  /// In ar, this message translates to:
  /// **'فهمت حدود التقدير وأوافق على حفظ ملفي محلياً'**
  String get consent;

  /// No description provided for @estimateInfo.
  ///
  /// In ar, this message translates to:
  /// **'تقدير سكاني للبالغين من مراجع الهيئة الأوروبية لسلامة الأغذية: إجمالي الماء ٢–٢٫٥ لتر، مع افتراض تقريبي أن الطعام يوفر ٢٠٪. نعرض للمشروبات ١٦٠٠ أو ٢٠٠٠ مل، أو متوسطهما ١٨٠٠ مل عند عدم تحديد المرجع. مساهمة الطعام تختلف، وهذا ليس وصفة شخصية.'**
  String get estimateInfo;

  /// No description provided for @medicalInfo.
  ///
  /// In ar, this message translates to:
  /// **'لم نضع هدفاً تلقائياً. اطلب إرشاد طبيبك بشأن السوائل؛ يمكنك الاستمرار بتسجيل المشروبات.'**
  String get medicalInfo;

  /// No description provided for @prescribedInfo.
  ///
  /// In ar, this message translates to:
  /// **'نعرض الحد الذي أدخلته من طبيبك. هو سقف موصوف وليس دعوة للوصول إليه، ولا نزيده تلقائياً. اتبع خطة طبيبك لجميع مصادر السوائل.'**
  String get prescribedInfo;

  /// No description provided for @uncertainty.
  ///
  /// In ar, this message translates to:
  /// **'تقدير سكاني • عدم يقين مرتفع للاحتياجات الفردية'**
  String get uncertainty;

  /// No description provided for @notMedical.
  ///
  /// In ar, this message translates to:
  /// **'للتثقيف وتتبع العادات، وليس للتشخيص أو العلاج.'**
  String get notMedical;

  /// No description provided for @hello.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً،'**
  String get hello;

  /// No description provided for @friend.
  ///
  /// In ar, this message translates to:
  /// **'صديقنا'**
  String get friend;

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @dailyJourney.
  ///
  /// In ar, this message translates to:
  /// **'رحلتك اليوم'**
  String get dailyJourney;

  /// No description provided for @recorded.
  ///
  /// In ar, this message translates to:
  /// **'المسجّل'**
  String get recorded;

  /// No description provided for @target.
  ///
  /// In ar, this message translates to:
  /// **'الهدف التقديري'**
  String get target;

  /// No description provided for @ceiling.
  ///
  /// In ar, this message translates to:
  /// **'الحد الموصوف'**
  String get ceiling;

  /// No description provided for @remaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get remaining;

  /// No description provided for @allowance.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي ضمن الحد'**
  String get allowance;

  /// No description provided for @ml.
  ///
  /// In ar, this message translates to:
  /// **'مل'**
  String get ml;

  /// No description provided for @degree.
  ///
  /// In ar, this message translates to:
  /// **'°م'**
  String get degree;

  /// No description provided for @percent.
  ///
  /// In ar, this message translates to:
  /// **'٪'**
  String get percent;

  /// No description provided for @addWater.
  ///
  /// In ar, this message translates to:
  /// **'إضافة ماء'**
  String get addWater;

  /// No description provided for @addDrink.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مشروب'**
  String get addDrink;

  /// No description provided for @quickAdd.
  ///
  /// In ar, this message translates to:
  /// **'رشفة جديدة'**
  String get quickAdd;

  /// No description provided for @quantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية (مل)'**
  String get quantity;

  /// No description provided for @beverage.
  ///
  /// In ar, this message translates to:
  /// **'نوع المشروب'**
  String get beverage;

  /// No description provided for @water.
  ///
  /// In ar, this message translates to:
  /// **'ماء'**
  String get water;

  /// No description provided for @tea.
  ///
  /// In ar, this message translates to:
  /// **'شاي'**
  String get tea;

  /// No description provided for @coffee.
  ///
  /// In ar, this message translates to:
  /// **'قهوة'**
  String get coffee;

  /// No description provided for @milk.
  ///
  /// In ar, this message translates to:
  /// **'حليب'**
  String get milk;

  /// No description provided for @juice.
  ///
  /// In ar, this message translates to:
  /// **'عصير'**
  String get juice;

  /// No description provided for @other.
  ///
  /// In ar, this message translates to:
  /// **'مشروب آخر'**
  String get other;

  /// No description provided for @notes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة (اختياري)'**
  String get notes;

  /// No description provided for @dateTime.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ والوقت'**
  String get dateTime;

  /// No description provided for @logged.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل المشروب'**
  String get logged;

  /// No description provided for @timeline.
  ///
  /// In ar, this message translates to:
  /// **'سجل اليوم'**
  String get timeline;

  /// No description provided for @allHistory.
  ///
  /// In ar, this message translates to:
  /// **'كل السجلات'**
  String get allHistory;

  /// No description provided for @emptyHistory.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بأول رشفة. ستظهر سجلاتك هنا.'**
  String get emptyHistory;

  /// No description provided for @contribution.
  ///
  /// In ar, this message translates to:
  /// **'نسجّل الحجم الفعلي للمشروبات، دون خصم افتراضي للكافيين. تختلف المكونات والتأثيرات؛ فضّل الماء حسب إرشادك الصحي.'**
  String get contribution;

  /// No description provided for @futureTime.
  ///
  /// In ar, this message translates to:
  /// **'اختر وقتاً لا يتجاوز الوقت الحالي'**
  String get futureTime;

  /// No description provided for @weather.
  ///
  /// In ar, this message translates to:
  /// **'ذكاء الطقس'**
  String get weather;

  /// No description provided for @searchCity.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن مدينة'**
  String get searchCity;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @useLocation.
  ///
  /// In ar, this message translates to:
  /// **'استخدام موقع تقريبي'**
  String get useLocation;

  /// No description provided for @noWeather.
  ///
  /// In ar, this message translates to:
  /// **'لم تُحمّل بيانات الطقس بعد'**
  String get noWeather;

  /// No description provided for @refresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get refresh;

  /// No description provided for @feels.
  ///
  /// In ar, this message translates to:
  /// **'المحسوسة'**
  String get feels;

  /// No description provided for @humidity.
  ///
  /// In ar, this message translates to:
  /// **'الرطوبة'**
  String get humidity;

  /// No description provided for @wind.
  ///
  /// In ar, this message translates to:
  /// **'الرياح (كم/س)'**
  String get wind;

  /// No description provided for @uv.
  ///
  /// In ar, this message translates to:
  /// **'أقصى مؤشر أشعة اليوم'**
  String get uv;

  /// No description provided for @hourly.
  ///
  /// In ar, this message translates to:
  /// **'الساعات القادمة بتوقيت المدينة'**
  String get hourly;

  /// No description provided for @forecast.
  ///
  /// In ar, this message translates to:
  /// **'توقعات الأيام'**
  String get forecast;

  /// No description provided for @cached.
  ///
  /// In ar, this message translates to:
  /// **'بيانات محفوظة؛ راجع وقت التحديث'**
  String get cached;

  /// No description provided for @updated.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث'**
  String get updated;

  /// No description provided for @noResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noResults;

  /// No description provided for @savedCities.
  ///
  /// In ar, this message translates to:
  /// **'المدن المحفوظة'**
  String get savedCities;

  /// No description provided for @weatherProvider.
  ///
  /// In ar, this message translates to:
  /// **'المصدر: أوبن ميتيو. الحرارة المحسوسة مؤشر للتعرض وليست قياساً طبياً. التنبيهات الرسمية غير متاحة من هذا المزود.'**
  String get weatherProvider;

  /// No description provided for @clear.
  ///
  /// In ar, this message translates to:
  /// **'سماء صافية'**
  String get clear;

  /// No description provided for @cloudy.
  ///
  /// In ar, this message translates to:
  /// **'غائم'**
  String get cloudy;

  /// No description provided for @rain.
  ///
  /// In ar, this message translates to:
  /// **'أمطار'**
  String get rain;

  /// No description provided for @snow.
  ///
  /// In ar, this message translates to:
  /// **'ثلوج'**
  String get snow;

  /// No description provided for @storm.
  ///
  /// In ar, this message translates to:
  /// **'عواصف'**
  String get storm;

  /// No description provided for @fog.
  ///
  /// In ar, this message translates to:
  /// **'ضباب'**
  String get fog;

  /// No description provided for @unknownWeather.
  ///
  /// In ar, this message translates to:
  /// **'ظروف جوية متغيرة'**
  String get unknownWeather;

  /// No description provided for @iraqHeat.
  ///
  /// In ar, this message translates to:
  /// **'وضع حرارة العراق'**
  String get iraqHeat;

  /// No description provided for @enableHeat.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل وضع الحرارة'**
  String get enableHeat;

  /// No description provided for @heatIntro.
  ///
  /// In ar, this message translates to:
  /// **'إرشادات للتعرض للحرارة في العراق والمناخات المشابهة. لا نزيد هدف السوائل تلقائياً.'**
  String get heatIntro;

  /// No description provided for @heatProfile.
  ///
  /// In ar, this message translates to:
  /// **'نمط التعرض'**
  String get heatProfile;

  /// No description provided for @general.
  ///
  /// In ar, this message translates to:
  /// **'الصيف العام'**
  String get general;

  /// No description provided for @worker.
  ///
  /// In ar, this message translates to:
  /// **'عامل في الخارج'**
  String get worker;

  /// No description provided for @athlete.
  ///
  /// In ar, this message translates to:
  /// **'رياضي'**
  String get athlete;

  /// No description provided for @commuter.
  ///
  /// In ar, this message translates to:
  /// **'متنقّل'**
  String get commuter;

  /// No description provided for @office.
  ///
  /// In ar, this message translates to:
  /// **'عمل مكتبي'**
  String get office;

  /// No description provided for @heatNormal.
  ///
  /// In ar, this message translates to:
  /// **'راقب الطقس ووازن النشاط مع راحتك.'**
  String get heatNormal;

  /// No description provided for @heatModerate.
  ///
  /// In ar, this message translates to:
  /// **'خطط لاستراحات وماء متاح، دون شرب سريع.'**
  String get heatModerate;

  /// No description provided for @heatHigh.
  ///
  /// In ar, this message translates to:
  /// **'الجو حار. خفف المجهود وخذ استراحات بالظل أو مكان بارد.'**
  String get heatHigh;

  /// No description provided for @heatExtreme.
  ///
  /// In ar, this message translates to:
  /// **'درجة الحرارة مرتفعة جداً. قلّل التعرض للشمس وخذ استراحات منتظمة بمكان بارد.'**
  String get heatExtreme;

  /// No description provided for @heatStale.
  ///
  /// In ar, this message translates to:
  /// **'نحتاج طقساً حديثاً لتقييم التعرض. لا تعتمد على بيانات قديمة.'**
  String get heatStale;

  /// No description provided for @workerAdvice.
  ///
  /// In ar, this message translates to:
  /// **'خطط مع مسؤول العمل لاستراحات تبريد ومهام أقل جهداً، وتجنب العمل منفرداً في الحر الشديد.'**
  String get workerAdvice;

  /// No description provided for @athleteAdvice.
  ///
  /// In ar, this message translates to:
  /// **'اختر وقتاً أبرد للتمرين. للجهد الطويل، اطلب خطة فردية للسوائل والأملاح من مختص.'**
  String get athleteAdvice;

  /// No description provided for @commuterAdvice.
  ///
  /// In ar, this message translates to:
  /// **'اختر الظل وقلل الانتظار في الشمس واحتفظ بماء متاح.'**
  String get commuterAdvice;

  /// No description provided for @officeAdvice.
  ///
  /// In ar, this message translates to:
  /// **'راقب حرارة المكان وخذ استراحات حركة منتظمة.'**
  String get officeAdvice;

  /// No description provided for @safety.
  ///
  /// In ar, this message translates to:
  /// **'الترطيب الآمن'**
  String get safety;

  /// No description provided for @safetyAlways.
  ///
  /// In ar, this message translates to:
  /// **'الحماية مفعلة دائماً'**
  String get safetyAlways;

  /// No description provided for @rapidWarning.
  ///
  /// In ar, this message translates to:
  /// **'سجلت كمية كبيرة خلال وقت قصير. تجنب شرب المزيد بسرعة، واطلب المشورة الطبية إذا ظهرت أعراض غير طبيعية.'**
  String get rapidWarning;

  /// No description provided for @limitWarning.
  ///
  /// In ar, this message translates to:
  /// **'وصل السجل إلى حد السوائل الموصوف. اتبع خطتك الطبية ولا ترفع الحد من تلقاء نفسك.'**
  String get limitWarning;

  /// No description provided for @highWarning.
  ///
  /// In ar, this message translates to:
  /// **'الكمية اليومية المسجلة مرتفعة وتحتاج مراجعة السياق. هذا تنبيه للمراجعة، وليس تشخيصاً أو حداً آمناً.'**
  String get highWarning;

  /// No description provided for @safetyEducation.
  ///
  /// In ar, this message translates to:
  /// **'الإفراط في الماء قد يخفض صوديوم الدم. الصداع الشديد أو القيء أو الارتباك أو التشنجات يستدعي تقييماً طبياً عاجلاً. السجل لا يقيس ترطيب الجسم ولا يشخّص الجفاف.'**
  String get safetyEducation;

  /// No description provided for @safetyThresholds.
  ///
  /// In ar, this message translates to:
  /// **'ننبه عند تسجيل ١٠٠٠ مل خلال ساعة أو ٤٠٠٠ مل باليوم. هذه عتبات مراجعة للتطبيق وليست حدوداً طبية آمنة.'**
  String get safetyThresholds;

  /// No description provided for @emergency.
  ///
  /// In ar, this message translates to:
  /// **'فقد الوعي أو الارتباك أو التشنجات أو ألم الصدر قد يدل على حالة طارئة. اتصل بخدمات الطوارئ المحلية. مع التعرض للحرارة، ابدأ التبريد بمكان آمن. لا تعطِ شراباً لمن فقد الوعي أو تعذر عليه البلع. الماء وحده لا يعالج ضربة الحرارة.'**
  String get emergency;

  /// No description provided for @reminders.
  ///
  /// In ar, this message translates to:
  /// **'التذكيرات الذكية'**
  String get reminders;

  /// No description provided for @enableReminders.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل التذكيرات'**
  String get enableReminders;

  /// No description provided for @interval.
  ///
  /// In ar, this message translates to:
  /// **'الفاصل بالدقائق'**
  String get interval;

  /// No description provided for @custom.
  ///
  /// In ar, this message translates to:
  /// **'مخصص'**
  String get custom;

  /// No description provided for @silent.
  ///
  /// In ar, this message translates to:
  /// **'تذكيرات صامتة'**
  String get silent;

  /// No description provided for @adaptive.
  ///
  /// In ar, this message translates to:
  /// **'توقيت متكيف مع السجل'**
  String get adaptive;

  /// No description provided for @adaptiveInfo.
  ///
  /// In ar, this message translates to:
  /// **'نتجنب الرسائل القريبة من تسجيل حديث، ونوقف رسائل الشرب لبقية اليوم عند بلوغ الهدف أو الحد. تعليمات الطبيب أولاً.'**
  String get adaptiveInfo;

  /// No description provided for @nextReminder.
  ///
  /// In ar, this message translates to:
  /// **'التذكير القادم'**
  String get nextReminder;

  /// No description provided for @notScheduled.
  ///
  /// In ar, this message translates to:
  /// **'غير مجدول'**
  String get notScheduled;

  /// No description provided for @notificationHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل فتح التذكيرات'**
  String get notificationHistory;

  /// No description provided for @notificationTitle.
  ///
  /// In ar, this message translates to:
  /// **'حان وقت شرب الماء'**
  String get notificationTitle;

  /// No description provided for @notificationBody.
  ///
  /// In ar, this message translates to:
  /// **'راجع سجلّك وخذ رشفة بهدوء إذا ناسب إرشادك الصحي.'**
  String get notificationBody;

  /// No description provided for @notificationReviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'وقت مراجعة سجل السوائل'**
  String get notificationReviewTitle;

  /// No description provided for @notificationSafetyBody.
  ///
  /// In ar, this message translates to:
  /// **'راجع خطة السوائل الطبية وتنبيه السلامة قبل تسجيل المزيد.'**
  String get notificationSafetyBody;

  /// No description provided for @notificationAdd.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل ٢٥٠ مل'**
  String get notificationAdd;

  /// No description provided for @snooze.
  ///
  /// In ar, this message translates to:
  /// **'تأجيل ١٠ دقائق'**
  String get snooze;

  /// No description provided for @reminderLimits.
  ///
  /// In ar, this message translates to:
  /// **'حتى ٤٨ إشعاراً للأيام القليلة القادمة، تتجدد عند فتح التطبيق. قد يؤخرها النظام. افتح التطبيق دورياً؛ التوقيت الدقيق غير مضمون.'**
  String get reminderLimits;

  /// No description provided for @permissionDenied.
  ///
  /// In ar, this message translates to:
  /// **'الإذن أو الخدمة غير متاحة. راجع إعدادات الجهاز.'**
  String get permissionDenied;

  /// No description provided for @openDeviceSettings.
  ///
  /// In ar, this message translates to:
  /// **'فتح إعدادات التطبيق'**
  String get openDeviceSettings;

  /// No description provided for @engagementInfo.
  ///
  /// In ar, this message translates to:
  /// **'نعرض مرات فتح التذكيرات المسجلة فقط؛ لا نؤكد تسليم كل إشعار أو نسبة استجابة موثوقة.'**
  String get engagementInfo;

  /// No description provided for @habits.
  ///
  /// In ar, this message translates to:
  /// **'ذاكرة العادات'**
  String get habits;

  /// No description provided for @enableHabits.
  ///
  /// In ar, this message translates to:
  /// **'التعلم من السجل المحلي'**
  String get enableHabits;

  /// No description provided for @habitIntro.
  ///
  /// In ar, this message translates to:
  /// **'نحلل أوقات التسجيل على جهازك. غياب السجل لا يعني أنك لم تشرب. نحتاج سبعة أيام مسجلة سابقة لإظهار نمط.'**
  String get habitIntro;

  /// No description provided for @insufficient.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات كافية بعد'**
  String get insufficient;

  /// No description provided for @quietHour.
  ///
  /// In ar, this message translates to:
  /// **'ساعة يقل فيها التسجيل عادةً'**
  String get quietHour;

  /// No description provided for @resetHabits.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف التعلم ومسح استنتاجاته'**
  String get resetHabits;

  /// No description provided for @habitResetInfo.
  ///
  /// In ar, this message translates to:
  /// **'الاستنتاجات تحسب عند الطلب ولا تخزن منفصلة. يمكنك إيقافها دون حذف السجل، أو حذف السجل من الخصوصية.'**
  String get habitResetInfo;

  /// No description provided for @coachIntro.
  ///
  /// In ar, this message translates to:
  /// **'مرشد للعادات، وليس بديلاً عن الطبيب. الحسابات والتحذيرات من محرك مستقل.'**
  String get coachIntro;

  /// No description provided for @ask.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سؤالك'**
  String get ask;

  /// No description provided for @send.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get send;

  /// No description provided for @thinking.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التفكير…'**
  String get thinking;

  /// No description provided for @offlineCoach.
  ///
  /// In ar, this message translates to:
  /// **'إرشاد محلي'**
  String get offlineCoach;

  /// No description provided for @cloudCoach.
  ///
  /// In ar, this message translates to:
  /// **'مساعد سحابي • مقيد بقواعد السلامة'**
  String get cloudCoach;

  /// No description provided for @targetQuestion.
  ///
  /// In ar, this message translates to:
  /// **'كيف حُسب هدفي؟'**
  String get targetQuestion;

  /// No description provided for @weatherQuestion.
  ///
  /// In ar, this message translates to:
  /// **'كيف أتعامل مع الحر؟'**
  String get weatherQuestion;

  /// No description provided for @habitQuestion.
  ///
  /// In ar, this message translates to:
  /// **'ما نمط تسجيلي؟'**
  String get habitQuestion;

  /// No description provided for @generalCoach.
  ///
  /// In ar, this message translates to:
  /// **'وزّع عادات الشرب خلال ساعات اليقظة وراجع سجلّك بهدوء. استجب لاحتياجاتك واتبع تعليمات طبيبك.'**
  String get generalCoach;

  /// No description provided for @iraqiCoach.
  ///
  /// In ar, this message translates to:
  /// **'خلّي المي قريب منك، وراجع سجلّك خلال اليوم. تعليمات الطبيب هي الأساس.'**
  String get iraqiCoach;

  /// No description provided for @coachRoutine.
  ///
  /// In ar, this message translates to:
  /// **'اربط مراجعة السجل باستراحة أو وجبة ثابتة. عدّل التذكيرات بما يلائم نومك وعملك.'**
  String get coachRoutine;

  /// No description provided for @deleteChat.
  ///
  /// In ar, this message translates to:
  /// **'حذف المحادثة'**
  String get deleteChat;

  /// No description provided for @iraqiDialect.
  ///
  /// In ar, this message translates to:
  /// **'أسلوب عراقي للمحادثة العامة'**
  String get iraqiDialect;

  /// No description provided for @daily.
  ///
  /// In ar, this message translates to:
  /// **'يومي'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In ar, this message translates to:
  /// **'أسبوعي'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In ar, this message translates to:
  /// **'شهري'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In ar, this message translates to:
  /// **'سنوي'**
  String get yearly;

  /// No description provided for @average.
  ///
  /// In ar, this message translates to:
  /// **'المتوسط اليومي'**
  String get average;

  /// No description provided for @total.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get total;

  /// No description provided for @frequency.
  ///
  /// In ar, this message translates to:
  /// **'مرات التسجيل'**
  String get frequency;

  /// No description provided for @weeklyPreview.
  ///
  /// In ar, this message translates to:
  /// **'الأيام السبعة الماضية'**
  String get weeklyPreview;

  /// No description provided for @expected.
  ///
  /// In ar, this message translates to:
  /// **'المتوقع بنهاية اليوم'**
  String get expected;

  /// No description provided for @chance.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الأيام المشابهة التي تبلغ الهدف'**
  String get chance;

  /// No description provided for @predictionInfo.
  ///
  /// In ar, this message translates to:
  /// **'تقدير من الأيام المسجلة فقط، بافتراض تكرار نمط بقية اليوم. ليس احتمالاً طبياً، وقد لا يمثل الأيام غير المسجلة.'**
  String get predictionInfo;

  /// No description provided for @predictionDisabled.
  ///
  /// In ar, this message translates to:
  /// **'فعّل تعلم العادات لعرض التوقعات المحلية.'**
  String get predictionDisabled;

  /// No description provided for @beverageBreakdown.
  ///
  /// In ar, this message translates to:
  /// **'حسب المشروب'**
  String get beverageBreakdown;

  /// No description provided for @exportCsv.
  ///
  /// In ar, this message translates to:
  /// **'تصدير CSV'**
  String get exportCsv;

  /// No description provided for @exportPdf.
  ///
  /// In ar, this message translates to:
  /// **'تصدير PDF'**
  String get exportPdf;

  /// No description provided for @report.
  ///
  /// In ar, this message translates to:
  /// **'تقرير السوائل'**
  String get report;

  /// No description provided for @noData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سجلات في هذه الفترة'**
  String get noData;

  /// No description provided for @correlationInfo.
  ///
  /// In ar, this message translates to:
  /// **'لا يتوفر تاريخ طقس كافٍ لحساب ارتباط موثوق؛ ولا نستنتج أن الطقس سبب تغير الشرب.'**
  String get correlationInfo;

  /// No description provided for @achievements.
  ///
  /// In ar, this message translates to:
  /// **'إنجازاتك'**
  String get achievements;

  /// No description provided for @streak.
  ///
  /// In ar, this message translates to:
  /// **'أيام تسجيل متتالية'**
  String get streak;

  /// No description provided for @firstSip.
  ///
  /// In ar, this message translates to:
  /// **'أول تسجيل'**
  String get firstSip;

  /// No description provided for @weekHabit.
  ///
  /// In ar, this message translates to:
  /// **'سبعة أيام من الاستمرارية'**
  String get weekHabit;

  /// No description provided for @achievementInfo.
  ///
  /// In ar, this message translates to:
  /// **'نكافئ الاستمرارية ولا نكافئ تجاوز هدف السوائل.'**
  String get achievementInfo;

  /// No description provided for @earned.
  ///
  /// In ar, this message translates to:
  /// **'مكتسب'**
  String get earned;

  /// No description provided for @inProgress.
  ///
  /// In ar, this message translates to:
  /// **'قيد التقدم'**
  String get inProgress;

  /// No description provided for @health.
  ///
  /// In ar, this message translates to:
  /// **'التكامل الصحي'**
  String get health;

  /// No description provided for @healthIntro.
  ///
  /// In ar, this message translates to:
  /// **'ربط اختياري لقراءة مدة التمارين خلال سبعة أيام. لا تُرسل البيانات للمساعد ولا تغيّر الهدف تلقائياً.'**
  String get healthIntro;

  /// No description provided for @connectHealth.
  ///
  /// In ar, this message translates to:
  /// **'قراءة التمارين بإذنك'**
  String get connectHealth;

  /// No description provided for @exerciseMinutes.
  ///
  /// In ar, this message translates to:
  /// **'دقائق التمارين المستوردة'**
  String get exerciseMinutes;

  /// No description provided for @healthUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'تعذر الاتصال أو لم يُمنح الإذن. تحقق من هيلث كونكت أو تطبيق الصحة.'**
  String get healthUnavailable;

  /// No description provided for @privacy.
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية والبيانات'**
  String get privacy;

  /// No description provided for @privacyText.
  ///
  /// In ar, this message translates to:
  /// **'تُشفّر البيانات محلياً بمفتاح في مخزن الجهاز الآمن. لا حساب ولا مزامنة افتراضية ولا إعلانات أو تتبع. يستقبل مزود الطقس المدينة أو الموقع التقريبي فقط. المساعد السحابي الاختياري يستقبل سؤالك ولغة الإجابة؛ تجنب كتابة معلومات صحية حساسة فيه. الملفات المصدّرة نسخ غير مشفرة تختار مشاركتها.'**
  String get privacyText;

  /// No description provided for @deleteHistory.
  ///
  /// In ar, this message translates to:
  /// **'حذف سجل المشروبات'**
  String get deleteHistory;

  /// No description provided for @deleteAll.
  ///
  /// In ar, this message translates to:
  /// **'حذف جميع البيانات وإعادة الضبط'**
  String get deleteAll;

  /// No description provided for @confirmDelete.
  ///
  /// In ar, this message translates to:
  /// **'الحذف نهائي من هذا الجهاز. تبقى النسخ التي صدّرتها عند الجهات التي شاركتها معها.'**
  String get confirmDelete;

  /// No description provided for @theme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get theme;

  /// No description provided for @system.
  ///
  /// In ar, this message translates to:
  /// **'حسب الجهاز'**
  String get system;

  /// No description provided for @dark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get dark;

  /// No description provided for @lightTheme.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get lightTheme;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الإشعارات'**
  String get notifications;

  /// No description provided for @cloudSetup.
  ///
  /// In ar, this message translates to:
  /// **'إعداد المساعد السحابي'**
  String get cloudSetup;

  /// No description provided for @backendUrl.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الخادم الآمن HTTPS'**
  String get backendUrl;

  /// No description provided for @backendToken.
  ///
  /// In ar, this message translates to:
  /// **'رمز وصول خادمك'**
  String get backendToken;

  /// No description provided for @cloudConsent.
  ///
  /// In ar, this message translates to:
  /// **'أوافق على إرسال أسئلتي إلى الخادم ومزود الذكاء الاصطناعي'**
  String get cloudConsent;

  /// No description provided for @disconnect.
  ///
  /// In ar, this message translates to:
  /// **'فصل الاتصال السحابي'**
  String get disconnect;

  /// No description provided for @setupInfo.
  ///
  /// In ar, this message translates to:
  /// **'انشر خادم جيميني المرفق وضع مفتاح المزود فيه فقط. لا تضع مفتاح جيميني في التطبيق. رمز خادمك يحفظ في مخزن الجهاز الآمن.'**
  String get setupInfo;

  /// No description provided for @favorites.
  ///
  /// In ar, this message translates to:
  /// **'أحجام الأكواب السريعة (مل، مفصولة بفواصل)'**
  String get favorites;

  /// No description provided for @storageError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح البيانات المحفوظة بأمان. لم نمسحها. أعد فتح التطبيق أو راجع دعم الجهاز.'**
  String get storageError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
