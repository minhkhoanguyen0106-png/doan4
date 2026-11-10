import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

@JS('playPondoraAlarm')
external void _jsPlayPondoraAlarm(JSString severity);

class AlarmSoundService {
  static bool soundEnabled = true;

  static void playAlarm({String severity = 'HIGH'}) {
    if (!soundEnabled) return;
    try {
      if (kIsWeb) {
        _jsPlayPondoraAlarm(severity.toJS);
      } else {
        SystemSound.play(SystemSoundType.alert);
      }
    } catch (e) {
      debugPrint('Failed to play alarm: $e');
    }
  }
}
