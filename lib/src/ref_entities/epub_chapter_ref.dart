import 'dart:async';

import 'package:quiver/collection.dart' as collections;
import 'package:quiver/core.dart';


class EpubChapterRef {

  String? Title;
  String? ContentFileName;
  String? Anchor;
  List<EpubChapterRef>? SubChapters;

  @override
  int get hashCode {
    var objects = [
      Title.hashCode,
      ContentFileName.hashCode,
      Anchor.hashCode,
      ...SubChapters?.map((subChapter) => subChapter.hashCode) ?? [0],
    ];
    return hashObjects(objects);
  }

  @override
  bool operator ==(other) {
    if (!(other is EpubChapterRef)) {
      return false;
    }
    return Title == other.Title &&
        ContentFileName == other.ContentFileName &&
        Anchor == other.Anchor &&
        collections.listsEqual(SubChapters, other.SubChapters);
  }

  @override
  String toString() {
    return 'Title: $Title, Subchapter count: ${SubChapters!.length}';
  }
}
