import 'package:flutter/foundation.dart';

/// SemVer parse + compare for upgrade policy (docs/app-versioning.md).
///
/// Build metadata (`+…`) is ignored. Pre-release labels after `-` are stripped
/// for policy comparison so `1.2.0-beta` compares as `1.2.0`.
@immutable
class SemVer implements Comparable<SemVer> {
  const SemVer(this.major, this.minor, this.patch);

  final int major;
  final int minor;
  final int patch;

  /// Parses `MAJOR.MINOR.PATCH` (extra segments ignored). Throws [FormatException]
  /// when the core version cannot be parsed.
  factory SemVer.parse(String raw) {
    final core = raw.split('+').first.split('-').first.trim();
    if (core.isEmpty) {
      throw FormatException('Empty SemVer', raw);
    }
    final parts = core.split('.');
    if (parts.isEmpty || parts.any((p) => p.isEmpty)) {
      throw FormatException('Invalid SemVer', raw);
    }
    int parsePart(String part) {
      final n = int.tryParse(part);
      if (n == null || n < 0) {
        throw FormatException('Invalid SemVer segment "$part"', raw);
      }
      return n;
    }

    return SemVer(
      parsePart(parts[0]),
      parts.length > 1 ? parsePart(parts[1]) : 0,
      parts.length > 2 ? parsePart(parts[2]) : 0,
    );
  }

  /// Like [parse] but returns `null` instead of throwing.
  static SemVer? tryParse(String raw) {
    try {
      return SemVer.parse(raw);
    } on FormatException {
      return null;
    }
  }

  @override
  int compareTo(SemVer other) {
    final majorCmp = major.compareTo(other.major);
    if (majorCmp != 0) return majorCmp;
    final minorCmp = minor.compareTo(other.minor);
    if (minorCmp != 0) return minorCmp;
    return patch.compareTo(other.patch);
  }

  bool operator <(SemVer other) => compareTo(other) < 0;
  bool operator <=(SemVer other) => compareTo(other) <= 0;
  bool operator >(SemVer other) => compareTo(other) > 0;
  bool operator >=(SemVer other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemVer &&
          major == other.major &&
          minor == other.minor &&
          patch == other.patch;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}
