/*
 * Package : mockio
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 08/03/2023
 * Copyright :  S.Hamblett
 */

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:typed_data/typed_data.dart';

///
/// Mock socket access class
///
class MockSocketAccess {
  static dynamic mockSocket;
}

//
/// The mock socket class
///
class MockSocket extends Mock implements Socket {
  final mockBytes = <int>[];
  final mockBytesUint = Uint8List(500);

  MockSocket();

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
    MockSocketAccess.mockSocket = extSocket;
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

  @override
  void destroy();

  @override
  Future close() {
    final completer = Completer<Future>();
    return completer.future;
  }
}

///
/// Mock socket scenario class
///
class MqttScenario1 extends MockSocket {
  dynamic onDataFunc;
  dynamic onDoneFunc;

  static Future<MqttScenario1> connect(host, int port,
      {sourceAddress, int sourcePort = 0, Duration? timeout}) {
    final completer = Completer<MqttScenario1>();
    final extSocket = MqttScenario1();
    extSocket.port = port;
    extSocket.host = host;
    MockSocketAccess.mockSocket = extSocket;
    completer.complete(extSocket);
    return completer.future;
  }

  @override
  void add(List<int> data) {
    mockBytes.addAll(data);
    final ack = MqttConnectAckMessage()
        .withReturnCode(MqttConnectReturnCode.connectionAccepted);
    final buff = Uint8Buffer();
    final ms = MqttByteBuffer(buff);
    ack.writeTo(ms);
    ms.seek(0);
    final out = Uint8List.fromList(ms.buffer!.toList());
    onDataFunc(out);
  }

  @override
  StreamSubscription<Uint8List> listen(void Function(Uint8List event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    onDataFunc = onData;
    onDoneFunc = onDone;
    return outgoing;
  }

  void onDone() => onDoneFunc();
}
