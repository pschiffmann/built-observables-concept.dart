import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:mustache/mustache.dart';
import 'package:source_gen/source_gen.dart';

import 'observable_model.dart';

const monitoredType = TypeChecker.fromRuntime(Monitored);
const managedFieldType = TypeChecker.fromRuntime(ManagedField);
const monitoredFieldType = TypeChecker.fromRuntime(MonitoredField);
const coreListType = TypeChecker.fromRuntime(List);
const coreMapType = TypeChecker.fromRuntime(Map);

/// Renders the Dart code for a monitor class. Expects a [MonitorDefinition]
/// as template variable.
final monitorTemplate = Template(r'''
class {{monitorName}} extends {{className}} {
  {{monitorName}}()
  {{#managedFields.isEmpty}};{{/managedFields.isEmpty}}
  {{#managedFields.isNotEmpty}}
  {
    {{#managedFields}}
    _{{name}} = {{constructor}}(_notifyChange);
    {{/managedFields}}
  }
  {{/managedFields.isNotEmpty}}

  {{#monitoredFields}}
  @override
  set {{name}}({{{type}}} v) {
    if ({{name}} == v) return;
    super.{{name}} = v;
    _notifyChange();
  }
  {{/monitoredFields}}

  {{#managedFields}}
  @override
  {{{type}}} get {{name}} => _{{name}};
  {{{type}}} _{{name}};
  {{/managedFields}}

  /// Sends an event every time the value of a monitored property changes.
  Stream<void> get onChange =>
      (_onChange ??= StreamController.broadcast(onCancel: _unobserved)).stream;
  StreamController<void> _onChange;

  void _unobserved() => _onChange = null;
  void _notifyChange() => _onChange?.add(null);
}
''');

Builder observableBuilder(BuilderOptions options) =>
    SharedPartBuilder([ObservableGenerator()], 'observable');

class ObservableGenerator extends GeneratorForAnnotation<Monitored> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError('@Monitored must annotate a class',
          element: element);
    }
    final cls = element as ClassElement;
    final definition = MonitorDefinition()
      ..className = cls.name
      ..monitorName = resolveMonitorName(cls, annotation);
    resolveFields(definition, cls);
    return monitorTemplate.renderString(definition);
  }

  /// Returns the name specified in [Monitored.name], or the name of [cls]
  /// without leading underscore.
  String resolveMonitorName(ClassElement cls, ConstantReader annotation) {
    final provided = annotation.read('name');
    if (provided.isSymbol) return provided.symbolValue.toString();
    if (cls.isPrivate) return cls.name.substring(1);
    throw InvalidGenerationSourceError(
        "Can't resolve the name of the generated monitor class because the "
        'class is not private',
        element: cls);
  }

  /// Resolves all fields in [cls] annotated with [MonitoredField] or
  /// [ManagedField] and adds the  respective [FieldDefinition]s to [monitor].
  void resolveFields(MonitorDefinition monitor, ClassElement cls) {
    for (final accessor in cls.accessors) {
      if (accessor.isGetter) {
        final resolved = resolveManagedField(accessor);
        if (resolved == null) continue;
        monitor.managedFields.add(resolved);
      } else {
        assert(accessor.isSetter);
        final resolved = resolveMonitoredField(accessor);
        if (resolved == null) continue;
        monitor.monitoredFields.add(resolved);
      }

      if (accessor.isStatic) {
        throw InvalidGenerationSourceError(
            '@MonitoredField() and @ManagedField() fields must not be static',
            element: accessor.isSynthetic ? accessor.variable : accessor);
      }
    }

    if (monitor.monitoredFields.isEmpty && monitor.managedFields.isEmpty) {
      throw InvalidGenerationSourceError(
          'No field is annotated with @MonitoredField. This would result in a '
          'monitor class that does nothing',
          element: cls);
    }
  }

  /// Processes a [MonitoredField] annotations on [setter], or returns `null` if
  /// no annotation is found.
  ///
  /// Throws an [InvalidGenerationSourceError] if the element has multiple
  /// [ManagedField] annotations, or an [MonitoredField] annotations.
  FieldDefinition resolveMonitoredField(PropertyAccessorElement setter) {
    final annotatedElement = setter.isSynthetic ? setter.variable : setter;
    final annotations =
        monitoredFieldType.annotationsOf(annotatedElement).toList();
    if (annotations.isEmpty) return null;
    if (annotations.length > 1) {
      throw InvalidGenerationSourceError(
          'Found multiple @MonitoredField() annotations on a single element, '
          'this is probably a bug',
          element: annotatedElement);
    }
    if (managedFieldType.hasAnnotationOf(annotatedElement)) {
      throw InvalidGenerationSourceError(
          'Fields must not be annotated with both '
          '@ManagedField() and @MonitoredField',
          element: annotatedElement);
    }

    final annotation = ConstantReader(annotations.first);
    final field = setter.variable;
    final result = FieldDefinition()
      ..name = field.name
      ..type = field.type?.displayName ?? 'dynamic';
    if (!annotation.read('compare').isNull) {
      throw UnimplementedError(
          '@MonitoredField.compare support is not implemented');
    }
    if (!annotation.read('normalize').isNull) {
      throw UnimplementedError(
          '@MonitoredField.normalize support is not implemented');
    }

    return result;
  }

  /// Processes a [ManagedField] annotations on [getter], or returns `null` if
  /// no annotation is found.
  FieldDefinition resolveManagedField(PropertyAccessorElement getter) {
    final annotatedElement = getter.isSynthetic ? getter.variable : getter;
    if (!managedFieldType.hasAnnotationOf(annotatedElement)) return null;
    if (monitoredFieldType.hasAnnotationOf(annotatedElement)) {
      throw InvalidGenerationSourceError(
          'Fields must not be annotated with both '
          '@ManagedField() and @MonitoredField',
          element: annotatedElement);
    }

    final field = getter.variable;
    final result = FieldDefinition()
      ..name = field.name
      ..type = field.type?.displayName ?? 'dynamic';
    if (coreListType.isExactlyType(field.type)) {
      result.constructor = 'ManagedList';
    } else if (coreMapType.isExactlyType(field.type)) {
      result.constructor = 'ManagedMap';
    } else {
      throw InvalidGenerationSourceError(
          'Currently, the only supported managed types are `List` and `Map`',
          element: annotatedElement);
    }

    return result;
  }
}

/// Stores information resolved from the parsed source code about a monitor
/// class that shall be generated.
class MonitorDefinition {
  /// The name of the monitored class.
  String className;

  /// The name of the generated class.
  String monitorName;

  final List<FieldDefinition> monitoredFields = [];
  final List<FieldDefinition> managedFields = [];
}

class FieldDefinition {
  /// The name of this field.
  String name;

  /// The static type of this field, including generic type parameters. (For
  /// example, `int` or `List<String>`).
  String type;

  /// The name of the backing implementation of `type` (for example
  /// `ManagedList` if [type] is `List<int>`), or `null` for monitored fields.
  String constructor;

  /// Returns `true` if this field is a managed field, and `false` if this is a
  /// monitored field.
  bool get isManaged => constructor != null;
}
