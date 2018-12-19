import 'dart:async';

import 'package:observable_model/observable_model.dart';

part 'config.g.dart';

@Monitored()
abstract class _GeneralConfiguration {
  @MonitoredField()
  String mashupTitle;

  @MonitoredField(managed: true)
  List<App> get apps;
}

@Monitored()
abstract class _App {
  @MonitoredField()
  String name;

  @MonitoredField(managed: true)
  Map<String, String> get hostToAppIdMappings;
}
