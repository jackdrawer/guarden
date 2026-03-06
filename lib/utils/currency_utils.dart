import 'package:intl/intl.dart';
import '../i18n/strings.g.dart';

class CurrencyUtils {
  static String getDefaultCurrency() {
    final locale = LocaleSettings.currentLocale;
    switch (locale.languageCode) {
      case 'tr':
        return 'TRY';
      default:
        return 'USD';
    }
  }

  static String getCurrencySymbol(String code) {
    try {
      final format = NumberFormat.simpleCurrency(name: code);
      return format.currencySymbol;
    } catch (_) {
      return code;
    }
  }

  static String formatAmount(double amount, String currencyCode) {
    final symbol = getCurrencySymbol(currencyCode);
    final format = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    return format.format(amount);
  }

  static List<String> getCommonCurrencies() {
    return ['TRY', 'USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD'];
  }
}
