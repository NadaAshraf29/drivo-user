import '../domain/models/walkthrough_model.dart';

class WalkthroughHelper {
  // Target Key IDs
  static const String targetHomeCategories = 'home_categories';
  static const String targetHomeSearch = 'home_search';
  static const String targetHomeNavActivity = 'home_nav_activity';
  static const String targetHomeNavNotifications = 'home_nav_notifications';
  static const String targetHomeNavProfile = 'home_nav_profile';

  static const String targetSearchPickup = 'search_pickup';
  static const String targetSearchDestination = 'search_destination';
  static const String targetSearchDate = 'search_date';
  static const String targetSearchTime = 'search_time';
  static const String targetSearchSeats = 'search_seats';
  static const String targetSearchGender = 'search_gender';
  static const String targetSearchSubmit = 'search_submit';

  static const String targetUniPicker = 'uni_picker';
  static const String targetUniPickup = 'uni_pickup';
  static const String targetUniDate = 'uni_date';
  static const String targetUniOptions = 'uni_options';
  static const String targetUniSubmit = 'uni_submit';

  static const String targetSchoolPicker = 'school_picker';
  static const String targetSchoolPickup = 'school_pickup';
  static const String targetSchoolDate = 'school_date';
  static const String targetSchoolOptions = 'school_options';
  static const String targetSchoolSubmit = 'school_submit';

  static const String targetResultsFirstCard = 'results_first_card';
  static const String targetResultsContinue = 'results_continue';

  static const String targetBookingSummary = 'booking_summary';
  static const String targetBookingDriver = 'booking_driver';
  static const String targetBookingConfirm = 'booking_confirm';

  // ----------------------------------------------------
  // Home Walkthrough Flow
  // ----------------------------------------------------
  static List<WalkthroughStep> getHomeSteps() {
    return [
      const WalkthroughStep(
        id: 'home_step_search',
        targetKeyId: targetHomeSearch,
        title: "Where are you heading?",
        titleAr: "رايح فين؟",
        description:
            "Quickly search for any destination or create your custom ride with your preferred stops.",
        descriptionAr:
            "دوس هنا وابحث عن وجهتك بكل سهولة أو حدد خط سيرك ومحطاتك الخاصة.",
        preferredPosition: TooltipPosition.bottom,
        borderRadius: 16,
      ),
      const WalkthroughStep(
        id: 'home_step_categories',
        targetKeyId: targetHomeCategories,
        title: "Start here! Choose your ride",
        titleAr: "اختار نوع رحلتك",
        description:
            "Choose between Anytime rides, Routine daily commute, Travel between cities, or University and School routes.",
        descriptionAr:
            "اختار نوع الرحلة اللي بتدور عليها: رحلات فورية، يومية، سفر بين المحافظات، أو جامعات ومدارس.",
        preferredPosition: TooltipPosition.top,
        borderRadius: 20,
      ),
      const WalkthroughStep(
        id: 'home_step_activity',
        targetKeyId: targetHomeNavActivity,
        title: "My Trips & Bookings",
        titleAr: "مشاويري وحجوزاتي",
        description:
            "Track your active rides, upcoming bookings, and history all in one place.",
        descriptionAr:
            "تابع مشاويرك ورحلاتك المحجوزة هنا، وشوف كل تفاصيل الرحلات الحالية والسابقة.",
        preferredPosition: TooltipPosition.top,
        borderRadius: 20,
        autoScroll: false,
      ),
      const WalkthroughStep(
        id: 'home_step_notifications',
        targetKeyId: targetHomeNavNotifications,
        title: "Stay updated",
        titleAr: "خليك متابع أول بأول",
        description:
            "Receive alerts on driver arrivals, ride status updates, and best travel offers.",
        descriptionAr:
            "هنا هتوصلك كل التنبيهات وتحديثات الرحلات وعروض السفر أول بأول.",
        preferredPosition: TooltipPosition.top,
        borderRadius: 20,
        autoScroll: false,
      ),
      const WalkthroughStep(
        id: 'home_step_profile',
        targetKeyId: targetHomeNavProfile,
        title: "Your Profile & Wallet",
        titleAr: "حسابك ومحفظتك",
        description:
            "Manage your personal info, wallet balance, saved addresses, and app preferences.",
        descriptionAr:
            "حسابك وإعداداتك وكل بياناتك هنا: المحفظة، العناوين المحفوظة، والإعدادات.",
        preferredPosition: TooltipPosition.top,
        borderRadius: 20,
        autoScroll: false,
      ),
    ];
  }

