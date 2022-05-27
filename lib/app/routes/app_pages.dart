import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/read_with_jeel/bindings/read_with_jeel_binding.dart';
import '../modules/read_with_jeel/views/read_with_jeel_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.READ_WITH_JEEL,
      page: () => ReadWithJeelView(),
      binding: ReadWithJeelBinding(),
    ),
  ];
}
