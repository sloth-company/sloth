import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
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

Stream firestoreStreamLMS() => FirebaseFirestore.instance.collection("master lms list").snapshots();

class _LoginPageState extends State<LoginPage> {

  final formKey = new GlobalKey<FormState>();
  //final Stream firestoreStream = FirebaseFirestore.instance.collection("master lms list").snapshots();
  final Stream _firestoreStreamLMS = firestoreStreamLMS();
  String _email;
  String _password;
  FormType _formType = FormType.login;
  String dropdownValueLMS;
  String dropdownValueSchool;

  void initState(){
    super.initState();
    setState(() {
      dropdownValueSchool = null;
    });
  }

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
          final User user = FirebaseAuth.instance.currentUser;
          CollectionReference users = FirebaseFirestore.instance.collection('users');
          users.doc(user.uid).set({
            'email': _email,
            'lms': dropdownValueLMS,
            'school': dropdownValueSchool,
          });
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

  void removeSchool(){
    setState(() {
      dropdownValueLMS = null;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Sloth " + (_formType == FormType.login ? "Login":"Sign Up"),
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
        ),
        body: Container(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
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
        stream: _firestoreStreamLMS,
        builder: (context, AsyncSnapshot snapshot){
          if(!snapshot.hasData){
            return Text("Loading");
          }
          else{
            List lmsList=[];
            for(int i=0; i<snapshot.data.docs.length; i++){
              DocumentSnapshot snap = snapshot.data.docs[i];
              lmsList.add(
                {'display': snap.id, 'value': snap.id}
              );
            }
            return DropDownFormField(
              dataSource: lmsList,
              titleText: "Learning Management System",
              hintText: "Please select the one your school uses",
              value: dropdownValueLMS,
              onChanged: (newValue) {
//                setState(() {
//                  removeSchool();
//                });
                setState(() {
                  dropdownValueLMS = newValue;
                  dropdownValueSchool = null;
                });
//                setState(() {
//                  dropdownValueLMS = null;
//                });
              },
              onSaved: (newValue) {
//                setState(() {
//                  removeSchool();
//                });
                setState(() {
                  dropdownValueLMS = newValue;
                });
              },
              textField: 'display',
              valueField: 'value',
              validator: (value) => dropdownValueLMS == null ? 'LMS can\'t be empty; select \"other\" if your school doesn\'t use one' : null,
            );
          }
        },
      ),
      _formType == FormType.login || dropdownValueLMS == null ? new SizedBox(width: 0, height: 0,): new StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('master lms list/$dropdownValueLMS/schools').snapshots(),
        builder: (context, AsyncSnapshot snapshot){
          if(!snapshot.hasData){
            return Text("Loading");
          }
          else{
            List schoolList=[];
            for(int i=0; i<snapshot.data.docs.length; i++){
              DocumentSnapshot snap = snapshot.data.docs[i];
              schoolList.add(
                  {'display': snap.id, 'value': snap.id}
              );
            }
            return DropDownFormField(
              dataSource: schoolList,
              titleText: "School",
              hintText: "Please select your school",
              value: dropdownValueSchool,
              onChanged: (newValue) {
                setState(() {
                  dropdownValueSchool = newValue;
                });
              },
              onSaved: (newValue) {
                setState(() {
                  dropdownValueSchool = newValue;
                });
              },
              textField: 'display',
              valueField: 'value',
              validator: (value) => dropdownValueSchool == null ? 'School can\'t be empty' : null,
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