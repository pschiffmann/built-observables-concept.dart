import 'src/collection.dart';

export 'src/collection.dart';

/// Annotation that marks a class as monitored. Fields must be explicitly marked
/// with [MonitoredField].
class Monitored {
  const Monitored({this.name});

  /// The name of the generated class. If `null`, the name of the annotated
  /// class without leading `_` is used.
  final Symbol name;
}

/// Annotation that marks a field of a [Monitored] as monitored.
class MonitoredField {
  const MonitoredField({this.compare, this.normalize});

  /// Compares the old and new field values. If this method returns `true`, a
  /// change event is queued. If omitted, [Object.operator==] of the old object
  /// is used.
  ///
  /// The signature of this function must be `bool Function(T, T)`, where `T` is
  /// the type of the annotated field.
  final bool Function(Null, Null) compare;

  /// Values assigned to this field are passed through this function first, and
  /// only the result is passed to [compare] and stored in this field.
  ///
  /// The signature of this function must be `T Function(T)`, where `T` is the
  /// type of the annotated field.
  ///
  /// **Caution**: Values from field initializer expressions and constructor
  /// initializer lists are not normalized.
  final Object Function(Null) normalize;
}

/// A managed object is considered part of its parent. The field must not have
/// a setter, and it shouldn't expose any _change_ streams itself. Instead, it
/// will report its changes through the `$fieldChanges` stream of its parent:
///
/// ```dart
/// @Monitored()
/// abstract class _User {
///   @Managedfield
///   List<String> get emails;
/// }
/// ```
///
/// In this example, `emails` will be instantiated as a [ManagedList], and every
/// change to that list will be reported through `User.emailsChanges`.
///
/// Currently, the only supported types are [ManagedList] and [ManagedMap].
class ManagedField {
  const ManagedField();
}
