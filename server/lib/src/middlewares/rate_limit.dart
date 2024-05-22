import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';

typedef DateTimeNow = DateTime Function();

Middleware rateLimit({
  int maxRequests = 300,
  Duration window = const Duration(minutes: 1),
  DateTimeNow dateTimeNow = DateTime.now,
}) =>
    _RateLimitMiddleware(maxRequests, window, dateTimeNow).call;

class _IpInfo {
  DateTime windowEndTime;
  int requestCount;
  Timer _cleanupTimer;

  _IpInfo(this.windowEndTime, this._cleanupTimer) : requestCount = 0;

  void resetWindow(_IpInfo info) {
    windowEndTime = info.windowEndTime;
    _cleanupTimer.cancel();
    _cleanupTimer = info._cleanupTimer;
    requestCount--; // decrement to prevent buffer overflows
  }
}

class _RateLimitMiddleware {
  final int _maxRequests;
  final Duration _window;
  final DateTimeNow _dateTimeNow;

  final _cache = <String, _IpInfo>{};
  final _logger = Logger('RateLimitMiddleware');

  _RateLimitMiddleware(
    this._maxRequests,
    this._window,
    this._dateTimeNow,
  );

  Handler call(Handler next) => (request) async {
        final blockTime = _checkRateLimit(request);
        if (blockTime > Duration.zero) {
          return Response(
            HttpStatus.tooManyRequests,
            headers: {
              HttpHeaders.retryAfterHeader: blockTime.inSeconds.toString(),
            },
          );
        }

        return next(request);
      };

  Duration _checkRateLimit(Request request) {
    final now = _dateTimeNow();
    final ip = _getIpAddress(request);
    final ipInfo = _cache.putIfAbsent(ip, () => _createInfo(ip, now));

    // check if limit has been reached
    ipInfo.requestCount++;
    if (ipInfo.requestCount == _maxRequests) {
      // first time offenders are not punished and only need to wait for the
      // end of the started window
      final blockTime = ipInfo.windowEndTime.difference(now);
      _logger.finer('Blocking $ip for $blockTime (first time offender)');
      return blockTime;
    } else if (ipInfo.requestCount > _maxRequests) {
      // trying again after being blocked resets the window as penalty
      _logger.fine('Blocking $ip for $_window (repeated offender)');
      ipInfo.resetWindow(_createInfo(ip, now));
      return _window;
    } else {
      _logger.finest(
        'Allowing $ip with ${ipInfo.requestCount}/$_maxRequests requests '
        'until ${ipInfo.windowEndTime}',
      );
      return Duration.zero;
    }
  }

  String _getIpAddress(Request request) =>
      request.headers['X-Forwarded-For'] ??
      (request.context['shelf.io.connection_info']! as HttpConnectionInfo)
          .remoteAddress
          .address;

  _IpInfo _createInfo(String ip, DateTime now) => _IpInfo(
        now.add(_window),
        Timer(
          _window,
          () => _cache.remove(ip),
        ),
      );
}
