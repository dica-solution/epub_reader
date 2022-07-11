import 'dart:async';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import '../entities/epub_schema.dart';
import '../readers/chapter_reader.dart';
import 'epub_chapter_ref.dart';

class EpubBookRef {
  Archive? _epubArchive;
  EpubSchema? Schema;
  EpubBookRef(Archive epubArchive) {
    _epubArchive = epubArchive;
  }

  @override
  int get hashCode {
    var objects = [
      Schema.hashCode,
    ];
    return hashObjects(objects);
  }

  @override
  bool operator ==(other) {
    if (!(other is EpubBookRef)) {
      return false;
    }

    return
        Schema == other.Schema;
  }

  Archive? EpubArchive() {
    return _epubArchive;
  }

  Future<List<EpubChapterRef>> getChapters() async {
    var chapters = await compute(ChapterReader.getChapters, this);
    return chapters;
  }
}
