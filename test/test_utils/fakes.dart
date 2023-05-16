import 'package:flutter/services.dart';
import 'package:freerasp/freerasp.dart';
import 'package:mocktail/mocktail.dart';

class FakeMethodChannel extends Fake implements MethodChannel {}

class FakeEventChannel extends Fake implements EventChannel {}

class FakeTalsecConfig extends Fake implements TalsecConfig {}
