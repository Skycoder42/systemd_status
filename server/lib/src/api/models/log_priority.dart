import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'level')
enum LogPriority {
  emergency('0'),
  alert('1'),
  critical('2'),
  error('3'),
  warning('4'),
  notice('5'),
  informational('6'),
  debug('7');

  final String level;

  const LogPriority(this.level);

  static String stringify(LogPriority p) => p.name;

  static LogPriority parse(String p) => LogPriority.values.byName(p);
}
