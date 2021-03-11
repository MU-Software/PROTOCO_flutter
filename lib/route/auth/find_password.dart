import 'package:flutter/material.dart';

class AccountFindPasswordRoute extends StatelessWidget {
  final emailInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create account'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Enter your email address,\n'
              'and we\'ll send a link to choose a new password',
              textAlign: TextAlign.center,
            ),
            TextField(
              controller: emailInputController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            ElevatedButton(
              child: Text('Send password reset link'),
              onPressed: () {},
            ),
            TextButton(
              child: Text('Back to sign-in'),
              onPressed: () =>
                  Navigator.of(context).pushNamedAndRemoveUntil('/auth/login', (Route<dynamic> route) => false),
            ),
          ],
        ),
      ),
    );
  }
}
