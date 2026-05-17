import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routes/route_names.dart';

class HomeScreen extends StatelessWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  static const _routes = [
    RouteNames.dashboard,
    RouteNames.scanner,
    RouteNames.reports,
    RouteNames.chatbot,
    RouteNames.appointments,
  ];

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.home_outlined),      selectedIcon: Icon(Icons.home_rounded),              label: 'Home'),
    NavigationDestination(icon: Icon(Icons.document_scanner_outlined), selectedIcon: Icon(Icons.document_scanner_rounded), label: 'Scan'),
    NavigationDestination(icon: Icon(Icons.analytics_outlined),  selectedIcon: Icon(Icons.analytics_rounded),         label: 'Reports'),
    NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble_rounded),       label: 'AI Chat'),
    NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Schedule'),
  ];

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final idx = _routes.indexWhere((r) => loc.startsWith(r));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => context.go(_routes[i]),
        destinations: _destinations,
        height: 72,
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
