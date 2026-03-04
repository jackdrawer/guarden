import 'dart:convert';

class TextSanitizer {
  static final RegExp _mojibakeMarker = RegExp(r'[\u00C2-\u00C5]');
  static final RegExp _duplicatedApostrophe = RegExp(r"^(.+?)'\1'?$");

  static String normalizeDisplayText(String input) {
    var output = input.trim();
    if (output.isEmpty) return output;

    output = _repairMojibake(output);
    output = _removeDuplicatedChunks(output);
    output = output.replaceAll(RegExp(r'\s+'), ' ').trim();
    return output;
  }

  static String _repairMojibake(String input) {
    if (!_mojibakeMarker.hasMatch(input)) return input;
    try {
      return utf8.decode(latin1.encode(input), allowMalformed: true);
    } catch (_) {
      return input;
    }
  }

  static String _removeDuplicatedChunks(String input) {
    final byApostrophe = _duplicatedApostrophe.firstMatch(input);
    if (byApostrophe != null) {
      return byApostrophe.group(1) ?? input;
    }

    if (input.length.isEven) {
      final half = input.length ~/ 2;
      final left = input.substring(0, half);
      final right = input.substring(half);
      if (left == right) {
        return left;
      }
    }

    return input;
  }
}
