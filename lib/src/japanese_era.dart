import 'gregorian_date.dart';
import 'pcal_exception.dart';

/// An imperial era (nengō) of the Japanese calendar.
///
/// Each era starts on a fixed Gregorian date and lasts until the day before the
/// next era starts. The last era, [reiwa], has no end.
///
/// ```dart
/// final era = JapaneseEra.fromJulianDayNumber(
///   GregorianDate(2026, 10, 10).julianDayNumber,
/// );
/// print(era.romajiName); // Reiwa
/// print(era.kanjiName); // 令和
/// ```
enum JapaneseEra {
  /// The Meiji era (明治), which started on 1868-01-25.
  meiji('Meiji', '明治', 'M', 1868, 1, 25),
  /// The Taishō era (大正), which started on 1912-07-30.
  taisho('Taisho', '大正', 'T', 1912, 7, 30),
  /// The Shōwa era (昭和), which started on 1926-12-25.
  showa('Showa', '昭和', 'S', 1926, 12, 25),
  /// The Heisei era (平成), which started on 1989-01-08.
  heisei('Heisei', '平成', 'H', 1989, 1, 8),
  /// The Reiwa era (令和), which started on 2019-05-01.
  reiwa('Reiwa', '令和', 'R', 2019, 5, 1);

  const JapaneseEra(
    this.romajiName,
    this.kanjiName,
    this.abbreviation,
    this.startYear,
    this.startMonth,
    this.startDay,
  );

  /// The name of the era in Latin letters, such as `Reiwa`.
  final String romajiName;

  /// The name of the era in kanji, such as `令和`.
  final String kanjiName;

  /// The one-letter abbreviation of the era, such as `R` for Reiwa.
  final String abbreviation;

  /// The Gregorian year in which the era starts.
  final int startYear;

  /// The Gregorian month, from `1` to `12`, in which the era starts.
  final int startMonth;

  /// The day of [startMonth] on which the era starts.
  final int startDay;

  /// The Julian day number of the first day of the era.
  int get startJulianDayNumber =>
      GregorianDate(startYear, startMonth, startDay).julianDayNumber;

  /// The Julian day number of the last day of the era.
  ///
  /// This is the day before the next era starts. For [reiwa], which is still
  /// current, it is the last day supported by [GregorianDate].
  int get endJulianDayNumber => this == reiwa
      ? GregorianDate.maxJulianDayNumber
      : values[index + 1].startJulianDayNumber - 1;

  /// Returns the era that contains the day with the given [julianDayNumber].
  ///
  /// Throws an [InvalidEraException] if the day is before the start of [meiji].
  static JapaneseEra fromJulianDayNumber(int julianDayNumber) {
    for (final era in values.reversed) {
      if (julianDayNumber >= era.startJulianDayNumber) {
        return era;
      }
    }
    throw InvalidEraException(
      'Julian day number $julianDayNumber is before the first supported era.',
    );
  }
}
