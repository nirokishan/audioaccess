import 'package:flutter/material.dart';

import 'audio.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter audio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed:(){
                String username =_usernameController.text;
                String password =_passwordController.text;
                if(username=="admin" && password=="admin"){
                  Navigator.push(context,
                  MaterialPageRoute(builder: ((context) => MyHomePage())
                  ),);
                }else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:Text("invalid password"),
                      duration: Duration(seconds: 1),
                    ));
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}






