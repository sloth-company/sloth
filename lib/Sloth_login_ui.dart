import 'package:flutter/material.dart';
//import 'auth.dart';
//import 'root_page.dart';

class LoginPage extends StatefulWidget {
  //LoginPage({this.auth, this.onSignedIn});
  //final BaseAuth auth;
  //final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

enum FormType {
  login,
  register
}


class _LoginPageState extends State<LoginPage> {

  final formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  FormType _formType = FormType.login;

//  bool validateAndSave() {
//    final form = formKey.currentState;
//    if (form.validate()) {
//      form.save();
//      return true;
//    }
//    return false;
//  }

//  void validateAndSubmit() async {
//    if (validateAndSave()) {
//      try {
//        if (_formType == FormType.login) {
//          String userId = await widget.auth.signInWithEmailAndPassword(_email, _password);
//          print('Signed in: $userId');
//        } else {
//          String userId = await widget.auth.createUserWithEmailAndPassword(_email, _password);
//          print('Signed in: $userId');
//        }
//        widget.onSignedIn();
//      }
//      catch (e) {
//        print('Error: $e');
//      }
//    }
//  }

  void moveToRegister() {
//reset contents of form
    formKey.currentState.reset();
    setState((){
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    setState(() {
      _formType = FormType.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(
            "Sloth " + (_formType == FormType.login ? "Login":"Sign Up"),
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
        ),
        body: new Container(
            padding: EdgeInsets.all(16.0),
            child: new Form(
              key: formKey,
              child: new SingleChildScrollView(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Image(
                      image: AssetImage('assets/Sloth_temp_logo.jpg'),
                      height: 200,
                      width: 200,
                    ),
                  ] + buildInputs() + buildSubmitButtons(),
                ),
              ),
            )
        )
    );

  }
  List<Widget> buildInputs() {
    return [
      new TextFormField(
        decoration: new InputDecoration(labelText: 'Email'),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty': null,
        onSaved: (value) => _email = value,
      ),
      new TextFormField(
        decoration: new InputDecoration(labelText: 'Password'),
        obscureText: true,
        validator: (value) => value.isEmpty ? 'Password can\'t be empty': null,
        onSaved: (value) => _password = value,
      ),
    ];
  }
  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return [
        new RaisedButton(
          child: new Text('Login', style: new TextStyle(fontSize: 20.0)),
          onPressed: (){
            if(formKey.currentState.validate()){
              formKey.currentState.save();
              print(_email);
              print(_password);
              Navigator.pop(context);
            }
          },
          //validateAndSubmit,
        ),
        new FlatButton(
          child: new Text('Create an account', style: new TextStyle(fontSize: 20.0)),
          onPressed: moveToRegister,
        )
      ];
    } else {
      return [
        new RaisedButton(
          child: new Text('Create an account', style: new TextStyle(fontSize: 20.0)),
          onPressed: (){
            if(formKey.currentState.validate()){
              formKey.currentState.save();
              print(_email);
              print(_password);
              Navigator.pop(context);
            }
          },
          //validateAndSubmit,
        ),
        new FlatButton(
          child: new Text('Have an account? Login', style: new TextStyle(fontSize: 20.0)),
          onPressed: moveToLogin,
        )
      ];
    }
  }
}