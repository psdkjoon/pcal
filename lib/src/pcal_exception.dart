class PcalException implements Exception {
  const PcalException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class InvalidYearException extends PcalException {
  const InvalidYearException(super.message);
}

class InvalidMonthException extends PcalException {
  const InvalidMonthException(super.message);
}

class InvalidDayException extends PcalException {
  const InvalidDayException(super.message);
}

class InvalidPanjikException extends PcalException {
  const InvalidPanjikException(super.message);
}

class InvalidVishakException extends PcalException {
  const InvalidVishakException(super.message);
}

class InvalidEraException extends PcalException {
  const InvalidEraException(super.message);
}
