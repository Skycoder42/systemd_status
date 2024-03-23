import 'src/di/river_serverpod.dart';
import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';

// This is the starting point of your Serverpod server. In most cases, you will
// only need to make additions to this file if you add future calls,  are
// configuring Relic (Serverpod's web-server), or need custom setup work.

Future<void> run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = RiverServerpod(
    args,
    Protocol(),
    Endpoints(),
  );

  // If you are using any future calls, they need to be registered here.
  // pod.registerFutureCall(ExampleFutureCall(), 'exampleFutureCall');

  // Serve all files in the /static directory.
  // pod.webServer.addRoute(
  //   RouteStaticDirectory(serverDirectory: 'static', basePath: '/'),
  //   '/*',
  // );

  // Start the server.
  await pod.start();
}
