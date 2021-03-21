class ExcMsg implements Exception {
  final String showingMessage;
  String debugMessage;

  ExcMsg(this.showingMessage, {this.debugMessage});

  get debugMsg => this.debugMessage ?? this.showingMessage;
}
