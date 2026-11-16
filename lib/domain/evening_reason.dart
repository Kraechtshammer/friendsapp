import '../data/database.dart';
import 'owed_reply.dart';
import 'reconnect_week.dart';

/// The reason the evening question names (02-design.md §8, review of
/// 2026-11-16, point 1). There is one evening notification per day; it
/// names its top reason when there is one, otherwise it asks the general
/// question. Birthdays have their own notifications and are no reason here.
///
/// The notifications are scheduled ahead, so the reason of a later day is
/// predicted from what is known now ([eveningDays]). Pure rules; the
/// current time is a parameter.

/// How many days ahead, from today, get a notification of their own with
/// that day's reason. After them the general weekly question takes over.
const eveningOneOffDays = 21;

/// Why the evening question comes on a day.
sealed class EveningReason {
  const EveningReason();
}

/// No particular reason: "Got ten minutes for someone today?".
class EveningGeneral extends EveningReason {
  const EveningGeneral();

  @override
  bool operator ==(Object other) => other is EveningGeneral;

  @override
  int get hashCode => 0;
}

/// [person] is owed a reply, the longest of everyone: "Still owe NAME a
/// reply?".
class EveningOwedReply extends EveningReason {
  const EveningOwedReply(this.person);

  final Person person;

  @override
  bool operator ==(Object other) =>
      other is EveningOwedReply &&
      other.person.id == person.id &&
      other.person.name == person.name;

  @override
  int get hashCode => Object.hash(1, person.id, person.name);
}

/// [person] is the reconnect person of the current span and the user has
/// not been in touch in it: "This month: NAME. Got ten minutes?".
class EveningReconnect extends EveningReason {
  const EveningReconnect(this.person, this.span);

  final Person person;
  final ReconnectSpan span;

  @override
  bool operator ==(Object other) =>
      other is EveningReconnect &&
      other.person.id == person.id &&
      other.person.name == person.name &&
      other.span == span;

  @override
  int get hashCode => Object.hash(2, person.id, person.name, span);
}

/// What is known now and decides the reason of a day.
class EveningInputs {
  const EveningInputs({
    this.people = const [],
    this.events = const [],
    this.replyWaitDays = defaultReplyWaitDays,
    this.listenerOn = true,
    this.reconnectId,
    this.reconnectStart,
    this.reconnectSpan = ReconnectSpan.defaultSpan,
  });

  final List<Person> people;
  final Iterable<ContactEvent> events;
  final int replyWaitDays;
  final bool listenerOn;
  final String? reconnectId;
  final DateTime? reconnectStart;
  final ReconnectSpan reconnectSpan;
}

/// The reason of the evening question that comes at [at], predicted from
/// [inputs]: first the person owed a reply longest at [at] ([owedReplies]:
/// an incoming message not yet owed now is owed later once the waiting
/// time has passed; one answered or cleared is not owed), else the
/// reconnect person if [at] lies in the span and the user has not been in
/// touch in it ([reconnectState]), else the general question.
EveningReason eveningReasonAt(DateTime at, EveningInputs inputs) {
  final owed = owedReplies(
    inputs.people,
    inputs.events,
    now: at,
    waitDays: inputs.replyWaitDays,
    listenerOn: inputs.listenerOn,
  );
  if (owed.isNotEmpty) return EveningOwedReply(owed.first.person);
  final state = reconnectState(
    people: inputs.people,
    events: inputs.events,
    chosenId: inputs.reconnectId,
    chosenStart: inputs.reconnectStart,
    span: inputs.reconnectSpan,
    today: at,
  );
  if (state is ReconnectChosen) {
    return EveningReconnect(state.person, inputs.reconnectSpan);
  }
  return const EveningGeneral();
}

/// The texts of the evening question in the user's language.
class EveningTexts {
  const EveningTexts({
    required this.general,
    required this.owedReply,
    required this.reconnect,
  });

  /// "Got ten minutes for someone today?"
  final String general;

  /// "Still owe NAME a reply?", with the first name.
  final String Function(String name) owedReply;

  /// "This month: NAME. Got ten minutes?", with the span and first name.
  final String Function(ReconnectSpan span, String name) reconnect;
}

/// One day's evening notification.
class EveningDay {
  const EveningDay({
    required this.at,
    required this.reason,
    required this.title,
    this.body,
  });

  /// Local time it comes.
  final DateTime at;
  final EveningReason reason;
  final String title;
  final String? body;

  @override
  bool operator ==(Object other) =>
      other is EveningDay &&
      other.at == at &&
      other.reason == reason &&
      other.title == title &&
      other.body == body;

  @override
  int get hashCode => Object.hash(at, reason, title, body);

  @override
  String toString() => 'EveningDay($at, $title)';
}

/// The evening notifications of the next [count] days, starting today
/// (the local day of [now]), at [minute] minutes after midnight on the
/// allowed [weekdays] ([eveningWeekdays]; empty when the question is off).
/// Times not after [now] are left out. Each day gets the reason predicted
/// by [eveningReasonAt] and its title from [texts]; names are first names
/// ([nameOf]).
List<EveningDay> eveningDays({
  required DateTime now,
  required List<int> weekdays,
  required int minute,
  required EveningInputs inputs,
  required EveningTexts texts,
  required String Function(String name) nameOf,
  int count = eveningOneOffDays,
}) => [
  for (var i = 0; i < count; i++)
    if (DateTime(now.year, now.month, now.day + i, minute ~/ 60, minute % 60)
        case final at when weekdays.contains(at.weekday) && at.isAfter(now))
      _day(at, eveningReasonAt(at, inputs), texts, nameOf),
];

EveningDay _day(
  DateTime at,
  EveningReason reason,
  EveningTexts texts,
  String Function(String name) nameOf,
) => EveningDay(
  at: at,
  reason: reason,
  title: switch (reason) {
    EveningGeneral() => texts.general,
    EveningOwedReply(:final person) => texts.owedReply(nameOf(person.name)),
    EveningReconnect(:final person, :final span) => texts.reconnect(
      span,
      nameOf(person.name),
    ),
  },
);
