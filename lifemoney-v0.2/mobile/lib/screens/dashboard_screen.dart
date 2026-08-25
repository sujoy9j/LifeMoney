import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 34),
        children: [
          _TopBar(),
          const SizedBox(height: 22),
          _WealthHero(onNavigate: onNavigate),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Safe to spend',
                  value: '₹63,500',
                  note: 'this month',
                  tint: AppColors.primarySoft,
                  foreground: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniMetric(
                  icon: Icons.local_fire_department_outlined,
                  label: 'FIRE target',
                  value: 'Age 51',
                  note: 'base scenario',
                  tint: const Color(0xFFFFF4E5),
                  foreground: const Color(0xFFB96C00),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SectionHeader(title: 'Quick simulate', action: 'See all'),
          const SizedBox(height: 12),
          SizedBox(
            height: 106,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _QuickAction(
                  icon: Icons.school_outlined,
                  label: 'Education',
                  onTap: () => onNavigate(1),
                ),
                _QuickAction(
                  icon: Icons.beach_access_outlined,
                  label: 'Retirement',
                  onTap: () => onNavigate(2),
                ),
                _QuickAction(
                  icon: Icons.flight_takeoff_rounded,
                  label: 'Dream trip',
                  onTap: () => onNavigate(3),
                ),
                _QuickAction(
                  icon: Icons.apartment_rounded,
                  label: 'Dream home',
                  onTap: () => onNavigate(3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const _SectionHeader(title: 'Your life goals', action: 'Manage'),
          const SizedBox(height: 12),
          const _GoalProgressCard(
            emoji: '🎓',
            title: 'Child education',
            subtitle: '2035 · ₹1.4 Cr target',
            progress: .72,
            status: 'On track',
          ),
          const SizedBox(height: 10),
          const _GoalProgressCard(
            emoji: '🌍',
            title: 'World travel',
            subtitle: '2029 · ₹18 L target',
            progress: .46,
            status: 'Needs ₹8K/mo',
          ),
          const SizedBox(height: 22),
          _DreamCard(onTap: () => onNavigate(3)),
          const SizedBox(height: 16),
          const _PrivacyStrip(),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good evening', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text('Your money dashboard', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () {},
          tooltip: 'Notifications',
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          child: Text('LM', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
        ),
      ],
    );
  }
}

class _WealthHero extends StatelessWidget {
  const _WealthHero({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16324F), Color(0xFF0C6E67)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F16324F),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'NET WORTH',
                  style: TextStyle(
                    color: Color(0xFFBFD6D2),
                    letterSpacing: 1.2,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_upward_rounded, size: 14, color: Colors.white),
                    SizedBox(width: 3),
                    Text('+11.4%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '₹1.84 Cr',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              height: 1.1,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Illustrative dashboard until your real profile is connected',
            style: TextStyle(color: Color(0xFFD7E6E3), fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Freedom score', style: TextStyle(color: Color(0xFFC7DAD6), fontSize: 12)),
                    SizedBox(height: 3),
                    Text('74 / 100', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.navy,
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                ),
                onPressed: () => onNavigate(3),
                icon: const Icon(Icons.bolt_rounded, size: 18),
                label: const Text('Can I afford it?'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.note,
    required this.tint,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final String value;
  final String note;
  final Color tint;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconBox(icon: icon, background: tint, foreground: foreground),
          const SizedBox(height: 15),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 3),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(note, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
        Text(action, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 106,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppIconBox(icon: icon),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalProgressCard extends StatelessWidget {
  const _GoalProgressCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.status,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final double progress;
  final String status;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Text(status, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: AppColors.primarySoft,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DreamCard extends StatelessWidget {
  const _DreamCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8EB),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFF4E4BF)),
        ),
        child: Row(
          children: [
            const AppIconBox(
              icon: Icons.auto_awesome_rounded,
              background: Color(0xFFFFEDC7),
              foreground: Color(0xFF9B6500),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dream Mode', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Tell us what would make life awesome. We turn it into a funding plan.', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Color(0xFF9B6500)),
          ],
        ),
      ),
    );
  }
}

class _PrivacyStrip extends StatelessWidget {
  const _PrivacyStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.inkMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Planning & simulation only in v0.2. No banking credentials or security recommendations are collected.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted, height: 1.45),
          ),
        ),
      ],
    );
  }
}
