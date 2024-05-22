import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
// ignore: implementation_imports
import 'package:shelf/src/body.dart';

part 'inject_flutter_config.freezed.dart';

Middleware injectFlutterConfig(List<InjectConfig> configs) =>
    _InjectFlutterConfigMiddleware(configs).call;

@freezed
sealed class InjectConfig with _$InjectConfig {
  const factory InjectConfig({
    required Pattern path,
    required Map<Pattern, String> replacements,
  }) = _InjectConfig;
}

class _InjectFlutterConfigMiddleware {
  final List<InjectConfig> _configs;
  final _logger = Logger('InjectFlutterConfigMiddleware');

  _InjectFlutterConfigMiddleware(this._configs);

  Handler call(Handler next) => (request) async {
        final response = await next(request);
        for (final config in _configs) {
          if (config.path.matchAsPrefix(request.url.path) != null) {
            _logger.finer(
              '${request.url.path} matches ${config.path} - replacing '
              'configuration values',
            );
            return _replaceInResponse(response, config);
          }
        }

        _logger.finest('${request.url.path} did not match any filters');
        return response;
      };

  Future<Response> _replaceInResponse(
    Response response,
    InjectConfig config,
  ) async {
    var body = await response.readAsString();
    for (final MapEntry(key: pattern, value: replacement)
        in config.replacements.entries) {
      _logger.finest('> Replacing $pattern');
      body = body.replaceAll(pattern, replacement);
    }

    return response.change(body: Body(body, response.encoding));
  }
}
