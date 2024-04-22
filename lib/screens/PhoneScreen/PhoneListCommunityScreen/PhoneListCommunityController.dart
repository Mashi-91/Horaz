import 'package:get/get.dart';

class PhoneListCommunityController extends GetxController {
  RxList<String> selectedTags = <String>[].obs;

  void selectTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
    update();
  }
}