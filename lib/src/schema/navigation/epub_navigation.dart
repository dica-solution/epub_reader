import 'package:quiver/core.dart';
import 'epub_navigation_map.dart';


class EpubNavigation {
  EpubNavigationMap? NavMap;

  @override
  int get hashCode {
    var objects = [
      NavMap.hashCode,
    ];
    return hashObjects(objects);
  }

  @override
  bool operator ==(other) {
    var otherAs = other as EpubNavigation?;
    if (otherAs == null) {
      return false;
    }
    return
        NavMap == otherAs.NavMap;
  }
}
