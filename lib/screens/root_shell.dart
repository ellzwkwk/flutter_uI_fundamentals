import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'courses_page.dart';
import 'favorites_page.dart';
import 'profile_tab.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int selectedIndex = 0;

  static const List<Widget> pages = [
    HomeTab(),
    CoursesPage(),
    FavoritesPage(),
    ProfileTab(),
  ];

  static const destinations = [
    NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.school), label: 'Courses'),
    NavigationDestination(icon: Icon(Icons.favorite), label: 'Favorites'),
    NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
  ];

  static const railDestinations = [
    NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
    NavigationRailDestination(icon: Icon(Icons.school), label: Text('Courses')),
    NavigationRailDestination(icon: Icon(Icons.favorite), label: Text('Favorites')),
    NavigationRailDestination(icon: Icon(Icons.person), label: Text('Profile')),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 840) {
          return Scaffold(
            body: pages[selectedIndex],
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                setState(() => selectedIndex = index);
              },
              destinations: destinations,
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => selectedIndex = index);
                },
                labelType: NavigationRailLabelType.all,
                destinations: railDestinations,
              ),
              const VerticalDivider(width: 1),
              Expanded(child: pages[selectedIndex]),
            ],
          ),
        );
      },
    );
  }
}