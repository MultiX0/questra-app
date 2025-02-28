import 'package:questra_app/imports.dart';

final soundEffectsServiceProvider = Provider<SoundEffectsService>((ref) {
  return SoundEffectsService();
});

bool activeLoop = false;

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

  void playFirstTada() {
    playEffect("tada_1.ogg");
  }

  void playCongrats() {
    playEffect("congrats.ogg");
  }

  Future<AudioPlayer?> playBackgroundMusic() async {
    // If already playing, don't start again
    if (activeLoop) return null;

    // Set flag before starting playback to prevent race conditions
    activeLoop = true;

    // Use loopLongAudio for background music that needs to loop continuously
    final audioPlayer = await FlameAudio.loopLongAudio('game-music-loop-6-144641.ogg');

    // Add error handling
    audioPlayer.onPlayerComplete.listen((_) {
      activeLoop = false;
    });

    return audioPlayer;
  }

  void stopBackgroundMusic(AudioPlayer audioPlayer) {
    audioPlayer.stop();
    activeLoop = false;
  }

  void playCoinsRecived() {
    playEffect("coins_recived.ogg");
  }
}
