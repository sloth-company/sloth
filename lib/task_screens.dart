



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sloth/home.dart';
import 'task.dart';
import 'categories.dart';
import 'hex_color.dart';
import 'package:flutter_datetime_formfield/flutter_datetime_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditTodoScreen extends StatefulWidget {
  final Task task;
  final AuthStatus authStatus;
  const EditTodoScreen({this.task, Key key, this.authStatus}): super(key: key);
  @override
  _EditTodoScreenState createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends State<EditTodoScreen> {
  String taskMainText;
  String taskDescription;
  final formKey = new GlobalKey<FormState>();
  //Category dropdownValue = _categories[0];
  Category dropdownValue;
//  print(dropdownValue.id);
//  print(dropdownValue.subject);
//  print(dropdownValue.color.value);
  DateTime dueDate;
  List <Category> catList=[];
  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      taskMainText = widget.task.taskName;
      taskDescription = widget.task.description;
      dropdownValue = widget.task.category;
      dueDate = widget.task.date;
    });
    print('initial value ' + dropdownValue.subject);
    print('initial value ' + dropdownValue.color.value.toRadixString(16));
    print('initial value ' + dropdownValue.id);
    super.initState();
  }
  void _editTodoItem(Task task){
    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('tasks').doc(task.id).set({
      'taskName': task.taskName,
      'category': task.category.id,
      'description': task.description,
      'dueDate': task.date,
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit Task'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: (){
                final form = formKey.currentState;
                if (form.validate()) {
                  form.save();
                  print(taskMainText);
                  print(taskDescription);
                  print(dropdownValue.subject);
                  print(dueDate);
                  _editTodoItem(Task(taskName: taskMainText, description: taskDescription, category: dropdownValue, date: dueDate, id: widget.task.id));
                  Navigator.pop(context);
                }
              },
            )
          ],
        ),
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                    initialValue: taskMainText,
                    validator: (value) => value.isEmpty ? 'Task can\'t be empty': null,
                    onSaved: (value) => taskMainText = value,
                    decoration: InputDecoration(
                        hintText: "Enter task...",
                        contentPadding: const EdgeInsets.all(16.0)
                    )
                ),
                TextFormField(
                    onSaved: (value) => taskDescription = value,
                    initialValue: taskDescription,
                    autocorrect: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 1,
                    decoration: InputDecoration(
                        hintText: "Enter description...",
                        contentPadding: const EdgeInsets.all(16.0)
                    )
                ),
                DateTimeFormField(
                  initialValue: dueDate,
                  label: "Due Date",
                  validator: (DateTime dateTime) {
                    if (dateTime == null) {
                      return "Due Date Required";
                    }
                    return null;
                  },
                  onSaved: (DateTime dateTime) => dueDate = dateTime,
                ),
                Padding(
                  padding: const EdgeInsets.all(100.0),
                  child: widget.authStatus == AuthStatus.notSignedIn ? SizedBox(width: 0, height: 0,): StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid)
                        .collection('master category list').snapshots(),
                    builder: (context, AsyncSnapshot snapshot){
                      if(!snapshot.hasData){
                        return Text("Loading");
                      }
                      else{
                        //List <Category> catList=[];
                        for(int i=0; i<snapshot.data.docs.length; i++){
                          DocumentSnapshot snap = snapshot.data.docs[i];
                          catList.add(
//                              DropdownMenuItem(
//                                child: Text(
//                                  snap['category'],
//                                  style: TextStyle(color: HexColor(snap['color'])),
//                                ),
//                                value: Category(subject: snap['category'], color: HexColor(snap['color']), id: snap.id),
//                              )
//                              {'display': snap['category'], 'value': Category(subject: snap['category'], color: HexColor(snap['color']), id: snap.id)}
                              new Category(subject: snap['category'], color: HexColor(snap['color']), id: snap.id)
                          );
                          print(snap['category']);
                          print(snap['color']);
                          print(snap.id);
//                          if(HexColor(snap['color']) == dropdownValue.color){
//                            print('same color');
//                          }
//                          if(snap['category'] == dropdownValue.subject){
//                            print('same category');
//                          }
//                          if(snap.id == dropdownValue.id){
//                            print('same id');
//                          }
                          if(HexColor(snap['color']) == dropdownValue.color && snap['category'] == dropdownValue.subject && snap.id == dropdownValue.id){
//                            setState(() {
//                              dropdownValue = widget.task.category;
//                            });
                            print('same everything');
                            print(snap['category']);
                            print(dropdownValue.subject);
                            print(snap['color']);
                            print(dropdownValue.color.value.toRadixString(16));
                            print(snap.id);
                            print(dropdownValue.id);

//                            dropdownValue = Category(subject: snap['category'], color: HexColor(snap['color']), id: snap.id);
                          }
                          if(Category(subject: snap['category'], color: HexColor(snap['color']), id: snap.id) == Category(subject: snap['category'], color: HexColor(snap['color']), id: snap.id)){
                            print('actually identical');
                          }
                          else{print('pain');}
                        }
                        return DropdownButtonFormField(
                          items: catList.map<DropdownMenuItem<Category>>((Category value) {
                            return DropdownMenuItem<Category>(
                              value: value,
                              child: Text(
                                value.subject,
                                style: TextStyle(color: value.color),
                              ),
                            );
                          }).toList(),
                          hint: Text("Please select a category"),
                          value: dropdownValue,
                          onChanged: (Category newValue) {
                            setState(() {
                              dropdownValue = newValue;
                            });
                          },
                          onSaved: (Category newValue) {
                            setState(() {
                              dropdownValue = newValue;
                            });
                          },
                          validator: (value) => dropdownValue == null ? 'Category can\'t be empty' : null,
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}

class AddTodoScreen extends StatefulWidget {
  final AuthStatus authStatus;
  const AddTodoScreen({Key key, this.authStatus}): super(key: key);
  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  String taskMainText;
  String taskDescription;
  final formKey = new GlobalKey<FormState>();
  //Category dropdownValue = _categories[0];
  Category dropdownValue;
//  print(dropdownValue.id);
//  print(dropdownValue.subject);
//  print(dropdownValue.color.value);
  DateTime dueDate;
  List <Category> catList=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  void _addTodoItem(Task task){
    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('tasks').add({
      'taskName': task.taskName,
      'category': task.category.id,
      'description': task.description,
      'dueDate': task.date,
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add New Task'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: (){
                final form = formKey.currentState;
                if (form.validate()) {
                  form.save();
                  print(taskMainText);
                  print(taskDescription);
                  print(dropdownValue.subject);
                  print(dueDate);
                  _addTodoItem(Task(taskName: taskMainText, description: taskDescription, date: dueDate, category: dropdownValue));
                  Navigator.pop(context);
                }
              },
            )
          ],
        ),
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                    initialValue: taskMainText,
                    validator: (value) => value.isEmpty ? 'Task can\'t be empty': null,
                    onSaved: (value) => taskMainText = value,
                    decoration: InputDecoration(
                        hintText: "Enter task...",
                        contentPadding: const EdgeInsets.all(16.0)
                    )
                ),
                TextFormField(
                    onSaved: (value) => taskDescription = value,
                    initialValue: taskDescription,
                    autocorrect: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 1,
                    decoration: InputDecoration(
                        hintText: "Enter description...",
                        contentPadding: const EdgeInsets.all(16.0)
                    )
                ),
                DateTimeFormField(
                  initialValue: dueDate,
                  label: "Due Date",
                  validator: (DateTime dateTime) {
                    if (dateTime == null) {
                      return "Due Date Required";
                    }
                    return null;
                  },
                  onSaved: (DateTime dateTime) => dueDate = dateTime,
                ),
                Padding(
                  padding: const EdgeInsets.all(100.0),
                  child: widget.authStatus == AuthStatus.notSignedIn ? SizedBox(width: 0, height: 0,): StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid)
                        .collection('master category list').snapshots(),
                    builder: (context, AsyncSnapshot snapshot){
                      if(!snapshot.hasData){
                        return Text("Loading");
                      }
                      else{
//                        List <Category> catList=[];
                        for(int i=0; i<snapshot.data.docs.length; i++){
                          DocumentSnapshot snap = snapshot.data.docs[i];
                          catList.add(
                              new Category(subject: snap['category'], color: HexColor(snap['color']), id: snap.id)
                          );
                          print(snap['category']);
                          print(snap['color']);
                          print(snap.id);

                        }
                        return DropdownButtonFormField(
                          items: catList.map<DropdownMenuItem<Category>>((Category value) {
                            return DropdownMenuItem<Category>(
                              value: value,
                              child: Text(
                                value.subject,
                                style: TextStyle(color: value.color),
                              ),
                            );
                          }).toList(),
                          hint: Text("Please select a category"),
                          value: dropdownValue,
                          onChanged: (Category newValue) {
                            setState(() {
                              dropdownValue = newValue;
                            });
                          },
                          onSaved: (Category newValue) {
                            setState(() {
                              dropdownValue = newValue;
                            });
                          },
                          validator: (value) => dropdownValue == null ? 'Category can\'t be empty' : null,
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}