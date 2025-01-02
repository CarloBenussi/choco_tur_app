import 'dart:async';

Future<void> startTimer(int seconds) async {
  final completer = Completer<void>();

  Timer(Duration(seconds: seconds), () {
    completer.complete();
  });

  return completer.future;
}
