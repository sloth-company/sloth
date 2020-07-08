import 'package:flutter/material.dart';

class TabIconData {
  TabIconData({
    this.imagePath = '',
    this.index = 0,
    this.selectedImagePath = '',
    this.isSelected = false,
    this.animationController,
  });

  String imagePath;
  String selectedImagePath;
  bool isSelected;
  int index;

  AnimationController animationController;

  static List<TabIconData> tabIconsList = <TabIconData>[
    TabIconData(
      imagePath: 'assets/fitness_app/orange_productive_timer.png',
      selectedImagePath: 'assets/fitness_app/orange_productive_timer.png',
      index: 0,
      isSelected: true,
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/fitness_app/orange_calendar.png',
      selectedImagePath: 'assets/fitness_app/orange_calendar.png',
      index: 1,
      isSelected: false,
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/fitness_app/orange_community_feed.png',
      selectedImagePath: 'assets/fitness_app/orange_community_feed.png',
      index: 2,
      isSelected: false,
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/fitness_app/orange_avatar.png',
      selectedImagePath: 'assets/fitness_app/orange_avatar.png',
      index: 3,
      isSelected: false,
      animationController: null,
    ),
  ];
}
