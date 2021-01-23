import 'package:flutter/material.dart';
import 'task.dart';
import 'categories.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
void main() {
  runApp(new TodoApp());
}

class TodoApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Things to Get Done',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.orange,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: new TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  TodoList({Key key, this.title}) : super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String title;

  @override
  _TodoListState createState() => _TodoListState();
}




class _TodoListState extends State<TodoList> {
  List<Task> _todoItems = [];
  List<Category> _categories = [Category(), Category(subject: "Math", color: Colors.lightBlueAccent)];

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
          onTap: () => _promptRemoveTodoItem(index)
      ),
    );
  }

  void _addTodoItem(String task){
    setState(() {
      _todoItems.add(Task(taskName: task, category: dropdownValue == null ? _categories[0]:dropdownValue));
    });
  }

  Widget _buildCategoryList() {
    return new ListView.builder(
      // ignore: missing_return
      itemBuilder: (context, index) {
        if (index < _categories.length - 1) {
          return _buildCategory(_categories[index + 1], index);
        }
      },
    );
  }

  Widget _buildCategory(Category category, int index) {
    return Card(
      child: new ListTile(
        title: new Text(
          category.subject,
          style: TextStyle(color: category.color),
        ),
      ),
    );
  }

  void _addCategory(Category task){
    setState(() {
      _categories.add(task);
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
  void _pushAddCategoryScreen(){
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
  // create some values
  Color pickerColor = Colors.grey;
  Color currentColor = Colors.grey;

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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.collections_bookmark, color: Colors.white,),
          onPressed: () { _openDrawer(); print("should have opened");},
        ),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(
            'Things to Get Done!',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _buildTodoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _pushAddTodoScreen,
        tooltip: 'New Task',
        child: Icon(Icons.add, color: Colors.white,),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        iconSize: 20,
        backgroundColor: Colors.grey[200],
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem> [
          BottomNavigationBarItem(
            title: Text("Home"),
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            title: Text("Tasks"),
            icon: Icon(Icons.format_list_numbered),
          ),
          BottomNavigationBarItem(
            title: Text("Calendar"),
            icon: Icon(Icons.calendar_today),
          ),
          BottomNavigationBarItem(
            title: Text("Profile"),
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
            body: _buildCategoryList()
        ),

      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}