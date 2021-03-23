//import 'dart:html';

//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'task.dart';
import 'categories.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'hex_color.dart';
class TodoList extends StatefulWidget {
  TodoList({Key key, this.title,}) : super(key: key);
  //TodoList({Key key, this.title, this.firestore}) : super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String title;
  //final FirebaseFirestore firestore;

  @override
  _TodoListState createState() => _TodoListState();
}

enum AuthStatus {
  notSignedIn,
  signedIn
}


class _TodoListState extends State<TodoList> {

  AuthStatus authStatus = AuthStatus.notSignedIn;


  initState() {
    super.initState();
    if(FirebaseAuth.instance.currentUser != null){
        setState(() {
          authStatus = AuthStatus.signedIn;
          //Stream categoriesStream = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('master category list').snapshots();
        });
    }
    else{
      authStatus = AuthStatus.notSignedIn;
    }
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User user) {
      if (user == null) {
        print('User is currently signed out!');
        setState(() {
          authStatus = AuthStatus.notSignedIn;
        });
      } else {
        print('User is signed in!');
        setState(() {
          authStatus = AuthStatus.signedIn;
        });
      }
    });
    print("state refreshed");
    FirebaseFirestore.instance
        .collection('master lms list')
        .doc('Canvas')
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document exists on the database');
        print(documentSnapshot.id);
      }
      else {
        print('sad');
      }
    });
  }
  List<Task> _todoItems = [];
  List<Category> _categories = [Category(), Category(subject: "Math", color: Colors.lightBlueAccent)];
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState.openDrawer();
  }

  void _closeDrawer() {
    Navigator.of(context).pop();
  }
  void _removeTodoItem(int index) {
    setState(() => _todoItems.removeAt(index));
  }

// Show an alert dialog asking the user to confirm that the task is done
  void _promptRemoveTodoItem(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('Mark "${_todoItems[index]}" as done?'),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('CANCEL'),
                    onPressed: () => Navigator.of(context).pop()
                ),
                new FlatButton(
                    child: new Text('MARK AS DONE'),
                    onPressed: () {
                      _removeTodoItem(index);
                      Navigator.of(context).pop();
                    }
                )
              ]
          );
        }
    );
  }

  Widget _buildTodoList() {
    return new ListView.builder(
      // ignore: missing_return
      itemBuilder: (context, index) {
        if (index < _todoItems.length) {
          return _buildTodoItem(_todoItems[index], index);
        }
      },
    );
  }

  Widget _buildTodoItem(Task todoTask, int index) {
    return Card(
      child: ListTile(
        title: Text(todoTask.taskName),
        subtitle: Text(
          todoTask.category.subject,
          style: TextStyle(color: todoTask.category.color),
        ),
        onTap: () => _promptRemoveTodoItem(index),
        trailing: RaisedButton(
          onPressed: () => _pushEditTodoScreen(todoTask, index),
        ),
      ),
    );
  }

  void _addTodoItem(String task){
    setState(() {
      _todoItems.add(Task(taskName: task, category: dropdownValue == null ? _categories[0]:dropdownValue));
    });
  }
  void _editTodoItem(Task task, int index){
    setState(() {
      _todoItems[index] = task;
    });
  }
  Widget _buildCategoryList() {
    return authStatus != AuthStatus.signedIn ? Container(child: Text('please sign in'),) : StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('master category list').snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          List categoryList = [];
          for(int i=0; i<snapshot.data.docs.length; i++){
            DocumentSnapshot snap = snapshot.data.docs[i];
            categoryList.add(Category(subject: snap.id, color: HexColor(snap['color'])));
          }
          return new ListView.builder(
            // ignore: missing_return
            itemBuilder: (context, index) {
              if (index < categoryList.length) {
                return _buildCategory(categoryList[index], index);
              }
            },
          );
        }
    );
