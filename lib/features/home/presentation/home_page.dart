import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onQuickNavigate});

  final ValueChanged<int> onQuickNavigate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 620
                ? 620.0
                : constraints.maxWidth;
            return Center(
              child: SizedBox(
                width: width,
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.18,
                  children: [
                    _QuickActionTile(
                      title: 'Построить маршрут',
                      subtitle: 'A* по карте кампуса',
                      icon: SvgPicture.asset(
                        'assets/path_icons.svg',
                        width: 26,
                        height: 26,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      onTap: () => onQuickNavigate(1),
                    ),
                    _QuickActionTile(
                      title: 'Кластеры заведений',
                      subtitle: 'Фильтр и DBSCAN',
                      icon: const Icon(
                        Icons.bubble_chart,
                        color: Colors.white,
                        size: 28,
                      ),
                      onTap: () => onQuickNavigate(2),
                    ),
                    _QuickActionTile(
                      title: 'Оценить заведение',
                      subtitle: 'Распознавание цифры 0-9',
                      icon: const Icon(
                        Icons.draw,
                        color: Colors.white,
                        size: 28,
                      ),
                      onTap: () => onQuickNavigate(3),
                    ),
                    _QuickActionTile(
                      title: 'Открыть карту',
                      subtitle: 'Быстрый доступ к навигации',
                      icon: const Icon(
                        Icons.map_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      onTap: () => onQuickNavigate(1),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.brand,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon,
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
