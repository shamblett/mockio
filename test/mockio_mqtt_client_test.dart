import 'dart:io';
import 'package:test/test.dart';

import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mockio/mockio.dart';

final mySocket = MockSocket();

void main() {
  group('Group 3 - Connect', () {
    test('Simple', () {
      const myHost = 'mine';
      IOOverrides.runZoned(() async {
        final client = MqttServerClient(myHost, 'xyz');
        client.logging(on:true);
        await client.connect();
        expect(client.connectionStatus!.state, MqttConnectionState.connected);
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
