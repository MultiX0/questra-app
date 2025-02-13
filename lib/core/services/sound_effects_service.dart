import 'package:questra_app/imports.dart';

final soundEffectsServiceProvider = Provider<SoundEffectsService>((ref) {
  return SoundEffectsService();
});

class SoundEffectsService {
  void playEffect(String soundName) {
    FlameAudio.play(soundName);
  }

  Future<void> playEffectWithCache(String soundName) async {
    await FlameAudio.audioCache.load(soundName);
  }

  Future<void> playSystemButtonClick() async {
    playEffect("mouserelease1.ogg");
  }

  Future<void> playMainButtonEffect() async {
    playEffect("default_btn.aac");
  }
}
