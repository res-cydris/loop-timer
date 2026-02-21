import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:loop_timer/models/timer_config.dart';

/// Generates and plays tones entirely at runtime as raw PCM/WAV bytes.
///
/// No audio asset files are required — every tone is synthesised on the fly
/// using [dart:math] and [dart:typed_data], making the service fully offline
/// and asset-free.
class AudioService {
  final AudioPlayer _player = AudioPlayer();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Preview a tone at 70% volume (used in UI tone pickers).
  Future<void> previewTone(String toneId) => playTone(toneId, 0.7);

  /// Play the end-of-timer tone at the given [volume] (0.0–1.0).
  Future<void> playTone(String toneId, double volume) async {
    final bytes = _buildWav(toneId, volume.clamp(0.0, 1.0));
    await _player.stop();
    await _player.setVolume(volume.clamp(0.0, 1.0));
    await _player.play(BytesSource(bytes));
  }

  /// Stop any currently playing tone.
  Future<void> stop() => _player.stop();

  /// Release the underlying [AudioPlayer] resources.
  Future<void> dispose() => _player.dispose();

  // ---------------------------------------------------------------------------
  // Tone dispatch
  // ---------------------------------------------------------------------------

  /// Builds WAV bytes for the requested [toneId].
  Uint8List _buildWav(String toneId, double volume) {
    switch (toneId) {
      case ToneIds.beep:
        // 880 Hz, 0.4 s, pure sine with short fade-in/out.
        return _generateWavBytes(
          frequency: 880.0,
          durationSec: 0.4,
          volume: volume,
          shape: _ToneShape.sine,
        );

      case ToneIds.chime:
        // 660 Hz, 0.8 s, sine with exponential decay.
        return _generateWavBytes(
          frequency: 660.0,
          durationSec: 0.8,
          volume: volume,
          shape: _ToneShape.decay,
        );

      case ToneIds.bell:
        // 528 Hz, 1.0 s, sine with long exponential decay.
        return _generateWavBytes(
          frequency: 528.0,
          durationSec: 1.0,
          volume: volume,
          shape: _ToneShape.longDecay,
        );

      case ToneIds.alarm:
        // 1000 Hz, 0.3 s × 3 repetitions with 0.1 s silence between.
        return _buildRepeatedTone(
          frequency: 1000.0,
          toneDurationSec: 0.3,
          silenceDurationSec: 0.1,
          repetitions: 3,
          volume: volume,
          shape: _ToneShape.sine,
        );

      case ToneIds.gentle:
        // 440 Hz, 0.6 s, sine with smooth (raised-cosine) envelope.
        return _generateWavBytes(
          frequency: 440.0,
          durationSec: 0.6,
          volume: volume,
          shape: _ToneShape.smooth,
        );

      case ToneIds.buzz:
        // 220 Hz, 0.5 s, sawtooth wave.
        return _generateWavBytes(
          frequency: 220.0,
          durationSec: 0.5,
          volume: volume,
          shape: _ToneShape.sawtooth,
        );

      case ToneIds.digital:
        // 1200 Hz, 0.2 s × 5 rapid chirps with 0.05 s silence between.
        return _buildRepeatedTone(
          frequency: 1200.0,
          toneDurationSec: 0.2,
          silenceDurationSec: 0.05,
          repetitions: 5,
          volume: volume,
          shape: _ToneShape.sine,
        );

      default:
        // Fallback: plain beep.
        return _generateWavBytes(
          frequency: 880.0,
          durationSec: 0.4,
          volume: volume,
          shape: _ToneShape.sine,
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Repeated-tone builder (alarm / digital)
  // ---------------------------------------------------------------------------

  /// Concatenates [repetitions] instances of a tone with [silenceDurationSec]
  /// of silence between each instance into a single WAV file.
  Uint8List _buildRepeatedTone({
    required double frequency,
    required double toneDurationSec,
    required double silenceDurationSec,
    required int repetitions,
    required double volume,
    required _ToneShape shape,
    int sampleRate = 44100,
  }) {
    final toneSamples = _generatePcmSamples(
      frequency: frequency,
      durationSec: toneDurationSec,
      volume: volume,
      shape: shape,
      sampleRate: sampleRate,
    );

    final silenceSampleCount =
        (silenceDurationSec * sampleRate).round();
    final silenceSamples = Int16List(silenceSampleCount); // zero-filled

    // Build the interleaved PCM buffer: tone, silence, tone, silence … tone.
    final totalSamples =
        toneSamples.length * repetitions +
        silenceSamples.length * (repetitions - 1);
    final combined = Int16List(totalSamples);

    int offset = 0;
    for (int i = 0; i < repetitions; i++) {
      combined.setAll(offset, toneSamples);
      offset += toneSamples.length;
      if (i < repetitions - 1) {
        combined.setAll(offset, silenceSamples);
        offset += silenceSamples.length;
      }
    }

    return _wrapInWav(combined, sampleRate);
  }

  // ---------------------------------------------------------------------------
  // Core WAV generator
  // ---------------------------------------------------------------------------

  /// Generates a complete WAV [Uint8List] for a single continuous tone.
  Uint8List _generateWavBytes({
    required double frequency,
    required double durationSec,
    required double volume,
    required _ToneShape shape,
    int sampleRate = 44100,
  }) {
    final samples = _generatePcmSamples(
      frequency: frequency,
      durationSec: durationSec,
      volume: volume,
      shape: shape,
      sampleRate: sampleRate,
    );
    return _wrapInWav(samples, sampleRate);
  }

  /// Synthesises 16-bit mono PCM samples for a single tone segment.
  Int16List _generatePcmSamples({
    required double frequency,
    required double durationSec,
    required double volume,
    required _ToneShape shape,
    required int sampleRate,
  }) {
    final numSamples = (durationSec * sampleRate).round();

    // Fade-in / fade-out window: first and last 10 ms avoid clicks.
    final fadeSamples = (0.01 * sampleRate).round().clamp(0, numSamples ~/ 2);

    final samples = Int16List(numSamples);
    final maxAmplitude = 32767.0 * volume;

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate; // time in seconds

      // --- Waveform value in [-1, 1] ---
      double raw;
      switch (shape) {
        case _ToneShape.sine:
          raw = math.sin(2.0 * math.pi * frequency * t);

        case _ToneShape.sawtooth:
          // Sawtooth: value = 2 * (t*f - floor(t*f + 0.5))
          final phase = t * frequency;
          raw = 2.0 * (phase - (phase + 0.5).floor());

        case _ToneShape.decay:
          // Exponential decay: amplitude = exp(-3 * t / duration)
          raw = math.sin(2.0 * math.pi * frequency * t) *
              math.exp(-3.0 * t / durationSec);

        case _ToneShape.longDecay:
          // Slower exponential decay: amplitude = exp(-2 * t / duration)
          raw = math.sin(2.0 * math.pi * frequency * t) *
              math.exp(-2.0 * t / durationSec);

        case _ToneShape.smooth:
          // Raised-cosine (Hann) envelope for a smooth attack and release.
          final envelope =
              0.5 * (1.0 - math.cos(2.0 * math.pi * i / (numSamples - 1)));
          raw = math.sin(2.0 * math.pi * frequency * t) * envelope;
      }

      // --- Short fade-in / fade-out to eliminate clicks at boundaries ---
      // Only applied for shapes that don't already have built-in envelopes.
      double fadeGain = 1.0;
      if (shape == _ToneShape.sine || shape == _ToneShape.sawtooth) {
        if (i < fadeSamples && fadeSamples > 0) {
          fadeGain = i / fadeSamples;
        } else if (i >= numSamples - fadeSamples && fadeSamples > 0) {
          fadeGain = (numSamples - 1 - i) / fadeSamples;
        }
      }

      samples[i] = (raw * fadeGain * maxAmplitude).round().clamp(-32768, 32767);
    }

    return samples;
  }

  // ---------------------------------------------------------------------------
  // WAV file construction
  // ---------------------------------------------------------------------------

  /// Wraps a [Int16List] of 16-bit mono PCM samples into a valid WAV [Uint8List].
  ///
  /// All multi-byte fields are written in little-endian byte order as required
  /// by the WAV specification.
  Uint8List _wrapInWav(Int16List samples, int sampleRate) {
    const int channels = 1;
    const int bitsPerSample = 16;
    final int byteRate = sampleRate * channels * bitsPerSample ~/ 8;
    final int blockAlign = channels * bitsPerSample ~/ 8;
    final int dataSize = samples.length * blockAlign;
    final int fileSize = 36 + dataSize; // 36 = RIFF header + fmt chunk

    final buffer = ByteData(8 + fileSize); // 8 for 'RIFF' tag + file-size field
    int offset = 0;

    // ---- RIFF chunk descriptor ----
    _writeAscii(buffer, offset, 'RIFF'); offset += 4;
    buffer.setUint32(offset, fileSize, Endian.little); offset += 4;
    _writeAscii(buffer, offset, 'WAVE'); offset += 4;

    // ---- fmt  sub-chunk (16 bytes) ----
    _writeAscii(buffer, offset, 'fmt '); offset += 4;
    buffer.setUint32(offset, 16, Endian.little); offset += 4;   // sub-chunk size
    buffer.setUint16(offset, 1, Endian.little); offset += 2;    // PCM = 1
    buffer.setUint16(offset, channels, Endian.little); offset += 2;
    buffer.setUint32(offset, sampleRate, Endian.little); offset += 4;
    buffer.setUint32(offset, byteRate, Endian.little); offset += 4;
    buffer.setUint16(offset, blockAlign, Endian.little); offset += 2;
    buffer.setUint16(offset, bitsPerSample, Endian.little); offset += 2;

    // ---- data sub-chunk ----
    _writeAscii(buffer, offset, 'data'); offset += 4;
    buffer.setUint32(offset, dataSize, Endian.little); offset += 4;

    // Write 16-bit samples in little-endian order.
    for (final sample in samples) {
      buffer.setInt16(offset, sample, Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }

  /// Writes a 4-character ASCII string into [buffer] at [offset].
  void _writeAscii(ByteData buffer, int offset, String text) {
    for (int i = 0; i < text.length; i++) {
      buffer.setUint8(offset + i, text.codeUnitAt(i));
    }
  }
}

// ---------------------------------------------------------------------------
// Internal tone shape enum
// ---------------------------------------------------------------------------

enum _ToneShape {
  /// Plain sine wave (with short click-prevention fades at boundaries).
  sine,

  /// Sawtooth wave (with short click-prevention fades at boundaries).
  sawtooth,

  /// Sine with fast exponential decay (exp(-3 * t / duration)).
  decay,

  /// Sine with slower exponential decay (exp(-2 * t / duration)).
  longDecay,

  /// Sine with a raised-cosine (Hann window) envelope — smooth attack + release.
  smooth,
}
