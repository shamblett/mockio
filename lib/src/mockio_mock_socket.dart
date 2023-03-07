import 'dart:async';
import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:event_bus/event_bus.dart';

class MockSocket extends Mock implements Socket {
  final eventBus = EventBus();
  final mockBytes = <int>[];
  MockSocket() {
    eventBus.on().listen((event) {
      // Print the runtime type. Such a set up could be used for logging.
      print('Hello from MockSocket - ${event.runtimeType}');
    });
  }
  static Future<MockSocket> connect(host, int port,
      {sourceAddress, int sourcePort = 0, Duration? timeout}) {
    final completer = Completer<MockSocket>();
    final extsocket = MockSocket();
    completer.complete(extsocket);
    return completer.future;
  }
}
