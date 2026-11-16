/// The part of the day the Home title greets (02-design.md §2.1).
enum Greeting { morning, day, evening }

/// Morning before 11:00, day until 17:00, evening after.
Greeting greetingAt(DateTime time) => switch (time.hour) {
  < 11 => Greeting.morning,
  < 17 => Greeting.day,
  _ => Greeting.evening,
};
