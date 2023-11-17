extension StringExtension on String {
  String replaceAllCapitalizedAccent() {
    return replaceAll("É", "E")
        .replaceAll("È", "E")
        .replaceAll("À", "A")
        .replaceAll("Ù", "U")
        .replaceAll("Ê", "E")
        .replaceAll("Â", "A")
        .replaceAll("Û", "U");
  }
}
