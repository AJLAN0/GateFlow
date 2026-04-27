import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'gateflow_colors.dart';

/// Brand-consistent AppBar used across sub-pages.
///
/// Centralizes the deep-blue header, white title, and back button behavior so
/// nested screens (System Management, list/detail pages, etc.) feel like one
/// connected product instead of disparate FlutterFlow screens.
class GateFlowAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GateFlowAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBack = true,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 60 : 76);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: GateFlowColors.brandPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 26),
              onPressed: onBack ?? () => context.safePop(),
              splashRadius: 22,
            )
          : null,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
      actions: actions,
      centerTitle: false,
    );
  }
}

extension _SafePopContext on BuildContext {
  void safePop() {
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}
