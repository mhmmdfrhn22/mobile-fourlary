import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'home/home_page.dart';
import 'gallery/gallery_page.dart';
import 'news/news_page.dart';
import 'pembinat/pembinat_page.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex; // Tambahan agar bisa atur index awal

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex;

  final List<Widget> _pages = const [
    HomePage(),
    GalleryPage(),
    NewsPage(),
    PembinatPage(),
  ];

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Iconsax.home, 'label': 'Beranda'},
    {'icon': Iconsax.image, 'label': 'Galeri'},
    {'icon': Iconsax.document_text, 'label': 'Berita'},
    {'icon': Iconsax.briefcase, 'label': 'Pembinat'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Set index awal dari parameter
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 232, 232, 232),
              blurRadius: 4,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 12,
            bottom: 16,
            right: 12,
            left: 12,
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF007BFF),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
            items: _navItems.map((item) {
              return BottomNavigationBarItem(
                icon: Icon(item['icon'] as IconData),
                label: item['label'] as String,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
