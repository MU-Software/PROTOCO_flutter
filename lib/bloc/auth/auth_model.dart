import 'package:PROTOCO_flutter/storage/keystore.dart';
import 'package:flutter/foundation.dart';

class AuthData {
  String email = '';
  String userName = '';
  String nickName = '';
  String password = '';
  int userUUID = -1;

  AuthData({
    @required this.email,
    @required this.userName,
    @required this.nickName,
    @required this.password,
    @required this.userUUID,
  });

  AuthData.fromKVStore(KVStore kvStore) {
    this.email = kvStore.data['email'] ?? '';
    this.userName = kvStore.data['userName'] ?? '';
    this.nickName = kvStore.data['nickName'] ?? '';
    this.password = kvStore.data['password'] ?? '';
    this.userUUID = int.tryParse(kvStore.data['userUUID']) ?? -1;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    return data;
  }
}
