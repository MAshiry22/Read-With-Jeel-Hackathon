import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';

class AudioPlayerUtil {
  //For asset audios using audiocache is a must instead of audioplayer directly
  static AudioCache backgroundMusicPlayer =
      AudioCache(fixedPlayer: AudioPlayer());
  static AudioCache player2 = AudioCache(fixedPlayer: AudioPlayer());

  static bool _isInVideo = false;
  static bool _isMusicEnabled = true;
  static bool _muteBackgroundMusic = false;
  static bool _isVolume0 = false;

  static playBackgroundMusic({required isAcapella}) {
    print('play audio');
    //player.loop('english.mp3');
    String audio = isAcapella
        ? 'audios/backgroundacapella.mp3'
        : 'audios/backgroundmusic.mp3';
    backgroundMusicPlayer.loop(audio, volume: 0.5);
    _isVolume0 = false;
  }

  static void muteOrUnmuteBackgroundMusic() {
    _muteBackgroundMusic = !_muteBackgroundMusic;
    if (_muteBackgroundMusic) {
      stopBackgroundMusic();
    } else {
      checkIfShouldPlayBackgroundMusic();
    }
  }

  static checkIfShouldPlayBackgroundMusic() async {
    if (_isInVideo || _muteBackgroundMusic) {
      stopBackgroundMusic();
    } else {
      if (_isMusicEnabled) {
        playBackgroundMusic(isAcapella: false);
      } else {
        playBackgroundMusic(isAcapella: true);
      }
    }
  }

  static stopBackgroundMusic() async {
    if (Platform.isIOS) {
      muteMusic();
    } else {
      print('stop audio');
      await backgroundMusicPlayer.fixedPlayer?.stop();
    }
  }

  static muteMusic() async {
    print('Muted');
    await backgroundMusicPlayer.fixedPlayer?.setVolume(0);
    _isVolume0 = true;
  }

  static resumeBackgroundMusic() async {
    if (_isVolume0) {
      await backgroundMusicPlayer.fixedPlayer?.setVolume(0.3);
      _isVolume0 = false;
    }
    backgroundMusicPlayer.fixedPlayer?.resume();
  }

  static pauseBackgroundMusic() {
    if (Platform.isIOS) {
      muteMusic();
    } else {
      backgroundMusicPlayer.fixedPlayer?.pause();
    }
  }

  static void enterVideoMode() {
    print('enter video audio');
    _isInVideo = true;
    stopBackgroundMusic();
  }

  static void exitVideoMode() {
    print('exit video audio');
    _isInVideo = false;
    checkIfShouldPlayBackgroundMusic();
  }

  static Future<Uri> loadAsset(String fileName) async {
    //Use AudioCache to load assets into files
    final uri = await backgroundMusicPlayer.load(fileName);
    return uri;
  }

  static play(String fileName, {Function()? onFinish}) async {
    StreamSubscription? listener;

    player2.play(fileName);
    listener = player2.fixedPlayer?.onPlayerCompletion.listen((v) {
      if (onFinish != null) onFinish();
      listener?.cancel();
    });
  }

  static stop() {
    if (Platform.isIOS) {
      player2.fixedPlayer?.setVolume(0.0);
    } else {
      player2.fixedPlayer?.stop();
    }
  }

  static playUrl(String audioUrl, {Function()? onFinish}) async {
    player2.fixedPlayer?.play(audioUrl);
    StreamSubscription? listener;
    listener = player2.fixedPlayer?.onPlayerCompletion.listen((v) {
      if (onFinish != null) onFinish();
      listener?.cancel();
    });
  }

  static playCacheUrl(String audioUrl, {Function()? onFinish}) async {
    File? file = await _getCachedFile(audioUrl);
    //play cached video if already cached if not start downloading and play as stream
    if (file != null) {
      player2.fixedPlayer?.play(file.path, isLocal: true);
      return;
    } else {
      player2.fixedPlayer?.play(audioUrl);
    }
    StreamSubscription? listener;
    listener = player2.fixedPlayer?.onPlayerCompletion.listen((v) {
      if (onFinish != null) onFinish();
      listener?.cancel();
    });
  }

  static Future<File?> _getCachedFile(String url) async {
    /*FileInfo? fileInfo = await DefaultCacheManager().getFileFromCache(url);
    if (fileInfo == null) {
      DefaultCacheManager().downloadFile(url);
      return null;
    } else {
      return fileInfo.file;
    }*/
    return null;
  }
}