  // ----------------------------------------------------
  // Search Flow (Set Destination Carpool Screen)
  // ----------------------------------------------------
  static List<WalkthroughStep> getSearchSteps({required String carpoolType}) {
    final isRoutine = carpoolType == 'routine';
    final isTrip = carpoolType == 'trip';
    final hasTime = isRoutine || isTrip;
    final isTravelOrSahel = carpoolType == 'travel' || carpoolType == 'north_coast';

    return [
      WalkthroughStep(
        id: 'search_step_pickup',
        targetKeyId: targetSearchPickup,
        title: isTravelOrSahel
            ? "Choose your boarding station"
            : "Start here — where are you leaving from?",
        titleAr: isTravelOrSahel
            ? "اختار محطة أو نقطة التجمع"
            : "هتتحرك منين؟ حدد نقطة الانطلاق",
        description: isTravelOrSahel
            ? "Pick your departure station or city from available meeting points."
            : "Set your exact pickup location or use your current location on the map.",
        descriptionAr: isTravelOrSahel
            ? "اختار محطة أو نقطة الانطلاق المتاحة على خط السير."
            : "حدد مكان تحركك بدقة أو اختار موقعك الحالي على الخريطة.",
        preferredPosition: TooltipPosition.bottom,
        borderRadius: 16,
      ),
      WalkthroughStep(
        id: 'search_step_destination',
        targetKeyId: targetSearchDestination,
        title: isTravelOrSahel
            ? "Select your destination stop"
            : "Great! Now tell us where you're going",
        titleAr: isTravelOrSahel
            ? "اختار محطة الوصول"
            : "تمام! دلوقتي اختار رايح فين",
        description:
            "Select where you want to arrive to match rides heading your way.",
        descriptionAr:
            "حدد وجهة الوصول عشان نظهرلك كل الرحلات المتاحة في نفس الاتجاه.",
        preferredPosition: TooltipPosition.bottom,
        borderRadius: 16,
      ),
      const WalkthroughStep(
        id: 'search_step_date',
        targetKeyId: targetSearchDate,
        title: "When do you want to travel?",
        titleAr: "حدد اليوم المناسب ليك",
        description:
            "Choose the travel date that works best for your schedule.",
        descriptionAr: "حدد يوم وتاريخ السفر المناسب لمشوارك.",
        preferredPosition: TooltipPosition.bottom,
        borderRadius: 16,
      ),
      if (hasTime)
        WalkthroughStep(
          id: 'search_step_time',
          targetKeyId: targetSearchTime,
          title: isRoutine
              ? "Departure & Return Times"
              : "What time works for you?",
          titleAr: isRoutine
              ? "مواعيد الذهاب والعودة"
              : "اختار وقت التحرك المناسب",
          description: isRoutine
              ? "Set your daily work commute departure and return timings."
              : "Pick your preferred departure time to find matching drivers.",
          descriptionAr: isRoutine
              ? "حدد مواعيد الذهاب للعمل وميعاد الرجوع المناسب ليك يومياً."
              : "حدد وقت التحرك عشان تلاقي كباتن ماشيين في نفس المعاد.",
          preferredPosition: TooltipPosition.bottom,
          borderRadius: 16,
        ),
      const WalkthroughStep(
        id: 'search_step_seats',
        targetKeyId: targetSearchSeats,
        title: "How many seats do you need?",
        titleAr: "محتاج كام كرسي؟",
        description:
            "Select how many seats you want to reserve for you or your companions.",
        descriptionAr: "اختار عدد الأماكن اللي محتاجها في الرحلة.",
        preferredPosition: TooltipPosition.bottom,
        borderRadius: 16,
      ),
      if (carpoolType != 'trip')
        const WalkthroughStep(
          id: 'search_step_gender',
          targetKeyId: targetSearchGender,
          title: "Passenger Preference",
          titleAr: "تفضيل نوع الركاب",
          description:
              "Filter rides by gender preference (Both, Male only, or Female only).",
          descriptionAr:
              "تقدر تختار تفضيل الركاب المناسب ليك (الكل / شباب فقط / بنات فقط).",
          preferredPosition: TooltipPosition.top,
          borderRadius: 16,
        ),
      const WalkthroughStep(
        id: 'search_step_submit',
        targetKeyId: targetSearchSubmit,
        title: "You're all set! Find rides",
        titleAr: "كل حاجة جاهزة! ابحث عن الرحلات",
        description:
            "Tap here to discover available verified drivers and trips.",
        descriptionAr: "دوس هنا وشوف الرحلات المتاحة والكباتن على خط سيرك.",
        preferredPosition: TooltipPosition.top,
        borderRadius: 25,
      ),
    ];
  }

