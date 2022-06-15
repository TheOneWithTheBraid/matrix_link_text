import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;

const icaanUrl =
    'https://www.iana.org/assignments/uri-schemes/uri-schemes-1.csv';
const outFile = './lib/src/schemes.dart';

void main() async {
  final res = utf8.decode((await http.get(Uri.parse(icaanUrl))).bodyBytes);
  final file = await File(outFile).open(mode: FileMode.write);
  await file.writeString('const allSchemes = {\n');
  for (final row in res.split('\n')) {
    final scheme = row.split(',').first.trim().toLowerCase();
    if (!RegExp(r'^[\da-z]+$').hasMatch(scheme) || scheme.isEmpty) {
      continue;
    }

    await file.writeString('  "$scheme",\n');
  }
  await file.writeString('};\n');
  await file.close();
}
