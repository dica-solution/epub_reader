
import '../schema/navigation/epub_navigation.dart';

class EpubSchema {
  EpubNavigation? Navigation;


  @override
  bool operator ==(other) {
    if (!(other is EpubSchema)) {
      return false;
    }

    return 
        Navigation == other.Navigation;
  }
}
