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
    await playEffectWithCache("mouserelease1.ogg");
  }

  Future<void> playMainButtonEffect() async {
    await playEffectWithCache("default_btn.aac");
  }
}
