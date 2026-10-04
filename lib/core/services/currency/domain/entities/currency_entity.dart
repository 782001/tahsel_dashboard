class CurrencyEntity {
  final String code;
  final String arabicName;
  final String englishName;
  final String arabicSymbol;
  final String englishSymbol;

  const CurrencyEntity({
    required this.code,
    required this.arabicName,
    required this.englishName,
    required this.arabicSymbol,
    required this.englishSymbol,
  });

  /// Default currency for Tahsel: Egyptian Pound (EGP)
  static const CurrencyEntity defaultCurrency = CurrencyEntity(
    code: 'EGP',
    arabicName: 'جنيه مصري',
    englishName: 'Egyptian Pound',
    arabicSymbol: 'ج.م',
    englishSymbol: 'EGP',
  );

  /// Dynamic localized display name based on app language code
  String getName([String langCode = 'ar']) {
    return langCode == 'ar' ? arabicName : englishName;
  }

  /// Dynamic localized symbol based on app language code
  String getSymbol([String langCode = 'ar']) {
    return langCode == 'ar' ? arabicSymbol : englishSymbol;
  }

  Map<String, dynamic> toMap() => {
        'code': code,
        'arabicName': arabicName,
        'englishName': englishName,
        'arabicSymbol': arabicSymbol,
        'englishSymbol': englishSymbol,
      };

  factory CurrencyEntity.fromMap(Map<String, dynamic> map) {
    return CurrencyEntity(
      code: map['code'] as String? ?? 'EGP',
      arabicName: map['arabicName'] as String? ?? 'جنيه مصري',
      englishName: map['englishName'] as String? ?? 'Egyptian Pound',
      arabicSymbol: map['arabicSymbol'] as String? ?? 'ج.م',
      englishSymbol: map['englishSymbol'] as String? ?? 'EGP',
    );
  }

  CurrencyEntity copyWith({
    String? code,
    String? arabicName,
    String? englishName,
    String? arabicSymbol,
    String? englishSymbol,
  }) {
    return CurrencyEntity(
      code: code ?? this.code,
      arabicName: arabicName ?? this.arabicName,
      englishName: englishName ?? this.englishName,
      arabicSymbol: arabicSymbol ?? this.arabicSymbol,
      englishSymbol: englishSymbol ?? this.englishSymbol,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyEntity &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$code ($arabicSymbol)';
}
