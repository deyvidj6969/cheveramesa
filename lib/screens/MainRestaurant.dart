import 'package:engineering/pages/ConversationsScreen.dart';
import 'package:engineering/pages/favorites_page.dart';
import 'package:engineering/pages/homegape.dart';
import 'package:engineering/pages/profile_page.dart';
import 'package:engineering/screens/EditRestaurantScreen.dart';
import 'package:engineering/screens/RestaurantMessagesScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainRestaurante extends StatefulWidget {
  @override
  _MainRestauranteState createState() => _MainRestauranteState();
}

class _MainRestauranteState extends State<MainRestaurante>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _controller;

  final List<Widget> _pages = [
    RestaurantMessagesScreen(
      currentUserUid: FirebaseAuth.instance.currentUser!.uid,
    ),
    EditRestaurantScreen(
      currentUserId: FirebaseAuth.instance.currentUser!.uid,
    ),
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
            icon: _buildIcon(FontAwesomeIcons.commentDots, 0),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(FontAwesomeIcons.shop, 1),
            label: 'Profile',
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
