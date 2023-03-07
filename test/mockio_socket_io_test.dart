import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mockio/mockio.dart';

final mySocket = MockSocket();

void main() {
  group('Group 1 - Simple', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Getter', () {
      when(() => mySocket.port).thenReturn(500);
      when(() => mySocket.remotePort).thenReturn(600);
      expect(mySocket.port, 500);
      expect(mySocket.remotePort, 600);
    });

    test('Setter', () {
      when(() => mySocket.setOption(SocketOption.tcpNoDelay, any()))
          .thenReturn(true);
      expect(mySocket.setOption(SocketOption.tcpNoDelay, true), isTrue);
    });
  });

  group('Group 2 - Dynamic', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Add', () {
      when(() => mySocket.add(any())).thenAnswer((invocation) {
        mySocket.mockBytes.addAll(invocation.positionalArguments[0]);
      });
      mySocket.add([1, 2, 3]);
      expect(mySocket.mockBytes, [1, 2, 3]);
    });

    test('Take', () async {
      when(() => mySocket.take(any())).thenAnswer((invocation) {
        final length = invocation.positionalArguments[0];
        final taken = mySocket.mockBytes.take(length).toList();
        mySocket.mockBytes.removeRange(0, length);
        final utaken = Uint8List.fromList(taken);
        final out = StreamController<Uint8List>();
        out.add(utaken);
        out.done;
        out.close();
        return out.stream;
      });
      final taken = mySocket.take(2);
      expect(await taken.single, [1, 2]);
      expect(mySocket.mockBytes, [3]);
    });
  });

  group('Group 3 - Connect', () {
    test('Simple', () {
      const myPort = 1000;
      const myHost = 'mine';
      IOOverrides.runZoned(() async {
        var mySocket = await Socket.connect(myHost, myPort);
        when(() => mySocket.port).thenReturn(myPort);
        expect(mySocket is MockSocket, isTrue);
        mySocket = mySocket as MockSocket;
        final eb = mySocket.eventBus;
        eb.fire('Hello');
        expect(mySocket.port, myPort);
      },
          socketConnect: (dynamic host, int port,
                  {dynamic sourceAddress,
                  int sourcePort = 0,
                  Duration? timeout}) =>
              MockSocket.connect(host, port,
                  sourceAddress: sourceAddress,
                  sourcePort: sourcePort,
                  timeout: timeout));
    });
    test('Listen', () {
      const myPort = 1000;
      const myHost = 'mine';
      IOOverrides.runZoned(() async {
        var mySocket = await Socket.connect(myHost, myPort);
        when(() => mySocket.port).thenReturn(myPort);
        when(() => mySocket.add(any())).thenAnswer((invocation) {
          (mySocket as MockSocket)
              .mockBytes
              .addAll(invocation.positionalArguments[0]);
        });
        expect(mySocket is MockSocket, isTrue);
        mySocket = mySocket as MockSocket;
        final eb = mySocket.eventBus;
        eb.fire('Hello');
        expect(mySocket.port, myPort);
        mySocket.add([1, 2, 3]);
        //mySocket.listen((event) {});
      },
          socketConnect: (dynamic host, int port,
                  {dynamic sourceAddress,
                  int sourcePort = 0,
                  Duration? timeout}) =>
              MockSocket.connect(host, port,
                  sourceAddress: sourceAddress,
                  sourcePort: sourcePort,
                  timeout: timeout));
    });
  });
}
