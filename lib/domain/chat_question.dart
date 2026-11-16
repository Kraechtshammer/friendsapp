import '../data/database.dart';

/// "Did you write?" waiting for the user to come back from a messenger
/// (02-design.md §2.3). [intention] is the thought the chat was opened
/// for; without it the question is about writing.
class ChatQuestion {
  const ChatQuestion(this.person, {this.intention});

  final Person person;
  final Intention? intention;
}
