/// drift stores whole seconds; cut here so a returned row equals the
/// stored one.
DateTime wholeSeconds(DateTime t) => t.subtract(
  Duration(milliseconds: t.millisecond, microseconds: t.microsecond),
);
