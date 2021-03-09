import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'auth.dart';
//import 'root_page.dart';

////////////////////////////////////////////////////////////////////////////////
//for testing: nathanjw50@gmail.com, testingpassword
////////////////////////////////////////////////////////////////////////////////

class LoginPage extends StatefulWidget {
  //LoginPage({this.auth, this.onSignedIn});
  //final BaseAuth auth;
  //final VoidCallback onSignedIn;
  //LoginPage({this.firestore});
  //FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

enum FormType {
  login,
  register
}

Stream firestoreStream() => FirebaseFirestore.instance.collection("master lms list").snapshots();

class _LoginPageState extends State<LoginPage> {

  final formKey = new GlobalKey<FormState>();
  //final Stream firestoreStream = FirebaseFirestore.instance.collection("master lms list").snapshots();
  final Stream _firestoreStream = firestoreStream();
  String _email;
  String _password;
  FormType _formType = FormType.login;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password);
          //print('Signed in: $userId');
          print(_email);
          print(_password);
          Navigator.pop(context);
        } else {
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password);
          // print('Signed in: $userId');
          print(_email);
          print(_password);
          Navigator.pop(context);
        }
        //widget.onSignedIn();
      }
      catch (e) {
        print('Error: $e');
      }
    }
  }

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
      _formType == FormType.login ? SizedBox(width: 0, height: 0,): StreamBuilder<QuerySnapshot>(
        stream: _firestoreStream,
        builder: (context, AsyncSnapshot snapshot){
          if(!snapshot.hasData){
            return Text("Loading");
          }
          else{
            List<DropdownMenuItem> lmsList=[];
            String dropdownValue;
            for(int i=0; i<snapshot.data.docs.length; i++){
              DocumentSnapshot snap = snapshot.data.docs[i];
              lmsList.add(
                DropdownMenuItem(
                  child: Text(
                    snap.id,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  value: "${snap.id}",
                )
              );
            }
            return DropdownButton(
              items: lmsList,
              hint: Text(
                "Select your school's Learning Management System",
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              icon: Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Theme.of(context).primaryColor),
              underline: Container(
                height: 2,
                color: Theme.of(context).primaryColor,
              ),
              value: dropdownValue,
              onChanged: (newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
              },
            );
          }
        },
      ),
    ];
  }
  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return [
        new RaisedButton(
          child: new Text('Login', style: new TextStyle(fontSize: 20.0)),
//          onPressed: (){
//            if(formKey.currentState.validate()){
//              formKey.currentState.save();
//              print(_email);
//              print(_password);
//              Navigator.pop(context);
//            }
//          },
          onPressed: validateAndSubmit,
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
//          onPressed: (){
//            if(formKey.currentState.validate()){
//              formKey.currentState.save();
//              print(_email);
//              print(_password);
//              Navigator.pop(context);
//            }
//          },
          onPressed: validateAndSubmit,
        ),
        new FlatButton(
          child: new Text('Have an account? Login', style: new TextStyle(fontSize: 20.0)),
          onPressed: moveToLogin,
        )
      ];
    }
  }
}