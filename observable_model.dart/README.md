# observable_model.dart

Builder that generates wrapper classes that automatically fire change events whenever a property in a monitored object changes. WIP.

## change event granularity

Suppose you have a class `User`:

```dart
abstract class _User {
  int id;
  @Monitored()
  String name;
  @Monitored()
  DateTime lastActive;
}
```

then this package can generate the following event sources:

```dart
class User extends _User {
  Stream<void> onChange;
  Stream<PropertyChangeRecord> changes;
  Stream</*String|PropertyChangeRecord<String>*/> nameChanges;
  Stream</*DateTime|PropertyChangeRecord<DateTime>*/> lastActiveChanges;
}
```

Notice: The generated class is the public one. Otherwise, we wouldn't be able to generate individual change streams for each property.
If you need to access a stream or the underlying stream controller in the class itself, simply add an abstract getter with the same name to the abstract class; the generated class will override it.
