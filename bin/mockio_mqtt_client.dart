/*
 * Package : mockio
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 08/03/2023
 * Copyright :  S.Hamblett
 */

import 'dart:io';

import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mockio/mockio.dart';

final mySocket = MockSocket();

void main() {
  const myHost = 'mine';
  IOOverrides.runZoned(() async {
    final client = MqttServerClient(myHost, 'xyz');
    client.logging(on: true);
    await client.connect();
    client.disconnect();
  },
      socketConnect: (dynamic host, int port,
              {dynamic sourceAddress, int sourcePort = 0, Duration? timeout}) =>
          MqttScenario1.connect(host, port,
              sourceAddress: sourceAddress,
              sourcePort: sourcePort,
              timeout: timeout));
}
