import 'dart:io';

import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;

class LoggingService {
  final Logger _logger = Logger('CalculaThor');

  static final LoggingService loggingService = LoggingService();

  LoggingService() {
    // * Setting up Logger
    Logger.root.level = Level.INFO;

    // * Print the log to the console
    Logger.root.onRecord.listen(
      (LogRecord record) => print(
        "[PROJECT ISHI] ${record.level.name}: ${record.time} ${record.message}",
      ),
    );
    Logger.root.onRecord.listen((LogRecord record) => _sendToLogstash(record));
  }

  void _sendToLogstash(LogRecord record) async {
    final logstashURI =
        Uri.https('project-ishi-logstash-wvxbmc25wq-el.a.run.app', '/');
    final logString =
        "[PROJECT ISHI] ${record.level.name}: ${record.time} ${record.message}";
    try {
      await http.post(logstashURI, body: logString);
    } catch (e) {}
  }

  void log(String operation) {
    String logMessage;

    logMessage = "$operation";

    _logger.info(logMessage);
  }
}
