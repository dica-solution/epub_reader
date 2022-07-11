import 'dart:async';

import 'package:archive/archive.dart';

import '../entities/epub_schema.dart';
import 'navigation_reader.dart';

class SchemaReader {
  static Future<EpubSchema> readSchema(Archive epubArchive) async {
    var result = EpubSchema();
    var navigation = await NavigationReader.readNavigation(
      epubArchive,
    );
    result.Navigation = navigation;
    return result;
  }
}
