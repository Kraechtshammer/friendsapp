import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;

import '../data/database.dart' show Person;
import '../platform/contacts.dart' show PhoneContact;
import 'birthdays.dart';
import 'phone_number.dart';

/// What a phone contact would change on a linked person (02-design.md §8,
/// refresh from contacts). Name, number and birthday are copied once at
/// import; a refresh looks again, and the user decides.
///
/// A field is only proposed when the contact has a value and it differs: an
/// empty field in the address book never erases what the user keeps. The
/// picture is proposed only when the person has none yet.
class ContactDiff {
  const ContactDiff(
    this.person, {
    this.name,
    this.phone,
    this.birthday,
    this.photo,
  });

  final Person person;

  /// The contact's value where it differs from the person's; else null.
  final String? name;
  final String? phone;
  final Birthday? birthday;

  /// The contact's picture (raw bytes), when the person has none.
  final Uint8List? photo;

  bool get isEmpty =>
      name == null && phone == null && birthday == null && photo == null;

  /// The person with the proposed values applied. The picture is stored by
  /// the caller (`applyContactDiff`) and passed as [photoName].
  Person apply({String? photoName}) {
    final b = birthday;
    return person.copyWith(
      name: name ?? person.name,
      phone: phone == null ? const Value.absent() : Value(phone),
      birthdayMonth: b == null ? const Value.absent() : Value(b.month),
      birthdayDay: b == null ? const Value.absent() : Value(b.day),
      birthdayYear: b == null ? const Value.absent() : Value(b.year),
      photo: photoName == null ? const Value.absent() : Value(photoName),
    );
  }
}

/// Compares [person] with the [contact] it was imported from. Pure.
ContactDiff compareWithContact(Person person, PhoneContact contact) {
  final name = contact.name.trim();
  final newName = name.isNotEmpty && name != person.name ? name : null;

  // The person's number is stored in the normalised form; the contact may
  // have several, and any of them being the same counts as equal.
  final numbers = [for (final p in contact.phones) ?normalisePhone(p)];
  final newPhone = numbers.isNotEmpty && !numbers.contains(person.phone)
      ? numbers.first
      : null;

  Birthday? newBirthday;
  final m = contact.birthdayMonth, d = contact.birthdayDay;
  if (m != null && d != null) {
    final theirs = Birthday(m, d, contact.birthdayYear);
    final same =
        person.birthdayMonth == m &&
        person.birthdayDay == d &&
        // An unknown year in the contact keeps the year the user has.
        (theirs.year == null || theirs.year == person.birthdayYear);
    if (!same && theirs.isValid) newBirthday = theirs;
  }
  return ContactDiff(
    person,
    name: newName,
    phone: newPhone,
    birthday: newBirthday,
    photo: person.photo == null ? contact.photo : null,
  );
}

/// The differences of every person linked to a contact in [contacts] (by
/// contact id), in the order of [people]. People without a link, whose
/// contact is gone, or who are up to date, are left out.
List<ContactDiff> compareAll(
  List<Person> people,
  Map<String, PhoneContact> contacts,
) => [
  for (final p in people)
    if (p.contactId != null && contacts[p.contactId] != null)
      if (compareWithContact(p, contacts[p.contactId]!) case final diff
          when !diff.isEmpty)
        diff,
];
