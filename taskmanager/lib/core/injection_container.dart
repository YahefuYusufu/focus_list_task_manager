import 'service_locator.dart';

class InjectionContainer {
  static Future<void> init() async {
    // Initialize service locator
    sl.setupDependencies();
  }
}
