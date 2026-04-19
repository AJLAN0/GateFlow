import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/mock_state.dart';
import 'gateflow_colors.dart';

/// Role-aware bottom navigation that keeps the app coherent across roles.
///
/// Each role has 3-4 primary destinations that map to existing named routes.
/// This replaces the fragmented push-only navigation that previously forced
/// users to back-track from every sub-screen.
class RoleBottomNav extends StatelessWidget {
  const RoleBottomNav({super.key, required this.current});

  /// Stable identifier of the current destination, e.g. `'home'`, `'requests'`,
  /// `'monitor'`, `'profile'`. Used only to highlight the selected item.
  final String current;

  @override
  Widget build(BuildContext context) {
    final role = context.read<MockState>().currentUserRole;
    final items = _itemsForRole(role);
    if (items.isEmpty) return const SizedBox.shrink();

    final selectedIndex =
        items.indexWhere((i) => i.id == current).clamp(0, items.length - 1);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Color(0x14000000),
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (i) => _navigate(context, items[i].route),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: GateFlowColors.brandPrimary,
          unselectedItemColor: GateFlowColors.textTertiary,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: items
              .map((i) => BottomNavigationBarItem(
                    icon: Icon(i.icon),
                    activeIcon: Icon(i.activeIcon ?? i.icon),
                    label: i.label,
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String routeName) {
    final current = GoRouterState.of(context).name;
    if (current == routeName) return;
    context.goNamed(routeName);
  }

  static List<_NavItem> _itemsForRole(UserRole role) {
    switch (role) {
      case UserRole.parent:
        return const [
          _NavItem(
              id: 'home',
              label: 'Home',
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              route: 'Dash'),
          _NavItem(
              id: 'children',
              label: 'Children',
              icon: Icons.child_care_outlined,
              activeIcon: Icons.child_care_rounded,
              route: 'ViewChildern'),
          _NavItem(
              id: 'requests',
              label: 'Requests',
              icon: Icons.event_note_outlined,
              activeIcon: Icons.event_note_rounded,
              route: 'RequestStatus'),
          _NavItem(
              id: 'profile',
              label: 'Profile',
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              route: 'ParentProfile'),
        ];
      case UserRole.guardian:
        return const [
          _NavItem(
              id: 'home',
              label: 'Home',
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              route: 'DashGuardian'),
          _NavItem(
              id: 'children',
              label: 'Children',
              icon: Icons.child_care_outlined,
              activeIcon: Icons.child_care_rounded,
              route: 'ViewChildernG'),
          _NavItem(
              id: 'profile',
              label: 'Profile',
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              route: 'ProfileG'),
        ];
      case UserRole.busDriver:
        return const [
          _NavItem(
              id: 'home',
              label: 'Home',
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              route: 'BusSupervisorDashboard'),
          _NavItem(
              id: 'students',
              label: 'Students',
              icon: Icons.groups_outlined,
              activeIcon: Icons.groups_rounded,
              route: 'AssignedStudentslist'),
          _NavItem(
              id: 'profile',
              label: 'Profile',
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              route: 'BusDriverProfile'),
        ];
      case UserRole.schoolStaff:
        return const [
          _NavItem(
              id: 'home',
              label: 'Home',
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              route: 'SchoolDashboard'),
          _NavItem(
              id: 'monitor',
              label: 'Monitor',
              icon: Icons.monitor_heart_outlined,
              activeIcon: Icons.monitor_heart_rounded,
              route: 'StudentStatus'),
          _NavItem(
              id: 'requests',
              label: 'Requests',
              icon: Icons.inbox_outlined,
              activeIcon: Icons.inbox_rounded,
              route: 'TimeRequest'),
          _NavItem(
              id: 'profile',
              label: 'Profile',
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              route: 'AdminProfile'),
        ];
      case UserRole.none:
        return const [];
    }
  }
}

class _NavItem {
  const _NavItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
    this.activeIcon,
  });

  final String id;
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final String route;
}
