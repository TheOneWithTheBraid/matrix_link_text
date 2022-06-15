import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:punycode/punycode.dart';

const icaanUrl = 'https://data.iana.org/TLD/tlds-alpha-by-domain.txt';
const outFile = './lib/src/tlds.dart';

void main() async {
  final res = utf8.decode((await http.get(Uri.parse(icaanUrl))).bodyBytes);
  final file = await File(outFile).open(mode: FileMode.write);
  await file.writeString('const allTlds = {\n');
  for (var tld in res.split('\n')) {
    tld = tld.trim().toLowerCase();
    if (tld.startsWith('#') || tld.isEmpty) {
      continue;
    }
    if (tld.startsWith('xn--')) {
      // decode unicode TLD
      await file.writeString('  "${punycodeDecode(tld.substring(4))}",\n');
    }
    await file.writeString('  "$tld",\n');
  }
  await file.writeString('};\n');
  await file.close();
}
