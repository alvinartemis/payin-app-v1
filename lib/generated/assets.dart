// GENERATED CODE - DO NOT MODIFY BY HAND

class Assets {
  Assets._();

  // Images
  static const String imagesLogo = 'assets/images/logo.png';
  static const String imagesLogoWhite = 'assets/images/logo_white.png';
  static const String imagesPlaceholder = 'assets/images/placeholder.png';
  static const String imagesEmptyInvoice = 'assets/images/empty_invoice.png';
  static const String imagesEmptyAnalytics = 'assets/images/empty_analytics.png';
  static const String imagesOnboarding1 = 'assets/images/onboarding/onboarding1.png';
  static const String imagesOnboarding2 = 'assets/images/onboarding/onboarding2.png';
  static const String imagesOnboarding3 = 'assets/images/onboarding/onboarding3.png';
  static const String imagesInvoiceTemplate = 'assets/images/invoice_template.png';
  static const String imagesSuccessPayment = 'assets/images/success_payment.png';

  // Icons
  static const String iconsInvoice = 'assets/icons/invoice.svg';
  static const String iconsDashboard = 'assets/icons/dashboard.svg';
  static const String iconsAnalytics = 'assets/icons/analytics.svg';
  static const String iconsSettings = 'assets/icons/settings.svg';
  static const String iconsClient = 'assets/icons/client.svg';
  static const String iconsEmail = 'assets/icons/email.svg';
  static const String iconsPdf = 'assets/icons/pdf.svg';
  static const String iconsPayment = 'assets/icons/payment.svg';
  static const String iconsReport = 'assets/icons/report.svg';
  static const String iconsCalendar = 'assets/icons/calendar.svg';
  static const String iconsCurrency = 'assets/icons/currency.svg';
  static const String iconsChart = 'assets/icons/chart.svg';
  static const String iconsInvoicePaid = 'assets/icons/invoice_paid.svg';
  static const String iconsInvoicePending = 'assets/icons/invoice_pending.svg';
  static const String iconsInvoiceOverdue = 'assets/icons/invoice_overdue.svg';

  // Logos
  static const String logosAppLogo = 'assets/logos/app_logo.png';
  static const String logosAppLogoWhite = 'assets/logos/app_logo_white.png';
  static const String logosAppLogoSmall = 'assets/logos/app_logo_small.png';
  static const String logosPayinLogo = 'assets/logos/payin_logo.png';
  static const String logosPayinLogoText = 'assets/logos/payin_logo_text.png';
  static const String logosSplashLogo = 'assets/logos/splash_logo.png';

  // Fonts
  static const String fontsInterRegular = 'assets/fonts/Inter-Regular.ttf';
  static const String fontsInterMedium = 'assets/fonts/Inter-Medium.ttf';
  static const String fontsInterSemiBold = 'assets/fonts/Inter-SemiBold.ttf';
  static const String fontsInterBold = 'assets/fonts/Inter-Bold.ttf';

  // Lottie Animations
  static const String animationsLoading = 'assets/animations/loading.json';
  static const String animationsSuccess = 'assets/animations/success.json';
  static const String animationsError = 'assets/animations/error.json';
  static const String animationsEmpty = 'assets/animations/empty.json';
  static const String animationsInvoiceCreated = 'assets/animations/invoice_created.json';

  // Helper methods
  static String getInvoiceStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return iconsInvoicePaid;
      case 'sent':
        return iconsInvoicePending;
      case 'overdue':
        return iconsInvoiceOverdue;
      case 'draft':
      default:
        return iconsInvoice;
    }
  }

  static String getLogoByTheme({bool isDark = false}) {
    return isDark ? logosAppLogoWhite : logosAppLogo;
  }

  static bool isValidAsset(String assetPath) {
    return assetPath.startsWith('assets/') && assetPath.isNotEmpty;
  }
}

// PERBAIKAN: Memindahkan classes ke top-level
class AssetsImages {
  static const String logo = Assets.imagesLogo;
  static const String logoWhite = Assets.imagesLogoWhite;
  static const String placeholder = Assets.imagesPlaceholder;
  static const String emptyInvoice = Assets.imagesEmptyInvoice;
  static const String emptyAnalytics = Assets.imagesEmptyAnalytics;
  static const String invoiceTemplate = Assets.imagesInvoiceTemplate;
  static const String successPayment = Assets.imagesSuccessPayment;
  
  // Onboarding images
  static const List<String> onboarding = [
    Assets.imagesOnboarding1,
    Assets.imagesOnboarding2,
    Assets.imagesOnboarding3,
  ];
}

class AssetsIcons {
  static const String invoice = Assets.iconsInvoice;
  static const String dashboard = Assets.iconsDashboard;
  static const String analytics = Assets.iconsAnalytics;
  static const String settings = Assets.iconsSettings;
  static const String client = Assets.iconsClient;
  static const String email = Assets.iconsEmail;
  static const String pdf = Assets.iconsPdf;
  static const String payment = Assets.iconsPayment;
  static const String report = Assets.iconsReport;
  static const String calendar = Assets.iconsCalendar;
  static const String currency = Assets.iconsCurrency;
  static const String chart = Assets.iconsChart;
  
  // Invoice status icons
  static const String invoicePaid = Assets.iconsInvoicePaid;
  static const String invoicePending = Assets.iconsInvoicePending;
  static const String invoiceOverdue = Assets.iconsInvoiceOverdue;
}

class AssetsLogos {
  static const String appLogo = Assets.logosAppLogo;
  static const String appLogoWhite = Assets.logosAppLogoWhite;
  static const String appLogoSmall = Assets.logosAppLogoSmall;
  static const String payinLogo = Assets.logosPayinLogo;
  static const String payinLogoText = Assets.logosPayinLogoText;
  static const String splashLogo = Assets.logosSplashLogo;
}

class AssetsFonts {
  static const String interRegular = Assets.fontsInterRegular;
  static const String interMedium = Assets.fontsInterMedium;
  static const String interSemiBold = Assets.fontsInterSemiBold;
  static const String interBold = Assets.fontsInterBold;
}

class AssetsAnimations {
  static const String loading = Assets.animationsLoading;
  static const String success = Assets.animationsSuccess;
  static const String error = Assets.animationsError;
  static const String empty = Assets.animationsEmpty;
  static const String invoiceCreated = Assets.animationsInvoiceCreated;
}
