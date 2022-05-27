import 'package:get/get.dart';

import '../controllers/read_with_jeel_controller.dart';

class ReadWithJeelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReadWithJeelController>(
      () => ReadWithJeelController(),
    );
  }
}
