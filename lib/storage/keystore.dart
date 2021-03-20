import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KVStore {
  FlutterSecureStorage storage;
  Map<String, String> data;

  bool isCalledOnce = false;
  bool isInitialized = false;

  // Singleton
  static final KVStore _instance = KVStore._internal();

  // Initializer
  KVStore._internal() {
    this.storage = FlutterSecureStorage();
  }

  // Singleton caller
  factory KVStore() {
    if (_instance.isCalledOnce && !_instance.isInitialized) {
      throw Exception('Please initialize on first call!');
    }
    _instance.isCalledOnce = true;
    return _instance;
  }

  void operator []=(String key, String value) {
    this.data[key] = value;
    this.storage.write(key: key, value: value);
  }

  Future<KVStore> init() async {
    _instance.isInitialized = true;
    _instance.data = await storage.readAll();
    return _instance;
  }
}
