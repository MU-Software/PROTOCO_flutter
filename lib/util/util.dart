class ExcMsg implements Exception {
  final String showingMessage;
  String debugMessage;
  dynamic exception;
  StackTrace stackTrace;

  ExcMsg(this.showingMessage, {this.debugMessage, this.exception, this.stackTrace});

  get debugMsg => this.debugMessage ?? this.showingMessage;
}
