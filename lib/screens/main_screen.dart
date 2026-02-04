import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Add this import
import 'home_page.dart';
import 'explore_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'auth_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final supabase = Supabase.instance.client;

  // Helper to determine which widget to show in the 4th tab
  Widget _getProfileTab() {
    final session = supabase.auth.currentSession;
    if (session != null) {
      return const ProfilePage();
    } else {
      return const AuthScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    // We define the list inside build so it updates when setState is called
    final List<Widget> pages = [
      const HomePage(),
      const ExplorePage(),
      const CartPage(),
      _getProfileTab(), // Dynamic check for Auth
    ];

    final double screenWidth = MediaQuery.of(context).size.width;
    final int itemCount = pages.length;
    final double tabWidth = screenWidth / itemCount;
    const double indicatorWidth = 42; 
    final double leftOffset =
        _currentIndex * tabWidth + (tabWidth - indicatorWidth) / 2;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: SizedBox(
        height: 70,
        child: Stack(
          children: [
            BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                // When we tap, we call setState to re-run _getProfileTab()
                setState(() => _currentIndex = index);
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 0,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: ''),
              ],
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              top: 4,
              left: leftOffset,
              child: Container(
                width: indicatorWidth,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}