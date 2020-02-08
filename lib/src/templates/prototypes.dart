import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';

import 'parameter_template.dart';

String whenPrototype(List<ConstructorElement> allConstructors, {@required bool areCallbacksRequired}) {
  final buffer = StringBuffer('Result when<Result>(');

  final parameters = <CallbackParameter>[];
  for (final constructor in allConstructors) {
    final constructorParameters = ParametersTemplate.fromParameterElements(constructor.parameters);

    var template = CallbackParameter(
      name: constructorNameToCallbackName(constructor.name),
      type: 'Result',
      isRequired: !isDefaultConstructor(constructor) && areCallbacksRequired,
      parameters: ParametersTemplate([
        ...constructorParameters.positionalParameters,
        ...constructorParameters.optionalPositionalParameters,
        ...constructorParameters.namedParameters,
      ]),
    );

    if (isDefaultConstructor(constructor)) {
      buffer..write(template)..write(',');
    } else {
      parameters.add(template);
    }
  }

  buffer
    ..write('{')
    ..writeAll(parameters, ',')
    ..write(',})');
  return buffer.toString();
}

bool isDefaultConstructor(ConstructorElement constructor) {
  return constructor.name == null || constructor.name.isEmpty;
}

String constructorNameToCallbackName(String constructorName) {
  return constructorName == null || constructorName.isEmpty ? '\$default' : constructorName;
}