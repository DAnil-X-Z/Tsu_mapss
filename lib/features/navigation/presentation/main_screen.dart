import 'package:app/features/clustering/presentation/clustering_page.dart';
import 'package:app/features/home/presentation/home_page.dart';
import 'package:app/features/rating/presentation/rating_page.dart';
import 'package:app/features/map/presentation/map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<Widget> _buildPages() {
    return <Widget>[
      HomePage(
        onQuickNavigate: (index) => setState(() => _selectedIndex = index),
      ),
      const MapPage(),
      const ClusteringPage(),
      const RatingPage(),
    ];
  }

  List<_NavItem> _buildNavItems() {
    return <_NavItem>[
      _NavItem(
        title: 'Главная',
        icon: const Icon(Icons.home_outlined),
        activeIcon: const Icon(Icons.home),
      ),
      _NavItem(
        title: 'Карта ТГУ',
        icon: SvgPicture.asset(
          'assets/path_icons.svg',
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            Color(0xFF0D4D73),
            BlendMode.srcIn,
          ),
        ),
        activeIcon: SvgPicture.asset(
          'assets/path_icons.svg',
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            Color(0xFF0172BB),
            BlendMode.srcIn,
          ),
        ),
      ),
      _NavItem(
        title: 'Кластеры',
        icon: const Icon(Icons.bubble_chart_outlined),
        activeIcon: const Icon(Icons.bubble_chart),
      ),
      _NavItem(
        title: 'Оценка',
        icon: const Icon(Icons.draw_outlined),
        activeIcon: const Icon(Icons.draw),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages();
    final navItems = _buildNavItems();
    final isHome = _selectedIndex == 0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: isHome
            ? Image.asset('assets/logo.png', height: 50, fit: BoxFit.contain)
            : Text(navItems[_selectedIndex].title),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                icon: const Icon(Icons.menu_rounded),
                tooltip: 'Меню',
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const ListTile(
                title: Text(
                  'Навигация',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const Divider(height: 1),
              for (var i = 0; i < navItems.length; i++)
                ListTile(
                  selected: i == _selectedIndex,
                  selectedTileColor: const Color(0xFFE9F4FB),
                  selectedColor: const Color(0xFF0172BB),
                  leading: i == _selectedIndex
                      ? navItems[i].activeIcon
                      : navItems[i].icon,
                  title: Text(navItems[i].title),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() => _selectedIndex = i);
                  },
                ),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.title,
    required this.icon,
    required this.activeIcon,
  });

  final String title;
  final Widget icon;
  final Widget activeIcon;
}
