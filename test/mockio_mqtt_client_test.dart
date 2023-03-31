/*
 * Package : mockio
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 08/03/2023
 * Copyright :  S.Hamblett
 */

import 'dart:io';

import 'package:test/test.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mockio/mockio.dart';

final mySocket = MockSocket();

void main() {
  group('Group 3 - Connect', () {
    test('Simple', () async {
      const myHost = 'mine';
      await IOOverrides.runZoned(() async {
        final client = MqttServerClient(myHost, 'xyz');
        client.logging(on: true);
        await client.connect();
        expect(client.connectionStatus!.state, MqttConnectionState.connected);
        client.disconnect();
      },
          socketConnect: (dynamic host, int port,
                  {dynamic sourceAddress,
                  int sourcePort = 0,
                  Duration? timeout}) =>
              MqttScenario1.connect(host, port,
                  sourceAddress: sourceAddress,
                  sourcePort: sourcePort,
                  timeout: timeout));
    });

    test('Simple - onDone', () async {
      const myHost = 'mine';
      await IOOverrides.runZoned(() async {
        final client = MqttServerClient(myHost, 'xyz');
        client.logging(on: true);
        await client.connect();
        expect(client.connectionStatus!.state, MqttConnectionState.connected);
        final mySocket = (MockSocket.instance as MqttScenario1);
        await MqttUtilities.asyncSleep(2);
        mySocket.onDone();
        expect(
            client.connectionStatus!.state, MqttConnectionState.disconnected);
      },
          socketConnect: (dynamic host, int port,
                  {dynamic sourceAddress,
                  int sourcePort = 0,
                  Duration? timeout}) =>
              MqttScenario1.connect(host, port,
                  sourceAddress: sourceAddress,
                  sourcePort: sourcePort,
                  timeout: timeout));
    });
  });
}
