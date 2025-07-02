import 'package:flutter/material.dart';
import 'package:my_application/teachers.dart';
import 'student.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              'List of Students and Teachers',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 22,
                color: Colors.white, // Title text color
              ),
            ),
          ),
          backgroundColor: const Color.fromARGB(
            255,
            94,
            146,
            230,
          ), // AppBar background color
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text('Students', style: TextStyle(color: Colors.white)),
              ),
              Tab(
                child: Text('Teachers', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        body: TabBarView(children: [StudentsScreen(), TeachersScreen()]),
      ),
    );
  }
}
