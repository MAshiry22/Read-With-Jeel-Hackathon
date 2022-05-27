import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flip_board/flip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/util/AudioPlayerUtil.dart';
import '../../../data/models/marker.dart';

class ReadWithJeelView extends StatefulWidget {
  const ReadWithJeelView({Key? key}) : super(key: key);

  @override
  State<ReadWithJeelView> createState() => _ReadWithJeelState();
}

class _ReadWithJeelState extends State<ReadWithJeelView> {
  final _flipController = StreamController<int>.broadcast();
  int _nextFlipValue = 0;
  AxisDirection direction = AxisDirection.left;
  bool paused = false;

  @override
  void dispose() {
    _flipController.close();
    streamController?.close();
    AudioPlayerUtil.stop();
    super.dispose();
  }

  final list = [
    {
      'image': 'assets/1.png',
      'text': 'فِي عُشٍّ صَغيرٍ يسْكُنُ عُصفُورانِ سعيدَانِ..',
    },
    {
      'image': 'assets/2.png',
      'text':
          'ولكنَّ سعادَتَهُمَا لمْ تستمِرَّ طويلًا؛ فقَدْ واجهَتْهُمَا مشكلةٌ كبيرَةٌ.',
    },
    {
      'image': 'assets/3.png',
      'text':
          'حيثُ بَنَى بعضُ البَشَرِ بيتًا مجاوِرًا للعُشِّ، وهذَا البيتُ له مِدخنَةٌ تُخْرِجُ دُخَانًا سَامًّا. "كحكح مَاهَذَا الدُّخَانُ؟".',
    },
    {
      'image': 'assets/4.png',
      'text':
          '''اكتَشَفَ العُصفُورَانِ أنَّ مصدَرَ الدُّخَانِ هُوَ مِدخَنَةُ البيتِ الْمُجَاوِرِ، فَقَرَّرَا أن يتصرَّفَا بإيجابيَّةٍ، ويطرُقَا بَابَ الجيرَانِ بِكُلِّ أدَبٍ.''',
    },
    /*{
      'image': 'assets/5.png',
      'text':
          '''قَالَ أحَدُ العصفورَينِ للبنْتِ لَمَّا فتحَتِ البَابَ: مرحبًا بجارَتِنَا، نأسَفُ للإزْعَاجِ.. لكِنَّنَا نُوَاجِهُ صعُوبَةً فِي التنَفُّسِ بسبَبِ دُخَانِ المدْخَنَةِ. فاعتَذَرَتِ البنتُ فِي الحالِ، ووعدَتْهُمَا أنَّهَا ستخْبِرُ والدَهَا، للبحْثِ عَنْ حَلٍّ لهذِهِ المشكِلَةِ في أقرَبِ وَقْتٍ.''',
    },
    {
      'image': 'assets/6.png',
      'text':
          'قَالَ أحَدُ العصفورَينِ للبنْتِ لَمَّا فتحَتِ البَابَ:وبعْدَ مُرورِ وقتٍ قصيرٍ وَضَعَ والدُ البنْتِ فوْقَ المدْخَنَةِ أداةً لتنقِيَةِ الهَوَاءِ؛ حتَّى لَا يتأَذَّى العُصفُورَانِ، فالْجَارُ لِلْجَارِ..',
    },
    {
      'image': 'assets/7.png',
      'text':
          'وعادَ العُصفورَانِ سعيدَيْنِ.. بفضْلِ استجَابَةِ الجِيرَانِ. فالهَوَاءُ النظِيفُ نعمةٌ لا تُقَدَّرُ بأغلَى الأثْمَانِ.',
    },*/
  ];

