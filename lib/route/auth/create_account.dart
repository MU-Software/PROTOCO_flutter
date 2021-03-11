import 'package:flutter/material.dart';

class AccountCreateRoute extends StatefulWidget {
  AccountCreateRoute() : super();

  @override
  AccountCreateRouteState createState() => AccountCreateRouteState();
}

class AccountCreateRouteState extends State<AccountCreateRoute> {
  final emailInputController = TextEditingController();
  final idInputController = TextEditingController();
  final nicknameInputController = TextEditingController();
  final passwordInputController = TextEditingController();
  final passwordRetypeInputController = TextEditingController();

  bool isPasswordConfirmed = false;

  void createAccount(BuildContext context) {
    if (passwordInputController.text != passwordRetypeInputController.text) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DEVCO!'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailInputController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: idInputController,
              decoration: InputDecoration(labelText: 'ID'),
            ),
            TextField(
              controller: nicknameInputController,
              decoration: InputDecoration(labelText: 'Nickname'),
            ),
            TextField(
              controller: passwordInputController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: passwordRetypeInputController,
              decoration: InputDecoration(labelText: 'Confirm'),
              obscureText: true,
              onChanged: (String passwordConfirmString) {
                if (passwordConfirmString.isNotEmpty && passwordConfirmString == passwordInputController.text) {
                  setState(() {
                    this.isPasswordConfirmed = true;
                  });
                } else {
                  setState(() {
                    this.isPasswordConfirmed = false;
                  });
                }
              },
            ),
            Text(isPasswordConfirmed ? 'Those passwords didn\'t match. Try again' : ''),
            ElevatedButton(
              child: Text('Create account'),
              onPressed: isPasswordConfirmed
                  ? () {
                      createAccount(context);
                    }
                  : null,
            ),
            TextButton(
              child: Text('Sign in instead'),
              onPressed: () =>
                  Navigator.of(context).pushNamedAndRemoveUntil('/auth/login', (Route<dynamic> route) => false),
            ),
          ],
        ),
      ),
    );
  }
}
