import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// Standard page wrapper with consistent padding, scroll physics, and pull-to-refresh
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 32),
    this.onRefresh,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final scrollable = ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: padding,
      children: children,
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        color: kPrimary,
        backgroundColor: Colors.white,
        onRefresh: onRefresh!,
        child: scrollable,
      );
    }

    return scrollable;
  }
}

/// Modern clean header with primary title and informative subtitle
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: kText,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    color: kMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Signature 4-Colored Dots Indicator (AI & Smart Assistant Badge from reference)
class FourDotIndicator extends StatelessWidget {
  const FourDotIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ColorDot(color: Color(0xFF00A3FF)),
          SizedBox(width: 3),
          _ColorDot(color: Color(0xFFF59E0B)),
          SizedBox(width: 3),
          _ColorDot(color: Color(0xFF10B981)),
          SizedBox(width: 3),
          _ColorDot(color: Color(0xFF8B5CF6)),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4.5,
      height: 4.5,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Circular Quick Action Button (from reference service row)
class CircularQuickAction extends StatelessWidget {
  const CircularQuickAction({
    super.key,
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: fg, size: 22),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal Goal Card (from reference 'Goals' carousel)
class HorizontalGoalCard extends StatelessWidget {
  const HorizontalGoalCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    this.trendText,
    this.isPositiveTrend = true,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String? trendText;
  final bool isPositiveTrend;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 158,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorder),
          boxShadow: kCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(icon, color: iconFg, size: 18),
                  ),
                ),
                if (trendText != null)
                  Icon(
                    isPositiveTrend ? Icons.trending_up_rounded : Icons.trending_flat_rounded,
                    color: isPositiveTrend ? kSuccess : kMuted,
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: kMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: kText,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isPositiveTrend ? kSuccess : kTextSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Activity Item Tile (from reference 'Received Activity' feed)
class ActivityItemTile extends StatelessWidget {
  const ActivityItemTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    this.trailingTitle,
    this.trailingSubtitle,
    this.trailingWidget,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String? trailingTitle;
  final String? trailingSubtitle;
  final Widget? trailingWidget;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
          boxShadow: kCardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: iconFg, size: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: kText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: kMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingWidget != null)
              trailingWidget!
            else if (trailingTitle != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    trailingTitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                  ),
                  if (trailingSubtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      trailingSubtitle!,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: kMuted,
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Clean Search Bar (from reference screen 4)
class CleanSearchBar extends StatelessWidget {
  const CleanSearchBar({
    super.key,
    this.hint = 'Cari nama atau no. RM...',
    this.controller,
    this.onChanged,
    this.trailing,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: kSearchBg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: kMuted, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 13.5, color: kText),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 13, color: kMuted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Elevated Card Container with multi-layer shadow and refined border
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    this.title,
    this.trailing,
    this.child,
    this.background = kSurface,
    this.borderColor = kBorder,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  final String? title;
  final Widget? trailing;
  final Widget? child;
  final Color background;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: kText,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            if (child != null) const SizedBox(height: 14),
          ],
          ?child,
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: cardContent,
      );
    }

    return cardContent;
  }
}

/// Metric Highlight Card with colored icon badge and bold numeric value
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
    required this.accent,
    this.subtitle,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tint;
  final Color accent;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kTextSecondary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 10.5, color: kMuted),
            ),
          ],
        ],
      ),
    );
  }
}

/// Modern capsule badge / status indicator
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.text,
    required this.bg,
    required this.fg,
    this.icon,
  });

  final String text;
  final Color bg;
  final Color fg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive Symptom Selection Card
