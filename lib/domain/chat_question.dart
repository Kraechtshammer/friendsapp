import '../data/database.dart';

/// "Did you write?" waiting for the user to come back from a messenger
/// (02-design.md §2.3). [intention] is the thought the chat was opened
/// for; without it the question is about writing. With [birthday] the
/// chat was opened from a birthday pick and the question is "Did you
/// congratulate?".
class ChatQuestion {
  const ChatQuestion(this.person, {this.intention, this.birthday = false});

  final Person person;
  final Intention? intention;
  final bool birthday;
}