  int length = 0;
  int markerIndex = 0;
  Duration soundDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    streamController = StreamController<int>.broadcast();
    readJson().then((_) {
      StreamSubscription? listener;
      listener = AudioPlayerUtil.player2.fixedPlayer?.onDurationChanged
          .listen((duration) {
        soundDuration = duration;
        markWords();
      });
      AudioPlayerUtil.play('sound.mp3', onFinish: () {
        listener?.cancel();
      });
      streamController!.sink.add(markerIndex);
    });
  }

  StreamController<int>? streamController;

  final List<Marker> markers = [];
  Duration playedDuration = Duration.zero;

  Future<void> markWords() async {
    if (markerIndex == markers.length) return;
    AudioPlayerUtil.player2.fixedPlayer?.seek(markers[markerIndex].start);
    var wordDuration = markerIndex == markers.length - 1
        ? soundDuration - markers[markerIndex].start
        : markers[markerIndex + 1].start - markers[markerIndex].start;
    if ((markerIndex - length) ==
        list[_nextFlipValue]['text']!.split(" ").length) {
      _flip();
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    if (AudioPlayerUtil.player2.fixedPlayer?.state == PlayerState.PAUSED &&
        mounted) {
      streamController!.sink.add(markerIndex);
      AudioPlayerUtil.player2.fixedPlayer?.resume();
    }
    Future.delayed(wordDuration).then((_) {
      if (mounted) {
        AudioPlayerUtil.player2.fixedPlayer?.pause();

        markerIndex++;
        Future.delayed(const Duration(milliseconds: 10), () {
          if (mounted && !paused) {
            markWords();
          }
        });
      }
    });
  }

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/markers2.json');
    final data = await json.decode(response);
    markers.clear();
    for (var e in (data as List)) {
      markers.add(Marker.fromJson(e as Map<String, dynamic>));
    }
    markers.sort((a, b) => a.start.compareTo(b.start));
  }

  @override
  Widget build(BuildContext context) {
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
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Image.asset(
                    'assets/back_button.png',
                    height: 70,
                    width: 70,
                  ),
                ),
              ),
              _flipWheel(),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    if (paused) {
                      AudioPlayerUtil.player2.fixedPlayer?.resume();
                      paused = false;
                      markWords();
                    } else {
                      AudioPlayerUtil.player2.fixedPlayer?.pause();
                      paused = true;
                    }
                  },
                  child: Image.asset(
                    'assets/microphone.png',
                    fit: BoxFit.fill,
                    height: 70,
                    width: 70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _flipWheel() => _wheel(
        _flipWidget,
        _nextPage,
        _previousPage,
      );

  Widget _wheel(
    Widget Function(AxisDirection) _widget,
    Widget _nextButton,
    Widget _previousButton,
  ) =>
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _widget(direction),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _previousButton,
                  Expanded(
                    child: StreamBuilder(
                      stream: _flipController.stream,
                      builder: (context, snapshot) {
                        return Row(
                          children: [
                            Expanded(
                              child: Container(
                                alignment: Alignment.topCenter,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white, width: 3),
                                    borderRadius: BorderRadius.circular(10)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    minHeight: 10,
                                    value: (((snapshot.data ?? 0) as int) + 1) /
                                        list.length,
                                    backgroundColor: Colors.grey,
                                    color: const Color(0xffa53a9a),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                                'Pages ${(((snapshot.data ?? 0) as int) + 1)} / ${list.length}'),
                          ],
                        );
                      },
                      initialData: 0,
                    ),
                  ),
                  _nextButton,
                ],
              ),
            ),
          ],
        ),
      );

  Widget get _nextPage => Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: GestureDetector(
          onTap: _flip,
          child: Image.asset(
            'assets/next.png',
            width: 50,
            height: 50,
          ),
        ),
      );

  Widget get _previousPage => Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: GestureDetector(
          onTap: _flipRemove,
          child: Image.asset(
            'assets/previous.png',
            width: 50,
            height: 50,
          ),
        ),
      );

  Widget _flipWidget(AxisDirection direction) => FlipWidget(
        flipType: FlipType.middleFlip,
        itemStream: _flipController.stream,
        itemBuilder: _itemBuilder,
        initialValue: _nextFlipValue,
        flipDirection: direction,
        flipCurve: direction == AxisDirection.down
            ? FlipWidget.bounceFastFlip
            : FlipWidget.defaultFlip,
        flipDuration: const Duration(milliseconds: 1000),
        perspectiveEffect: 0.003,
        hingeWidth: 0.00,
        hingeLength: 0.0,
        // hingeColor: Colors.black,
      );

  Widget _itemBuilder(BuildContext context, int? value) {
    List split = list[value ?? 0]['text']!.split(" ");
    Size _size = MediaQuery.of(context).size;
    return Container(
      width: 0.81 * _size.width,
      height: 0.7664 * _size.height,
      alignment: Alignment.center,
      child: Row(
        children: [
          Container(
            width: 0.81 * _size.width / 2,
            height: 0.7664 * _size.height,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              image: DecorationImage(
                image: AssetImage(list[value ?? 0]['image']!),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Container(
            width: 0.81 * _size.width / 2,
            height: 0.7664 * _size.height,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: StreamBuilder<int>(
                stream: streamController!.stream,
                builder: (context, snapshot) {
                  return RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      children: [
                        for (int i = 0; i < split.length; i++)
                          TextSpan(
                            text: split[i] + " ",
                            style: TextStyle(
                                color: snapshot.data != null &&
                                        i == (snapshot.data! - length)
                                    ? Colors.blue
                                    : Colors.black),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _flip() => _nextFlipValue < list.length - 1
      ? {
          if (direction == AxisDirection.right)
            {
              setState(() => direction = AxisDirection.left),
            },
          length += list[_nextFlipValue]['text']!.split(' ').length,
          markerIndex = length,
          _flipController.add(++_nextFlipValue % list.length)
        }
      : null;

  void _flipRemove() => _nextFlipValue > 0
      ? {
          if (direction == AxisDirection.left)
            {
              setState(() => direction = AxisDirection.right),
            },
          length -= list[_nextFlipValue]['text']!.split(' ').length,
          markerIndex = length,
          _flipController.add(--_nextFlipValue % list.length)
        }
      : null;
}
