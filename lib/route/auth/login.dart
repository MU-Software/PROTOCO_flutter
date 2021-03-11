import 'package:flutter/material.dart';

class AccountLoginRoute extends StatelessWidget {
  // LoginPage({Key key}) : super(key: key);

  final idInputController = TextEditingController();
  final passwordInputController = TextEditingController();

  void doLogin(BuildContext context) {
    final String resultText = 'ID : ' + idInputController.text + ', PW : ' + passwordInputController.text;

    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("My title"),
      content: Text(resultText),
      actions: [
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        leading: null,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: idInputController,
              decoration: InputDecoration(labelText: 'Email or ID'),
            ),
            TextField(
              controller: passwordInputController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              child: Text('Login'),
              onPressed: () {
                doLogin(context);
              },
            ),
            TextButton(
              child: Text('Create account'),
              onPressed: () => Navigator.of(context).pushNamed('/auth/create'),
            ),
            TextButton(
              child: Text('Forgot password?'),
              onPressed: () => Navigator.of(context).pushNamed('/auth/find-password'),
            ),
          ],
        ),
      ),
    );
  }
}