//    return new ListView.builder(
//      // ignore: missing_return
//      itemBuilder: (context, index) {
//        if (index < _categories.length - 1) {
//          return _buildCategory(_categories[index + 1], index);
//        }
//      },
//    );
  }

  Widget _buildCategory(Category category, int index) {
    return Card(
      child: new ListTile(
        title: new Text(
          category.subject,
          style: TextStyle(color: category.color),
        ),
        trailing: RaisedButton(
          onPressed: () => _pushEditCategoryScreen(category, index),
        ),
      ),
    );
  }

  void _addCategory(Category category){
    setState(() {
      _categories.add(category);
    });
  }

  void _editCategory(Category category, int index){
    setState(() {
      _categories[index + 1] = category;
    });
  }

  Category dropdownValue;
  void _pushAddTodoScreen(){
    bool checkIsPressable = false;
    String taskMainText;
    //Category dropdownValue = _categories[0];
    dropdownValue = null;
    Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (context) {
              return new Scaffold(
                  appBar: AppBar(
                    title: Text('Add New Task'),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: (){
                          if (checkIsPressable){
                            _addTodoItem(taskMainText);
                            Navigator.pop(context);
                          }
                        },
                      )
                    ],
                  ),
                  body: Column(
                    children: <Widget>[
                      TextField(
                          autofocus: true,
                          onSubmitted: (val) {
                            taskMainText = val;
                            checkIsPressable = true;
                          },
                          decoration: InputDecoration(
                              hintText: "Enter task...",
                              contentPadding: const EdgeInsets.all(16.0)
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.all(100.0),
                        child: DropdownButton(
                          hint: Text(
                            dropdownValue == null ? "Choose Category":dropdownValue.subject,
                            style: TextStyle(color: dropdownValue == null ? Colors.deepPurple:dropdownValue.color),
                          ),
                          value: dropdownValue,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.deepPurple),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (newValue) {
                            setState(() {
                              dropdownValue = newValue;
                            });
                          },
                          items: _categories.map<DropdownMenuItem> ((value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(
                                value.subject,
                                style: TextStyle(color: value.color),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  )
              );
            }
        )
    );
  }

  void _pushEditTodoScreen(Task todoTask, int index){
    bool checkIsPressable = false;
    String taskMainText;
    dropdownValue = todoTask.category;
    Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (context) {
              return new Scaffold(
                  appBar: AppBar(
                    title: Text('Edit Task'),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: (){
                          if (checkIsPressable){
                            _editTodoItem(Task(taskName: taskMainText, category: dropdownValue), index);
                            Navigator.pop(context);
                          }
                        },
                      )
                    ],
                  ),
                  body: Column(
                    children: <Widget>[
                      TextFormField(
                          autofocus: true,
                          initialValue: todoTask.taskName,
                          onFieldSubmitted: (val) {
                            taskMainText = val;
                            checkIsPressable = true;
                          },
                          decoration: InputDecoration(
                              hintText: "Enter task...",
                              contentPadding: const EdgeInsets.all(16.0)
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.all(100.0),
                        child: DropdownButton(
                          hint: Text(
                            dropdownValue == null ? "Choose Category":dropdownValue.subject,
                            style: TextStyle(color: dropdownValue == null ? Colors.deepPurple:dropdownValue.color),
                          ),
                          value: dropdownValue,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.deepPurple),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (newValue) {
                            setState(() {
                              dropdownValue = newValue;
                            });
                          },
                          items: _categories.map<DropdownMenuItem> ((value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(
                                value.subject,
                                style: TextStyle(color: value.color),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  )
              );
            }
        )
    );
  }

  void _pushAddCategoryScreen(){
    currentColor = Colors.grey;
    pickerColor = Colors.grey;
    Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (context) {
              return new Scaffold(
                  appBar: AppBar(
                      title: Text('Add New Category')
                  ),
                  body: Column(
                    children: <Widget>[
                      TextField(
                          autofocus: true,
                          onSubmitted: (val) {
                            _addCategory(Category(subject: val, color: currentColor));
                            Navigator.pop(context);
                          },
                          decoration: InputDecoration(
                              hintText: "Enter task...",
                              contentPadding: const EdgeInsets.all(16.0)
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.all(100.0),
                        child: RaisedButton(
                          color: currentColor,
                          onPressed: () => _showMaterialDialog(),
                          child: Text(
                            "Choose Color",
                          ),
                        ),
                      ),
                    ],
                  )
              );
            }
        )
    );
  }

  void _pushEditCategoryScreen(Category category, int index){
    pickerColor = category.color;
    currentColor = category.color;
    Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (context) {
              return new Scaffold(
                  appBar: AppBar(
                      title: Text('Edit Category')
                  ),
                  body: Column(
                    children: <Widget>[
                      TextFormField(
                          autofocus: true,
                          initialValue: category.subject,
                          onFieldSubmitted: (val) {
                            _editCategory(Category(subject: val, color: currentColor), index);
                            Navigator.pop(context);
                          },
                          decoration: InputDecoration(
                              hintText: "Enter task...",
                              contentPadding: const EdgeInsets.all(16.0)
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.all(100.0),
                        child: RaisedButton(
                          color: currentColor,
                          onPressed: () => _showMaterialDialog(),
                          child: Text(
                            "Choose Color",
                          ),
                        ),
                      ),
                    ],
                  )
              );
            }
        )
    );
  }

  // create some values
  Color pickerColor;
  Color currentColor;

// ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }
  _showMaterialDialog(){
    showDialog(
      context: context,
      child: AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
          // Use Material color picker:
          //
          // child: MaterialPicker(
          //   pickerColor: pickerColor,
          //   onColorChanged: changeColor,
          //   showLabel: true, // only on portrait mode
          // ),
          //
          // Use Block color picker:
          //
          // child: BlockPicker(
          //   pickerColor: currentColor,
          //   onColorChanged: changeColor,
          // ),
          //
          // child: MultipleChoiceBlockPicker(
          //   pickerColors: currentColors,
          //   onColorsChanged: changeColors,
          // ),
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('Got it'),
            onPressed: () {
              setState(() => currentColor = pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    List<AppBar> appBars = [
      AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.collections_bookmark,
            color: Colors.white,
          ),
          onPressed: () {
            _openDrawer();
            print("should have opened");
          },
        ),
        title: Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              authStatus == AuthStatus.signedIn ? FirebaseAuth.instance.currentUser.email:"",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
//          FutureBuilder(
//            future: FirebaseFirestore.instance.collection("testing").doc('bruh').get(),
//            builder: (context, snapshot){
//              if(!snapshot.hasData){
//                return Text("Loading");
//              }
//              else{
//                return Expanded(child: Text(snapshot.data.id));
//              }
//            }
//          ),
          IconButton(
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            onPressed: authStatus == AuthStatus.notSignedIn ? () => Navigator.pushNamed(context, '/login'): () async {
              await FirebaseAuth.instance.signOut();
//              DocumentSnapshot snap = await FirebaseFirestore.instance.collection('testing').doc('bruh').get();
//              print('${snap.id}');
            },
          ),
        ],
      ),
      AppBar(
        title: Text(
          'All Tasks',
          style: TextStyle(color: Colors.white),
        ),
      ),
      AppBar(
        title: Text(
          'Calendar',
          style: TextStyle(color: Colors.white),
        ),
      ),
      AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
    ];
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBars[_currentIndex],
      body: _buildTodoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _pushAddTodoScreen,
        tooltip: 'New Task',
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        iconSize: 20,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.grey[200],
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: "Home",
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: "Tasks",
            icon: Icon(Icons.format_list_numbered),
          ),
          BottomNavigationBarItem(
            label: "Calendar",
            icon: Icon(Icons.calendar_today),
          ),
          BottomNavigationBarItem(
            label: "Profile",
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
      drawer: Drawer(
        child: Scaffold(
            appBar: AppBar(
              title: Text("Categories"),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _pushAddCategoryScreen,
                )
              ],
            ),
            body: _buildCategoryList()),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}