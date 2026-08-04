import 'dart:convert';
import 'dart:io';

/// Synchronous fixture load from `test/fixtures/`.
Map<String, dynamic> readFixtureSync(String name) {
  final file = _fixtureFile(name);
  return Map<String, dynamic>.from(
    jsonDecode(file.readAsStringSync()) as Map,
  );
}

File _fixtureFile(String name) {
  final candidates = [
    File('test/fixtures/$name'),
    File('test/fixtures/documents/$name'),
    File('test/fixtures/chats/$name'),
    File('test/fixtures/exports/$name'),
    File('fixtures/$name'),
    File('fixtures/documents/$name'),
    File('fixtures/chats/$name'),
    File('fixtures/exports/$name'),
  ];
  for (final f in candidates) {
    if (f.existsSync()) return f;
  }
  throw StateError('Fixture not found: $name');
}
