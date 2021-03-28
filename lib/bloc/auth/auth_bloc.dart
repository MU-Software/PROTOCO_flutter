import 'package:flutter_bloc/flutter_bloc.dart';

import './auth_model.dart';
import './auth_event.dart';
import './auth_state.dart';
import 'package:PROTOCO_flutter/storage/keystore.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(KVStore kvStore) : super(AuthState(authData: AuthData.fromKVStore(kvStore)));

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is AuthSignUpEvent) {
      try {
        // Create Request body
      } catch (e) {
        yield AuthFailState('INTERNET_CONNECTION_FAILED');
      }
    }
    if (event is AuthSignInEvent) {
      // yield AuthSignInState();
    }
    if (event is AuthSignOutEvent) {
      // yield AuthSignOutState();
    }
  }
}