  // ----------------------------------------------------
  // University Search Flow
  // ----------------------------------------------------
  static List<WalkthroughStep> getUniversitySteps() {
    return [
      const WalkthroughStep(
        id: 'uni_step_picker',
        targetKeyId: targetUniPicker,
        title: "Select your University",
        titleAr: "اختار جامعتك",
        description:
            "Choose your campus to see tailored student carpool routes.",
        descriptionAr:
            "اختار الجامعة أو الأكاديمية عشان تشوف خطوط السير المخصصة للطلبة.",
        preferredPosition: TooltipPosition.bottom,
        borderRadius: 16,
      ),
      const WalkthroughStep(
        id: 'uni_step_pickup',
        targetKeyId: targetUniPickup,
        title: "Nearest pickup point",
        titleAr: "أقرب نقطة تجمع",
        description:
            "Pick the meeting point closest to your home for student pickup.",
        descriptionAr: "اختار أقرب نقطة ركوب وتجمع مناسبة ليك من منطقتك.",
        preferredPosition: TooltipPosition.bottom,
        borderRadius: 16,
      ),
      const WalkthroughStep(
        id: 'uni_step_date',
        targetKeyId: targetUniDate,
        title: "Select commute date",
        titleAr: "حدد تاريخ المشوار",
        description: "Pick the day you want to travel to university.",
        descriptionAr: "حدد اليوم اللي عندك فيه محاضرات ومحتاج تتحرك فيه.",
        preferredPosition: TooltipPosition.bottom,
        borderRadius: 16,
      ),
      const WalkthroughStep(
        id: 'uni_step_options',
        targetKeyId: targetUniOptions,
        title: "Seats & Options",
        titleAr: "المقاعد وتفضيلات الرحلة",
        description:
            "Choose number of seats, return ride needs, and passenger preferences.",
        descriptionAr:
            "حدد عدد المقاعد، وإذا كنت محتاج رحلة عودة وتفضيل نوع الركاب.",
        preferredPosition: TooltipPosition.top,
        borderRadius: 16,
      ),
      const WalkthroughStep(
        id: 'uni_step_submit',
        targetKeyId: targetUniSubmit,
        title: "Find University Rides",
        titleAr: "ابحث عن رحلات الجامعة",
        description: "Tap to find available rides heading to your campus.",
        descriptionAr: "دوس هنا وشوف رحلات الجامعة المتاحة واحجز مكانك.",
        preferredPosition: TooltipPosition.top,
        borderRadius: 25,
      ),
    ];
  }

