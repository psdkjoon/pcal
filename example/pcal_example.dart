import 'dart:io';

import '../lib/pcal.dart';

void main() {
  final gregorian = GregorianDate(2026, 10, 10);

  stdout.writeln('Gregorian: $gregorian ${gregorian.weekdayName}');

  final jalali = gregorian.toJalali();
  stdout.writeln(
    'Jalali:    $jalali ${jalali.monthName} ${jalali.weekdayName}',
  );

  final deylami = gregorian.toDeylami();
  stdout.writeln(
    'Deylami:   $deylami ${deylami.monthName} ${deylami.weekdayName}',
  );

  final japanese = gregorian.toJapanese();
  stdout.writeln('Japanese:  $japanese ${japanese.toKanjiString()}');

  final vishak = DeylamiDate(1598, 0, 0);
  stdout.writeln(
    'Vishak ${vishak.toGregorian()} is ${vishak.toJalali()} in Jalali',
  );

  final fromJalali = JalaliDate(1403, 1, 1).toGregorian();
  stdout.writeln('Nowruz 1403 fell on $fromJalali');

  final reiwa = JapaneseDate(JapaneseEra.reiwa, 1, 5, 1);
  stdout.writeln('${reiwa.toKanjiString()} is ${reiwa.toGregorian()}');

  try {
    GregorianDate(2023, 2, 29);
  } on InvalidDayException catch (error) {
    stdout.writeln(error);
  }
}
