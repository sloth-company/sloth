import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'task.dart';
import 'categories.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'hex_color.dart';

class AddCategoryScreen extends StatefulWidget {
  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  Color currentColor = Colors.grey;
  Color pickerColor = Colors.grey;
  String categoryName;
  final formKey = new GlobalKey<FormState>();
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
  void _addCategory(Category category){
//    setState(() {
//      _categories.add(category);
//    });
    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('master category list').add({'category': category.subject, 'color': currentColor.value.toRadixString(16)});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Add New Category'),
          actions: [
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                final form = formKey.currentState;
                if (form.validate()) {
                  form.save();
                  _addCategory(Category(subject: categoryName, color: currentColor));
                  Navigator.pop(context);
                }
              }
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Form(
              key: formKey,
              child: TextFormField(
                  onSaved: (val) => categoryName = val,
                  validator: (value) => value.isEmpty ? 'Category can\'t be empty': null,
                  decoration: InputDecoration(
                      hintText: "Enter category...",
                      contentPadding: const EdgeInsets.all(16.0)
                  )
              ),
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
}

class EditCategoryScreen extends StatefulWidget {
  final Category category;
  const EditCategoryScreen({this.category, Key key}): super(key: key);
  @override
  _EditCategoryScreenState createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  Color currentColor;
  Color pickerColor;
  String categoryName;
  final formKey = new GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      currentColor = widget.category.color;
      pickerColor = widget.category.color;
      categoryName = widget.category.subject;
    });
    super.initState();
  }
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
  void _editCategory(Category category){
    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('master category list')
        .doc(category.id).set({'color': category.color.value.toRadixString(16), 'category': category.subject});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit Category'),
          actions: [
            IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  final form = formKey.currentState;
                  if (form.validate()) {
                    form.save();
                    _editCategory(Category(subject: categoryName, color: currentColor, id: widget.category.id));
                    Navigator.pop(context);
                  }
                }
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Form(
              key: formKey,
              child: TextFormField(
                  initialValue: categoryName,
                  onSaved: (val) => categoryName = val,
                  validator: (value) => value.isEmpty ? 'Category can\'t be empty': null,
                  decoration: InputDecoration(
                      hintText: "Enter category...",
                      contentPadding: const EdgeInsets.all(16.0)
                  )
              ),
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
}