  // ----------------------------------------------------
  // School Search Flow
  // ----------------------------------------------------
  static List<WalkthroughStep> getSchoolSteps() {
    return [
      const WalkthroughStep(
        id: 'school_step_picker',
        targetKeyId: targetSchoolPicker,
        title: "Select School",
        titleAr: "اختار المدرسة",
        description: "Choose the school destination for student routes.",
        descriptionAr: "اختار المدرسة عشان نظهرلك خطوط السير المتاحة.",
        preferredPosition: TooltipPosition.bottom,
        borderRadius: 16,
      ),
      const WalkthroughStep(
        id: 'school_step_pickup',
        targetKeyId: targetSchoolPickup,
        title: "Pickup Point",
        titleAr: "نقطة التجمع والركوب",
        description: "Pick your neighborhood meeting location.",
        descriptionAr: "اختار نقطة التجمع والركوب الأقرب لمكان سكنك.",
        preferredPosition: TooltipPosition.bottom,
        borderRadius: 16,
      ),
      const WalkthroughStep(
        id: 'school_step_date',
        targetKeyId: targetSchoolDate,
        title: "School Day Date",
        titleAr: "تاريخ اليوم الدراسي",
        description: "Select the starting date for the school ride.",
        descriptionAr: "حدد تاريخ بدء رحلات المدرسة.",
        preferredPosition: TooltipPosition.bottom,
        borderRadius: 16,
      ),
      const WalkthroughStep(
        id: 'school_step_options',
        targetKeyId: targetSchoolOptions,
        title: "Seats & Preferences",
        titleAr: "المقاعد والخيارات",
        description: "Select seats count, return trip option, and preferences.",
        descriptionAr: "حدد عدد المقاعد، خيار العودة، وتفضيل الركاب.",
        preferredPosition: TooltipPosition.top,
        borderRadius: 16,
      ),
      const WalkthroughStep(
        id: 'school_step_submit',
        targetKeyId: targetSchoolSubmit,
        title: "Search School Rides",
        titleAr: "ابحث عن رحلات المدرسة",
        description: "Tap to view safe and trusted school commute options.",
        descriptionAr: "دوس هنا وشوف باقات ورحلات المدارس المتاحة.",
        preferredPosition: TooltipPosition.top,
        borderRadius: 25,
      ),
    ];
  }

  // ----------------------------------------------------
  // Search Results Flow
  // ----------------------------------------------------
  static List<WalkthroughStep> getSearchResultsSteps() {
    return [
      const WalkthroughStep(
        id: 'results_step_card',
        targetKeyId: targetResultsFirstCard,
        title: "Matching Ride Found!",
        titleAr: "لقينا رحلة مناسبة ليك!",
        description:
            "Here you see the driver rating, departure time, route stops, price per seat, and available capacity.",
        descriptionAr:
            "هنا بتشوف تفاصيل الرحلة: تقييم الكابتن، ميعاد التحرك، خط السير، سعر الكرسي، والمقاعد المتاحة.",
        preferredPosition: TooltipPosition.bottom,
        borderRadius: 20,
      ),
      const WalkthroughStep(
        id: 'results_step_continue',
        targetKeyId: targetResultsContinue,
        title: "Ready to Book?",
        titleAr: "لقيت الرحلة المناسبة؟",
        description:
            "Tap here to continue to booking details and secure your ride.",
        descriptionAr: "دوس هنا عشان تختار الرحلة وتكمل باقي تفاصيل الحجز.",
        preferredPosition: TooltipPosition.top,
        borderRadius: 28,
      ),
    ];
  }

  // ----------------------------------------------------
  // Booking Screen Flow
  // ----------------------------------------------------
  static List<WalkthroughStep> getBookingSteps() {
    return [
      const WalkthroughStep(
        id: 'booking_step_summary',
        targetKeyId: targetBookingSummary,
        title: "Trip & Route Summary",
        titleAr: "ملخص الرحلة وخط السير",
        description:
            "Review your pickup location, drop-off point, and trip schedule before booking.",
        descriptionAr:
            "راجع نقطة الركوب والنزول، وميعاد الرحلة وتفاصيل السعر بدقة.",
        preferredPosition: TooltipPosition.bottom,
        borderRadius: 20,
      ),
      const WalkthroughStep(
        id: 'booking_step_driver',
        targetKeyId: targetBookingDriver,
        title: "Driver & Car Details",
        titleAr: "بيانات الكابتن والعربية",
        description:
            "View your assigned driver's verification status, car model, and plate number.",
        descriptionAr:
            "اتعرف على الكابتن الموثق، نوع العربية ورقم اللوحة لرحلة آمنة.",
        preferredPosition: TooltipPosition.top,
        borderRadius: 20,
      ),
      const WalkthroughStep(
        id: 'booking_step_confirm',
        targetKeyId: targetBookingConfirm,
        title: "Confirm & Book Now",
        titleAr: "كل حاجة تمام؟ احجز مكانك",
        description:
            "Everything looks good? Confirm your booking and you're ready to go!",
        descriptionAr:
            "كل حاجة تمام؟ اكد حجزك ومكانك هيكون مضمون في الرحلة.",
        preferredPosition: TooltipPosition.top,
        borderRadius: 28,
      ),
    ];
  }
}