class SymptomTile extends StatelessWidget {
  const SymptomTile({
    super.key,
    required this.label,
    required this.icon,
    required this.tint,
    required this.selected,
    required this.onToggle,
    this.description,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final bool selected;
  final VoidCallback onToggle;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? kSoftBlue : kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? kPrimary : kBorder,
            width: selected ? 1.8 : 1.0,
          ),
          boxShadow: selected ? kButtonShadow : kCardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: selected ? kPrimary : kText, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected ? kPrimary : kText,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: const TextStyle(fontSize: 11, color: kMuted),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: selected ? kPrimary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? kPrimary : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Primary Banner Action Button with gradient and tactile feedback
class PrimaryBannerButton extends StatelessWidget {
  const PrimaryBannerButton({
    super.key,
    required this.label,
    this.icon,
    this.gradient,
    this.enabled = true,
  });

  final String label;
  final IconData? icon;
  final Gradient? gradient;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: enabled
            ? (gradient ??
                const LinearGradient(
                  colors: [kPrimaryGradientStart, kPrimaryGradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ))
            : const LinearGradient(
                colors: [Color(0xFFCBD5E1), Color(0xFF94A3B8)],
              ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: enabled ? kButtonShadow : const [],
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 19),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Action Chip Button
class AppActionChip extends StatelessWidget {
  const AppActionChip({
    super.key,
    required this.label,
    required this.filled,
    required this.fillColor,
    required this.fg,
    this.icon,
    this.onTap,
  });

  final String label;
  final bool filled;
  final Color fillColor;
  final Color fg;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? fillColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: filled ? fillColor : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: filled ? kButtonShadow : const [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty State Illustration & Description Card
class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(icon, color: kMuted, size: 26),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: kText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, height: 1.45, color: kMuted),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kPrimary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Chat Bubble with distinctive typography and layout
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.text,
    required this.incoming,
  });

  final String text;
  final bool incoming;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: incoming ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: incoming ? kSurface : kPrimary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(incoming ? 4 : 18),
            bottomRight: Radius.circular(incoming ? 18 : 4),
          ),
          border: incoming ? Border.all(color: kBorder) : null,
          boxShadow: incoming ? kCardShadow : kButtonShadow,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.45,
            color: incoming ? kText : Colors.white,
          ),
        ),
      ),
    );
  }
}

/// History Log Card for treatment doses & checkups
class HistoryLogCard extends StatelessWidget {
  const HistoryLogCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.tint,
    required this.fg,
  });

  final String title;
  final String subtitle;
  final IconData leading;
  final Color tint;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
        boxShadow: kCardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(leading, color: fg, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: kMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Notification Feed Card
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusBg,
    required this.statusFg,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final Color statusBg;
  final Color statusFg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
        boxShadow: kCardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: statusFg, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kText,
                        ),
                      ),
                    ),
                    StatusPill(text: status, bg: statusBg, fg: statusFg),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: kMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Checklist item tile
class ChecklistTile extends StatelessWidget {
  const ChecklistTile({
    super.key,
    required this.label,
    required this.time,
    required this.checked,
    this.onTap,
  });

  final String label;
  final String time;
  final bool checked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: checked ? kSoftGreen : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: checked ? kBorderGreen : kBorder,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: checked ? kSuccess : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: checked ? kSuccess : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: checked ? FontWeight.w700 : FontWeight.w600,
                      color: checked ? const Color(0xFF065F46) : kText,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(fontSize: 11, color: kMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// High-craft Auth Field
class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.fieldKey,
    this.onChanged,
    this.suffixIcon,
    this.obscureText = false,
  });

  final String hintText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final Key? fieldKey;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(prefixIcon, color: kMuted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              key: fieldKey,
              controller: controller,
              onChanged: onChanged,
              obscureText: obscureText,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: kText,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: kMuted, fontSize: 13),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          ?suffixIcon,
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

/// Account & Profile Row Tile
class AccountRowTile extends StatelessWidget {
  const AccountRowTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.titleColor,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color? titleColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
          boxShadow: kCardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: (titleColor == kDanger) ? kSoftRed : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: titleColor ?? kPrimary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: titleColor ?? kText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: kMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: kMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Profile menu tile (alias for AccountRowTile)
typedef ProfileMenuTile = AccountRowTile;

/// Language Selection Modal Dialog
Future<void> showLanguageDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Pilih Bahasa / Language', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: kPrimary),
              title: const Text('Bahasa Indonesia (ID)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.radio_button_unchecked, color: kMuted),
              title: const Text('English (EN)', style: TextStyle(fontSize: 13.5)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}

/// Reusable Confirmation Dialog for Logout
Future<bool?> showConfirmLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: kDanger, size: 22),
            SizedBox(width: 8),
            Text(
              'Konfirmasi Keluar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kText,
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun ini?',
          style: TextStyle(fontSize: 13, color: kTextSecondary),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: kMuted, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kDanger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      );
    },
  );
}
