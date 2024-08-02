export 'common/startup_controller.dart'
    show clientConfigProvider, serverUrlProvider;

export 'common/startup_controller.dart'
    if (dart.library.js_interop) 'web/startup_controller.dart'
    if (dart.library.io) 'vm/startup_controller.dart' show StartupController;
