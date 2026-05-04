part of flutter_tbc;

class _SectionCard extends StatelessWidget {
  const _SectionCard({this.title, this.trailing, this.child, this.background = kSurface, this.borderColor = const Color(0xFFEEF2F7)});

  final String? title;
  final Widget? trailing;
  final Widget? child;
  final Color background;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Row(
              children: [
                Expanded(child: Text(title!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kText))),
                if (trailing != null) trailing!,
              ],
            ),
          if (title != null && child != null) const SizedBox(height: 12),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon, required this.tint, required this.accent});

  final String label;
  final String value;
  final IconData icon;
  final Color tint;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(18), border: Border.all(color: kBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Icon(icon, color: accent, size: 22), const SizedBox(height: 18), Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: accent)), const SizedBox(height: 2), Text(label, style: const TextStyle(fontSize: 10.5, color: kMuted))],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.bg, required this.fg});

  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  const _TimeBadge({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: kSoftBlue, borderRadius: BorderRadius.circular(14)),
      child: Text(time, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: kPrimary)),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, required this.filled, required this.fillColor, required this.fg, this.onTap});

  final String label;
  final bool filled;
  final Color fillColor;
  final Color fg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 46),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(12),
          border: filled ? null : Border.all(color: const Color(0x332563EB)),
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: fg)),
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: active ? kSoftBlue : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: active ? const Color(0xFFBFDBFE) : kBorder)),
      child: Row(
        children: [
          Icon(active ? Icons.check_circle_rounded : Icons.radio_button_unchecked, color: active ? kPrimary : kMuted, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kText))),
        ],
      ),
    );
  }
}

class _SymptomTile extends StatelessWidget {
  const _SymptomTile({required this.label, required this.icon, required this.tint, required this.selected, required this.onToggle});

  final String label;
  final IconData icon;
  final Color tint;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: selected ? kPrimary : const Color(0xFFEEF2F7))),
        child: Row(
          children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: selected ? kPrimary : const Color(0xFF334155), size: 22)),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12.8, fontWeight: FontWeight.w700, color: kText))),
            Container(width: 22, height: 22, decoration: BoxDecoration(color: selected ? kPrimary : Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: selected ? kPrimary : const Color(0xFF6B7280))), child: selected ? const Icon(Icons.check, color: Colors.white, size: 14) : null),
          ],
        ),
      ),
    );
  }
}

class _PrimaryBannerButton extends StatelessWidget {
  const _PrimaryBannerButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(14)),
      child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.text, required this.incoming});

  final String text;
  final bool incoming;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: incoming ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: incoming ? kSoftBlue : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
        child: Text(text, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: kText)),
      ),
    );
  }
}

class _HistoryLogCard extends StatelessWidget {
  const _HistoryLogCard({required this.title, required this.subtitle, required this.leading, required this.tint, required this.fg});

  final String title;
  final String subtitle;
  final IconData leading;
  final Color tint;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEEF2F7))),
      child: Row(
        children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(12)), child: Icon(leading, color: fg, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: kText)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 9.2, color: kMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.icon, required this.title, required this.subtitle, required this.status, required this.statusBg, required this.statusFg});

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final Color statusBg;
  final Color statusFg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEEF2F7))),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: kSoftBlue, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: kPrimary, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: kText)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 9.5, color: kMuted)),
              ],
            ),
          ),
          _StatusPill(text: status, bg: statusBg, fg: statusFg),
        ],
      ),
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kText)),
        Text(action, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kPrimary)),
      ],
    );
  }
}

class _DoctorPreviewCard extends StatelessWidget {
  const _DoctorPreviewCard({required this.name, required this.specialty, required this.badge, this.muted = false});

  final String name;
  final String specialty;
  final String badge;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: muted ? const Color(0xFFE1E2ED) : const Color(0xFFD0E1FB),
            child: Text(name.split(' ').last[0], style: TextStyle(fontWeight: FontWeight.w700, color: muted ? const Color(0xFF434655) : const Color(0xFF54647A))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: kText)),
                const SizedBox(height: 2),
                Text(specialty, style: const TextStyle(fontSize: 11.5, color: kMuted)),
              ],
            ),
          ),
          _StatusPill(text: badge, bg: muted ? const Color(0xFFE1E2ED) : const Color(0xFFEFF6FF), fg: muted ? const Color(0xFF434655) : kPrimary),
        ],
      ),
    );
  }
}

class _PatientPreviewCard extends StatelessWidget {
  const _PatientPreviewCard({required this.name, required this.status, required this.badge});

  final String name;
  final String status;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
      child: Row(
        children: [
          CircleAvatar(radius: 20, backgroundColor: const Color(0xFFE1E2ED), child: Text(name[0], style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF434655)))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: kText)),
                const SizedBox(height: 2),
                Text(status, style: const TextStyle(fontSize: 11.5, color: kMuted)),
              ],
            ),
          ),
          _StatusPill(text: badge, bg: const Color(0xFFF8FAFC), fg: kMuted),
        ],
      ),
    );
  }
}

class _DoctorListItem extends StatelessWidget {
  const _DoctorListItem({required this.name, required this.specialty, required this.badge, this.muted = false});

  final String name;
  final String specialty;
  final String badge;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return _DoctorPreviewCard(name: name, specialty: specialty, badge: badge, muted: muted);
  }
}

class _PatientListItem extends StatelessWidget {
  const _PatientListItem({required this.name, required this.status, required this.badge});

  final String name;
  final String status;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return _PatientPreviewCard(name: name, status: status, badge: badge);
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({required this.icon, required this.title, required this.subtitle, this.titleColor = kText});

  final IconData icon;
  final String title;
  final String subtitle;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
      child: Row(
        children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFFF3F3FE), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: titleColor, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: titleColor)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(fontSize: 9.5, color: kMuted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}
