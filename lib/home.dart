//import 'dart:html';

//import 'dart:html';



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sloth/category_screens.dart';
import 'package:sloth/task_screens.dart';
import 'task.dart';
import 'categories.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'hex_color.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter_datetime_formfield/flutter_datetime_formfield.dart';
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
  //User user;
  int _currentIndex = 0;
  initState() {
    super.initState();
    if(FirebaseAuth.instance.currentUser != null){
        setState(() {
          authStatus = AuthStatus.signedIn;
          //Stream categoriesStream = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('master category list').snapshots();
          //user = FirebaseAuth.instance.currentUser;
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
//    FirebaseFirestore.instance
//        .collection('master lms list')
//        .doc('Canvas')
//        .get()
//        .then((DocumentSnapshot documentSnapshot) {
//      if (documentSnapshot.exists) {
//        print('Document exists on the database');
//        print(documentSnapshot.id);
//      }
//      else {
//        print('sad');
//      }
//    });
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState.openDrawer();
  }

  void _closeDrawer() {
    Navigator.of(context).pop();
  }
  void _removeTodoItem(String id) {
    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('tasks').doc(id).delete();
  }

// Show an alert dialog asking the user to confirm that the task is done
  void _promptRemoveTodoItem(Task task) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('Mark "${task.taskName}" as done?'),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('CANCEL'),
                    onPressed: () => Navigator.of(context).pop()
                ),
                new FlatButton(
                    child: new Text('MARK AS DONE'),
                    onPressed: () {
                      _removeTodoItem(task.id);
                      Navigator.of(context).pop();
                    }
                )
              ]
          );
        }
    );
  }

  Widget _buildTodoList() {
    return authStatus != AuthStatus.signedIn ? Container(child: Text('please sign in'),) : StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('tasks').orderBy('dueDate', descending: false).snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          return StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').doc(
                  FirebaseAuth.instance.currentUser.uid).collection(
                  'master category list').snapshots(),
              builder: (context, AsyncSnapshot catSnapshot) {
                List taskList = [];
                for (int i = 0; i < snapshot.data.docs.length; i++) {
                  Category category;
                  DocumentSnapshot snap = snapshot.data.docs[i];
                  for(int j = 0; j < catSnapshot.data.docs.length; j++) {
                    DocumentSnapshot catSnap = catSnapshot.data.docs[j];
//                    print('id:' + catSnap.id);
//                    print(catSnap['category']);
                    if(catSnapshot.data.docs[j].id == snap['category']) {
//                      print('id:' + catSnap.id);
//                      print(catSnap['category']);
                      category = new Category(
                          subject: catSnap['category'],
                          color: HexColor(catSnap['color']),
                          id: catSnap.id);
                    }
                    else{print('failed');}
                  }
                  taskList.add(
                      Task(taskName: snap['taskName'],
                          description: snap['description'],
                          id: snap.id,
                          category: category,
                          date: DateTime.parse(
                              snap['dueDate'].toDate().toString())
                      )
                  );
                }
                return new ListView.builder(
                  // ignore: missing_return
                  itemBuilder: (context, index) {
                    if (index < taskList.length) {
                      return _buildTodoItem(taskList[index],);
                    }
                  },
                );
              }

          );
        }
    );
  }

  Widget _buildTodoItem(Task todoTask,) {

    return Card(
//      child: ListTile(
//        title: Text(todoTask.taskName),
//        subtitle: Text(
//          todoTask.category.subject,
//          style: TextStyle(
//              //color: todoTask.category.color
//          ),
//        ),
//        onTap: () => _promptRemoveTodoItem(todoTask),
//        trailing: IconButton(
//          onPressed: () => _pushEditTodoScreen(todoTask),
//          icon: Icon(Icons.create),
//        ),
//      ),
//      color: todoTask.category.color,
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: todoTask.category.color,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todoTask.taskName,
                  ),
                  Text(
                    todoTask.description,
                  ),
                  Text(
                    todoTask.category.subject,
                  ),
                  Text(
                    todoTask.date.toString(),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 80,
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () => _promptRemoveTodoItem(todoTask),
            ),
          ),
          Positioned(
            right: 15,
            top: 15,
            child: IconButton(
                icon: Icon(Icons.create),
                onPressed: () => _pushEditTodoScreen(todoTask),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return authStatus != AuthStatus.signedIn ? Container(child: Text('please sign in'),) : StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('master category list').snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          List categoryList = [];
          for(int i=0; i<snapshot.data.docs.length; i++){
            DocumentSnapshot snap = snapshot.data.docs[i];
            categoryList.add(Category(subject: snap['category'], color: HexColor(snap['color']), id: snap.id));
          }
          return new ListView.builder(
            // ignore: missing_return
            itemBuilder: (context, index) {
              if (index < categoryList.length) {
                return _buildCategory(categoryList[index]);
              }
            },
          );
        }
    );
  }

  Widget _buildCategory(Category category) {
    return Card(
      child: new ListTile(
        title: new Text(
          category.subject,
          style: TextStyle(color: category.color),
        ),
        trailing: IconButton(
          onPressed: () => _pushEditCategoryScreen(category),
          icon: Icon(Icons.create),

        ),
      ),
    );
  }


  void _pushEditTodoScreen(Task task){
    Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (context) {
              return EditTodoScreen(task: task, authStatus: authStatus,);
            }
        )
    );
  }
  void _pushAddTodoScreen(){
    Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (context) {
              return AddTodoScreen(authStatus: authStatus,);
            }
        )
    );
  }
  void _pushAddCategoryScreen(){
    Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (context) {
              return AddCategoryScreen();
            }
        )
    );
  }
  void _pushEditCategoryScreen(Category category){
    Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (context) {
              return EditCategoryScreen(category: category,);
            }
        )
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