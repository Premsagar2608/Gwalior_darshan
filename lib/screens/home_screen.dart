import 'dart:async';
import 'dart:convert';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:gwalior_darshan/screens/places/places_list.dart';
import 'package:gwalior_darshan/screens/profile/profile_screen.dart';
import 'package:gwalior_darshan/screens/search/search_screen.dart';
import 'package:gwalior_darshan/screens/transport/transport_screen.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import 'favorites/favorites_screen.dart';
import 'food/food_list.dart';
import 'hotels/hotels_list.dart';
import 'map/map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController();
  int _currentBanner = 0;
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> banners = [
    {
      "title": "Explore the Beauty of Gwalior City 🌄",
      "image": "assets/images/logo.png"
    },
    {
      "title": "Taste the Famous Food of Gwalior 🍲",
      "image": "assets/images/logo.png"
    },
    {
      "title": "Find Luxury Hotels in Gwalior 🏨",
      "image": "assets/images/logo.png"
    },
    {
      "title": "Know the Transport Guide 🚍",
      "image": "assets/images/logo.png"
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;

    // Auto Swipe Every 2 Seconds
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_bannerController.hasClients) {
        _currentBanner = (_currentBanner + 1) % banners.length;

        _bannerController.animateToPage(
          _currentBanner,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeService>(context).isDarkMode;

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF0D1117) : const Color(0xFFF4F7FF),

      appBar: AppBar(
        backgroundColor:
        isDark ? const Color(0xFF0D1117) : const Color(0xFF1746A2),
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage("assets/images/logo.png"),
            ),
            const SizedBox(width: 10),
            const Text(
              "Gwalior 🛺",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                );
              },
            ),

            // IconButton(
            //   icon: Icon(
            //     isDark ? Icons.dark_mode : Icons.light_mode,
            //     color: Colors.white,
            //   ),
            //   onPressed: () {
            //     Provider.of<ThemeService>(context, listen: false).toggleTheme();
            //   },
            // ),
          ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ⭐ PREMIUM AUTO-SWIPE BANNER
          SizedBox(
            height: 170,
            child: PageView.builder(
              controller: _bannerController,
              itemCount: banners.length,
              onPageChanged: (index) {
                setState(() => _currentBanner = index);
              },
              itemBuilder: (context, index) {
                return AnimatedScale(
                  scale: _currentBanner == index ? 1 : 0.95,
                  duration: const Duration(milliseconds: 1000),
                  child: bannerItem(
                    title: banners[index]["title"],
                    image: banners[index]["image"],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // ⭐ DOT INDICATOR
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              banners.length,
                  (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentBanner == index ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentBanner == index
                      ? const Color(0xFF1746A2)
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Categories Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.grid_view_rounded, color: Color(0xFF1746A2), size: 26),
                    SizedBox(width: 10),
                    Text(
                      "Categories",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1746A2),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFC93C), Color(0xFF1746A2)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Explore",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ⭐ PREMIUM GRID VIEW
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _colorfulCard(
                    title: "     Tourist\nDestinations",
                    icon: Icons.location_city,
                    gradient: const [Color(0xFF1746A2), Color(0xFF4FC3F7)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PlacesList()),
                      );
                    },
                  ),

                  _colorfulCard(
                    title: "Famous Food",
                    icon: Icons.restaurant_menu,
                    gradient: const [Color(0xFFFFA600), Color(0xFFFFC046)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FoodList()),
                      );
                    },
                  ),
                  _colorfulCard(
                    title: "Hotels",
                    icon: Icons.hotel,
                    gradient: const [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HotelsList()),
                      );
                    },
                  ),
                  _colorfulCard(
                    title: "Gwalior Map",
                    icon: Icons.map,
                    gradient: const [Color(0xFF2ECC71), Color(0xFF58D68D)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MapScreen()),
                      );
                    },
                  ),
                  _colorfulCard(
                    title: "Transport Guide",
                    icon: Icons.directions_bus,
                    gradient: const [Color(0xFFE91E63), Color(0xFFF48FB1)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TransportScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex, // ← ADD THIS
        height: 60,
        backgroundColor: Colors.transparent,
        color: isDark ? const Color(0xFF1746A2) : const Color(0xFF1746A2),
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.map, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 0) {
            // Already home
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MapScreen()),
            ).then((_) {
              // When coming back → reset to HOME
              setState(() => _selectedIndex = 0);
            });
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ).then((_) {
              setState(() => _selectedIndex = 0);
            });
          }
        },
      ),


    );
  }

  // ⭐ PREMIUM BANNER WIDGET
  Widget bannerItem({required String title, required String image}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1746A2), Color(0xFF4FC3F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ClipOval(
                  child: Image.asset(
                    image,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ⭐ PREMIUM CATEGORY CARD
  Widget _colorfulCard({
    required String title,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(3, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTemporaryMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("This feature will be added soon!"),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
