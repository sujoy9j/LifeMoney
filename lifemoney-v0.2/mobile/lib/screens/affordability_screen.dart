import 'package:flutter/material.dart';

import '../api.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';

class AffordabilityScreen extends StatefulWidget {
  const AffordabilityScreen({super.key});

  @override
  State<AffordabilityScreen> createState() => _AffordabilityScreenState();
}

class _AffordabilityScreenState extends State<AffordabilityScreen> {
  final api = LifeMoneyApi();
  final price = TextEditingController(text: '800000');
  final liquid = TextEditingController(text: '2500000');
  final reserve = TextEditingController(text: '1000000');
  final surplus = TextEditingController(text: '75000');
  final returns = TextEditingController(text: '8');
  final horizon = TextEditingController(text: '5');

  String selectedDream = 'Travel';
  Map<String, dynamic>? result;
  String? error;
  bool loading = false;

  final dreams = const [
    ('Travel', Icons.flight_takeoff_rounded),
    ('Home', Icons.apartment_rounded),
    ('Car', Icons.directions_car_outlined),
    ('Sabbatical', Icons.beach_access_outlined),
  ];

  Future<void> calculate() async {
    FocusScope.of(context).unfocus();
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await api.checkAffordability({
        'purchase_price': controllerNumber(price),
        'current_liquid_corpus': controllerNumber(liquid),
        'protected_reserve': controllerNumber(reserve),
        'monthly_surplus': controllerNumber(surplus),
        'annual_return': controllerNumber(returns) / 100,
        'horizon_years': controllerNumber(horizon).round(),
      });
      if (!mounted) return;
      setState(() => result = response);
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    for (final controller in [price, liquid, reserve, surplus, returns, horizon]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Can I afford it?',
      subtitle: 'See the true cost of a dream without sacrificing protected money.',
      trailing: const AppIconBox(
        icon: Icons.auto_awesome_rounded,
        background: Color(0xFFFFEDC7),
        foreground: Color(0xFF9B6500),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF7E7), Color(0xFFFFFBF3)],
              ),
              border: Border.all(color: const Color(0xFFF2E1BA)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✨', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dream Mode', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        'Spend confidently. LifeMoney shows what the purchase does to your future wealth.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text('What are you dreaming about?', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: dreams
                .map(
                  (dream) => ChoicePill(
                    label: dream.$1,
                    icon: dream.$2,
                    selected: selectedDream == dream.$1,
                    onTap: () => setState(() => selectedDream = dream.$1),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$selectedDream affordability', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 5),
                Text('We protect your reserve before deciding whether the spend is affordable.', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 18),
                MoneyField(controller: price, label: 'Dream / purchase price'),
                const SizedBox(height: 12),
                MoneyField(controller: liquid, label: 'Current liquid corpus'),
                const SizedBox(height: 12),
                MoneyField(controller: reserve, label: 'Protected reserve', helper: 'Emergency fund + money you refuse to compromise'),
                const SizedBox(height: 12),
                MoneyField(controller: surplus, label: 'Monthly surplus'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AssumptionTile(
            icon: Icons.tune_rounded,
            title: 'Opportunity-cost assumptions',
            subtitle: '${returns.text}% return · ${horizon.text}-year horizon',
            child: Row(
              children: [
                Expanded(child: NumberField(controller: returns, label: 'Expected return', suffix: '%')),
                const SizedBox(width: 12),
                Expanded(child: NumberField(controller: horizon, label: 'Compare after', suffix: 'yrs')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryAction(
            label: 'Tell me if I can afford it',
            loading: loading,
            icon: Icons.bolt_rounded,
            onPressed: calculate,
          ),
          if (error != null) ErrorBanner(error!),
          if (result != null) ...[
            const SizedBox(height: 18),
            _AffordabilityResult(dream: selectedDream, result: result!),
          ],
        ],
      ),
    );
  }
}

class _AffordabilityResult extends StatelessWidget {
  const _AffordabilityResult({required this.dream, required this.result});

  final String dream;
  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    final affordable = result['affordable_now'] == true;
    final months = result['months_to_afford_without_touching_reserve'];

    return SectionCard(
      borderColor: (affordable ? AppColors.success : AppColors.warning).withValues(alpha: .3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: (affordable ? AppColors.success : AppColors.warning).withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  affordable ? Icons.check_rounded : Icons.schedule_rounded,
                  color: affordable ? AppColors.success : const Color(0xFF9B6500),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      affordable ? 'Yes — your $dream is affordable' : 'Not yet — protect your future first',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      affordable
                          ? 'This does not require touching your protected reserve.'
                          : 'You can still get there without compromising protected money.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ResultMetric(
            label: 'Future opportunity cost of buying now',
            value: money(result['opportunity_cost_at_horizon']),
            emphasis: true,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: ResultMetric(label: 'Investable money left', value: money(result['investable_after_purchase']))),
              const SizedBox(width: 10),
              Expanded(
                child: ResultMetric(
                  label: 'Wait time without touching reserve',
                  value: months == null ? 'Needs surplus' : months == 0 ? 'Now' : '$months months',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.navySoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.psychology_alt_outlined, color: AppColors.navy),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    affordable
                        ? 'The next version will also show how this purchase changes retirement age and every other goal.'
                        : 'The next version will calculate the fastest path: save more, wait longer, or reduce the dream budget.',
                    style: const TextStyle(color: AppColors.navy, height: 1.45, fontWeight: FontWeight.w600),
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
