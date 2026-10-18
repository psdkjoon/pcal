import 'gregorian_date.dart';
import 'pcal_exception.dart';

enum JapaneseEra {
  meiji('Meiji', '明治', 'M', 1868, 1, 25),
  taisho('Taisho', '大正', 'T', 1912, 7, 30),
  showa('Showa', '昭和', 'S', 1926, 12, 25),
  heisei('Heisei', '平成', 'H', 1989, 1, 8),
  reiwa('Reiwa', '令和', 'R', 2019, 5, 1);

  const JapaneseEra(
    this.romajiName,
    this.kanjiName,
    this.abbreviation,
    this.startYear,
    this.startMonth,
    this.startDay,
  );

  final String romajiName;

  final String kanjiName;

  final String abbreviation;

  final int startYear;

  final int startMonth;

  final int startDay;

  int get startJulianDayNumber =>
      GregorianDate(startYear, startMonth, startDay).julianDayNumber;

  int get endJulianDayNumber => this == reiwa
      ? GregorianDate.maxJulianDayNumber
      : values[index + 1].startJulianDayNumber - 1;

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
