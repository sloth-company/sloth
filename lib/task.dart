import 'package:flutter/material.dart';
import 'categories.dart';
class Task {
  String taskName;
  String description;
  Category category;
  DateTime date;
  Task({Key key, this.taskName: "", this.description: "", this.category, this.date: null,});
}