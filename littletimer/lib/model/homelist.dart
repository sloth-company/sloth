import 'package:best_flutter_ui_templates/design_course/home_design_course.dart';
import 'package:best_flutter_ui_templates/fitness_app/fitness_app_home_screen.dart';
import 'package:best_flutter_ui_templates/hotel_booking/hotel_home_screen.dart';
import 'package:flutter/widgets.dart';

class HomeList {
  HomeList({
    this.navigateScreen,
    this.imagePath = '',
    this.title = '',
  });

  Widget navigateScreen;
  String imagePath;
  String title;

  static List<HomeList> homeList = [
    HomeList(
      imagePath: 'assets/banners/banner_articles.jpg',
      navigateScreen: HotelHomeScreen(),
      title: 'Articles'
          
    ),
    HomeList(
      imagePath: 'assets/banners/banner_entertainment.jpg',
      navigateScreen: FitnessAppHomeScreen(),
      title: 'Avatar'
    ),
    HomeList(
      imagePath: 'assets/banners/banner_games.jpg',
      navigateScreen: DesignCourseHomeScreen(),
      title: 'Courses'
    ),
    HomeList(
      imagePath: 'assets/banners/banner_timer.jpg',
      navigateScreen: DesignCourseHomeScreen(),
      title: 'Timer'
    ),
  ];
}
