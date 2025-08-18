class CurrencyData {
  final String code;
  final String name;
  final String symbol;

  CurrencyData({
    required this.code,
    required this.name,
    required this.symbol,
  });
}

class CurrencyUtility {
  static final List<CurrencyData> currencies = [
    CurrencyData(code: 'GBP', name: 'British Pound', symbol: '£'),
    CurrencyData(code: 'USD', name: 'US Dollar', symbol: '\$'),
    CurrencyData(code: 'EUR', name: 'Euro', symbol: '€'),
    CurrencyData(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
    CurrencyData(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$'),
    CurrencyData(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$'),
    CurrencyData(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF'),
    CurrencyData(code: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
    CurrencyData(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
    CurrencyData(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$'),
    CurrencyData(code: 'RUB', name: 'Russian Ruble', symbol: '₽'),
    CurrencyData(code: 'KRW', name: 'South Korean Won', symbol: '₩'),
    CurrencyData(code: 'MXN', name: 'Mexican Peso', symbol: '\$'),
    CurrencyData(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$'),
    CurrencyData(code: 'HKD', name: 'Hong Kong Dollar', symbol: 'HK\$'),
    CurrencyData(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr'),
    CurrencyData(code: 'SEK', name: 'Swedish Krona', symbol: 'kr'),
    CurrencyData(code: 'DKK', name: 'Danish Krone', symbol: 'kr'),
    CurrencyData(code: 'PLN', name: 'Polish Złoty', symbol: 'zł'),
    CurrencyData(code: 'TRY', name: 'Turkish Lira', symbol: '₺'),
  ];

  static CurrencyData? getCurrencyByCode(String code) {
    try {
      return currencies.firstWhere((currency) => currency.code == code);
    } catch (e) {
      return null;
    }
  }

  static String getSymbolByCode(String code) {
    final currency = getCurrencyByCode(code);
    return currency?.symbol ?? '\$';
  }
}
