import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextWidget extends StatefulWidget {
  final Function(String)? onVoiceRecognized;
  const SpeechToTextWidget({
    super.key,
    this.onVoiceRecognized,
  });

  @override
  State<SpeechToTextWidget> createState() => _SpeechToTextWidgetState();
}

class _SpeechToTextWidgetState extends State<SpeechToTextWidget> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  final bool _logEvents = true;
  String lastError = '';
  String lastStatus = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      debugLogging: _logEvents,
      onError: errorListener,
      onStatus: statusListener,
    );
  }

  void errorListener(SpeechRecognitionError error) {
    _logEvent(
        'Received error status: $error, listening: ${_speechToText.isListening}');
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  void statusListener(String status) {
    _logEvent(
        'Received listener status: $status, listening: ${_speechToText.isListening}');
    setState(() {
      lastStatus = status;
    });
  }

  void _logEvent(String eventDescription) {
    if (_logEvents) {
      var eventTime = DateTime.now().toIso8601String();
      debugPrint('$eventTime $eventDescription');
    }
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      widget.onVoiceRecognized?.call(_lastWords);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mic = IconButton(
      icon: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      onPressed:
          _speechToText.isNotListening ? _startListening : _stopListening,
    );
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            // If listening is active show the recognized words
            _speechToText.isListening
                ? _lastWords
                // If listening isn't active but could be tell the user
                // how to start it, otherwise indicate that speech
                // recognition is not yet ready or not supported on
                // the target device
                : _speechEnabled
                    ? 'Tap the microphone to start listening...'
                    : 'Speech not available',
          ),
        ),
        Center(child: mic),
      ],
    );
  }
}
