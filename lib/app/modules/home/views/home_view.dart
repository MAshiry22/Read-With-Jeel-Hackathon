import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);

    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      decoration: const BoxDecoration(
        color: Color(0xFFfcdfae),
        image: DecorationImage(
          image: AssetImage('assets/screen_bg.png'),
          fit: BoxFit.fitWidth,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'المكتبة',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
              ),
              Wrap(
                textDirection: TextDirection.rtl,
                children: [
                  InkWell(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/book.png',
                          scale: 1.9,
                          width: 100,
                          height: 150,
                        ),
                        const Text('من فضلك')
                      ],
                    ),
                    onTap: () {
                      Get.toNamed(Routes.READ_WITH_JEEL);
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
