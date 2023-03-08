/*
 * Package : mockio
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 08/03/2023
 * Copyright :  S.Hamblett
 */

import 'dart:io';

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
      expect(mySocket.port, 0);
      expect(mySocket.host, '');
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
      mySocket.add([1, 2, 3]);
      expect(mySocket.mockBytes, [1, 2, 3]);
    });
  });

  group('Group 3 - Connect', () {
    test('Simple', () {
      const myPort = 1000;
      const myHost = 'mine';
      IOOverrides.runZoned(() async {
        var mySocket = await Socket.connect(myHost, myPort);
        expect(mySocket is MockSocket, isTrue);
        mySocket = mySocket as MockSocket;
        expect(mySocket.port, myPort);
        expect(mySocket.host, myHost);
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
        expect(mySocket is MockSocket, isTrue);
        mySocket = mySocket as MockSocket;
        expect(mySocket.port, myPort);
        expect(mySocket.host, myHost);
        mySocket.add([1, 2, 3]);
        mySocket.listen((data) {
          expect(data, [1, 2, 3]);
        });
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
