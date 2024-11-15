import 'package:engineering/pages/ConversationsScreen.dart';
import 'package:engineering/pages/favorites_page.dart';
import 'package:engineering/pages/homegape.dart';
import 'package:engineering/pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _controller;

  final List<Widget> _pages = [
    HomePage(),
    ProfilePage(),
    ConversationsScreen(
      currentUserId: FirebaseAuth.instance.currentUser!.uid,
    ),
    FavoritesPage(currentUserId: FirebaseAuth.instance.currentUser!.uid),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      _controller.forward(from: 0.0); // Reiniciar la animación
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFF2404E),
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        selectedFontSize: 14.0,
        unselectedFontSize: 12.0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon(FontAwesomeIcons.house, 0),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(FontAwesomeIcons.user, 1),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(FontAwesomeIcons.commentDots, 2),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(FontAwesomeIcons.heart, 3),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index) {
    final bool isSelected = _currentIndex == index;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(vertical: isSelected ? 6.0 : 0.0),
      child: FaIcon(
        icon,
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
        size: isSelected ? 30.0 : 24.0,
      ),
    );
  }
}
