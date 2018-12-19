part of 'config.dart';

class GeneralConfiguration extends _GeneralConfiguration {
  GeneralConfiguration() {
    _apps = ManagedList(_notifyChange);
  }

  @override
  set mashupTitle(String v) {
    if (mashupTitle == v) return;
    super.mashupTitle = v;
    _notifyChange();
  }

  @override
  List<App> get apps => _apps;
  List<App> _apps;

  Stream<void> get onChange =>
      (_onChange ??= StreamController.broadcast(onCancel: _unobserved)).stream;
  StreamController<void> _onChange;

  void _unobserved() => _onChange = null;

  void _notifyChange() => _onChange?.add(null);
}

class App extends _App {
  App() {
    _hostToAppIdMappings = ManagedMap(_notifyChange);
  }

  @override
  set name(String v) {
    if (name == v) return;
    super.name = v;
    _notifyChange();
  }

  @override
  Map<String, String> get hostToAppIdMappings => _hostToAppIdMappings;
  Map<String, String> _hostToAppIdMappings;

  Stream<void> get onChange =>
      (_onChange ??= StreamController.broadcast(onCancel: _unobserved)).stream;
  StreamController<void> _onChange;

  void _unobserved() => _onChange = null;

  void _notifyChange() => _onChange?.add(null);
}
