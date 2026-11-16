/// The first word of a name, for tight places ("Tom Berger" is "Tom").
String firstNameOf(String name) {
  final words = name.trim().split(RegExp(r'\s+'));
  return words.first;
}
