import 'package:flutter/foundation.dart';

class MyPageIndexProvider with ChangeNotifier {

  int _pageIndex = 0;

  int get pageIndex => _pageIndex;

  void updateIndex(int index) {
    _pageIndex = index;
    notifyListeners();
  }
}