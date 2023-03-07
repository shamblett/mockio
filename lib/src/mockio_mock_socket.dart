import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:event_bus/event_bus.dart';

class MockSocket extends Mock implements Socket {
  final eventBus = EventBus();
  final mockBytes = <int>[];
  final mockBytesUint = Uint8List(500);

  MockSocket() {
    eventBus.on().listen((event) {
      // Print the runtime type. Such a set up could be used for logging.
      print('MockSocket:: - we are $event');
    });
  }

  @override
  int port = 0;

  String host = '';

  late StreamSubscription<Uint8List> outgoing =
      Stream<Uint8List>.empty().listen((event) {});

  static Future<MockSocket> connect(host, int port,
      {sourceAddress, int sourcePort = 0, Duration? timeout}) {
    final completer = Completer<MockSocket>();
    final extSocket = MockSocket();
    extSocket.port = port;
    extSocket.host = host;
    completer.complete(extSocket);
    return completer.future;
  }

  @override
  void add(List<int> data) {
    mockBytes.addAll(data);
  }

  @override
  StreamSubscription<Uint8List> listen(void Function(Uint8List event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    final out = Uint8List.fromList(mockBytes);
    onData!(out);
    return outgoing;
  }
}
