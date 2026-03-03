import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

class ClipboardService {
  Timer? _clipboardTimer;

  Future<void> copy(
    String text, {
    Duration expireAfter = const Duration(seconds: 45),
  }) async {
    try {
      if (text == '••••••••' || text.isEmpty) return;

      await Clipboard.setData(ClipboardData(text: text));

      _clipboardTimer?.cancel();

      _clipboardTimer = Timer(expireAfter, () async {
        try {
          final currentData = await Clipboard.getData(Clipboard.kTextPlain);
          if (currentData != null && currentData.text == text) {
            await Clipboard.setData(const ClipboardData(text: ''));
          }
        } catch (e) {
          // Graceful degradation, background clear fails silently
        }
      });
    } on PlatformException catch (e) {
      // Graceful degradation, log but don't crash
      debugPrint('Clipboard copy failed: $e');
    } catch (e) {
      debugPrint('Clipboard error: $e');
    }
  }

  void dispose() {
    _clipboardTimer?.cancel();
  }
}

final clipboardServiceProvider = Provider<ClipboardService>((ref) {
  final service = ClipboardService();
  ref.onDispose(() => service.dispose());
  return service;
});
