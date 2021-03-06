import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

abstract class ParserGenerator<T extends Element, GlobalData, Data, Annotation>
    extends GeneratorForAnnotation<Annotation> {
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    final values = StringBuffer();

    final globalData = parseGlobalData(library.element);

    for (var element in library.annotatedWith(typeChecker).map((e) => e.element).whereType<T>()) {
      final data = parseElement(globalData, element);
      if (data == null) continue;

      for (final value in generateForData(globalData, data).map((e) => e.toString())) {
        assert(value == null || (value.length == value.trim().length));
        values.writeln(value);
      }
    }

    return values.toString();
  }

  GlobalData parseGlobalData(LibraryElement library);

  Data parseElement(GlobalData globalData, T element);

  Iterable<Object> generateForData(GlobalData globalData, Data data);

  @override
  Iterable<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) sync* {
    // implemented for source_gen_test – otherwise unused
    final globalData = parseGlobalData(element.library);
    final data = parseElement(globalData, element as T);
    if (data == null) return;
    yield* generateForData(globalData, data).map((element) => element.toString());
  }
}
