import 'package:engineering/funtions/funtions.dart';
import 'package:engineering/models/restaurant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class RestaurantDetails extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetails({
    required this.restaurant,
  });

  @override
  _RestaurantDetailsState createState() => _RestaurantDetailsState();
}

class _RestaurantDetailsState extends State<RestaurantDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  final GlobalKey _resumenKey = GlobalKey();
  final GlobalKey _fotosKey = GlobalKey();
  final GlobalKey _menuKey = GlobalKey();

  bool _isTabTapped = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isTabTapped) return;

    double resumenOffset = _getOffsetFromKey(_resumenKey);
    double fotosOffset = _getOffsetFromKey(_fotosKey);
    double menuOffset = _getOffsetFromKey(_menuKey);
    double currentOffset = _scrollController.offset;

    if (currentOffset >= menuOffset - 150) {
      _updateTabController(2);
    } else if (currentOffset >= fotosOffset - 150) {
      _updateTabController(1);
    } else if (currentOffset >= resumenOffset - 150) {
      _updateTabController(0);
    }
  }

  double _getOffsetFromKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox?;
      return box?.localToGlobal(Offset.zero)?.dy ?? 0.0;
    }
    return 0.0;
  }

  void _scrollToSection(GlobalKey key, int tabIndex) {
    final context = key.currentContext;
    if (context != null) {
      setState(() => _isTabTapped = true);
      _tabController.animateTo(tabIndex);

      Scrollable.ensureVisible(
        context,
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      ).then((_) => setState(() => _isTabTapped = false));
    }
  }

  void _updateTabController(int index) {
    if (_tabController.index != index) {
      _tabController.animateTo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          restaurant.name,
          style: TextStyle(
            fontFamily: 'Lobster',
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen principal del restaurante
            Image.network(
              restaurant.image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            // Pestañas de Resumen, Fotos, Menú
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: Color(0xFFF2404E), width: 1),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                  onTap: (index) {
                    if (index == 0) {
                      _scrollToSection(_resumenKey, index);
                    } else if (index == 1) {
                      _scrollToSection(_fotosKey, index);
                    } else if (index == 2) {
                      _scrollToSection(_menuKey, index);
                    }
                  },
                  tabs: [
                    Tab(text: 'Resumen'),
                    Tab(text: 'Fotos'),
                    Tab(text: 'Menú'),
                  ],
                ),
              ),
            ),

            // Secciones
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumen
                    Container(
                      key: _resumenKey,
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.orange, size: 18),
                              Text(restaurant.rating.toString()),
                              SizedBox(width: 10),
                              Icon(Icons.chat_bubble_outline, size: 18),
                              Text('${restaurant.resenas.length} Reseñas'),
                              SizedBox(width: 10),
                              Icon(Icons.attach_money, size: 18),
                              Text('Desde ${restaurant.price}'),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Sobre el establecimiento',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            restaurant.description,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),

                    // Fotos
                    Container(
                      key: _fotosKey,
                      padding: EdgeInsets.all(16.0),
                      child: MasonryGridView.count(
                        crossAxisCount: 2,
                        itemCount: restaurant.secondaryImages.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              restaurant.secondaryImages[index],
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),

                    // Menú
                    Container(
                      key: _menuKey,
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: restaurant.menu.entries.map((category) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.key,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ...category.value.map((menuItem) {
                                return ListTile(
                                  title: Text(menuItem.name),
                                  subtitle: Text(menuItem.description),
                                  trailing: Text(menuItem.price),
                                );
                              }).toList(),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Agrega la función más tarde
          await manejarConversacion(
            context,
            widget.restaurant.id,
            FirebaseAuth.instance.currentUser!.uid,
          );
        },
        backgroundColor: Color(0xFFF2404E),
        child: Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}
