import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../common/common.dart';
import '../../constants.dart';

class SpeechToTextWidget extends StatefulWidget {
  final Function(String)? onVoiceRecognized;
  final FirebaseAnalytics analytics;
  const SpeechToTextWidget({
    super.key,
    this.onVoiceRecognized,
    required this.analytics,
  });

  @override
  State<SpeechToTextWidget> createState() => _SpeechToTextWidgetState();
}

class _SpeechToTextWidgetState extends State<SpeechToTextWidget> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  String _lastError = '';
  String _lastStatus = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      debugLogging: isDevelopment,
      onError: errorListener,
      onStatus: statusListener,
    );
  }

  void errorListener(SpeechRecognitionError error) {
    _logEvent(
        'Received error status: $error, listening: ${_speechToText.isListening}');
    setState(() {
      _lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  void statusListener(String status) {
    _logEvent(
        'Received listener status: $status, listening: ${_speechToText.isListening}');
    setState(() {
      _lastStatus = status;
    });
  }

  void _logEvent(String eventDescription) async {
    var eventTime = DateTime.now().toIso8601String();
    if (isDevelopment) {
      debugPrint('$eventTime $eventDescription');
    }
    await widget.analytics.logEvent(
      name: 'speech_to_text',
      parameters: <String, dynamic>{
        'event_time': eventTime,
        'event_description': eventDescription,
      },
    );
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    setState(() {
      _loading = true;
    });
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _loading = false;
    });
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
      icon: _loading
          ? const CircularProgressIndicator(
              backgroundColor: Colors.grey,
              color: Colors.white,
              strokeWidth: 2,
            )
          : Icon(
              _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
              color: _speechToText.isNotListening
                  ? Colors.grey
                  : Colors.green[400],
            ),
      onPressed: !_loading && _speechToText.isNotListening
          ? _startListening
          : _stopListening,
    );
    return [
      Text(
        // If listening is active show the recognized words
        _speechToText.isListening
            ? _lastWords
            // If listening isn't active but could be tell the user
            // how to start it, otherwise indicate that speech
            // recognition is not yet ready or not supported on
            // the target device
            : _speechEnabled
                ? AppLocalizations.of(context)!.tapToStart
                : AppLocalizations.of(context)!.speechNotAvailable,
      ),
      Center(child: mic),
      if (isDevelopment && _lastError.isNotEmpty)
        Text(
          _lastError,
          style: const TextStyle(color: Colors.red),
        ).center(),
      if (isDevelopment && _lastStatus.isNotEmpty)
        Text(
          _lastStatus,
          style: const TextStyle(color: Colors.green),
        ).center(),
    ].toColumn();
  }
}
