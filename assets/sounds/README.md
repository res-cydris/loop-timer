# Sound Assets

All tones are generated programmatically at runtime by `ToneGenerator`
(see `lib/services/audio_service.dart`). No external audio files are required.

Generated tones and their base frequencies:

| Tone ID   | Frequency (Hz) | Character          |
|-----------|---------------|--------------------|
| beep      | 880           | Short digital beep |
| chime     | 660           | Soft chime         |
| bell      | 528           | Bell ring          |
| alarm     | 1000          | Urgent alarm       |
| gentle    | 440           | Gentle notification|
| buzz      | 220           | Low buzzer         |
| digital   | 1200          | Digital chirp      |
