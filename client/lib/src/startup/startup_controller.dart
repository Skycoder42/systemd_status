export 'common/startup_controller.dart'
    show clientConfigProvider, serverUrlProvider;

export 'common/startup_controller.dart'
    if (dart.library.html) 'web/startup_controller.dart'
    if (dart.library.io) 'vm/startup_controller.dart' show StartupController;
