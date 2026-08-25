import 'package:flutter/material.dart';

import '../api.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final api = LifeMoneyApi();
  final currentCost = TextEditingController(text: '5000000');
  final years = TextEditingController(text: '10');
  final currentCorpus = TextEditingController(text: '1000000');
  final inflation = TextEditingController(text: '8');
  final returns = TextEditingController(text: '10');
  final stepUp = TextEditingController(text: '10');

  String selectedGoal = 'Education';
  Map<String, dynamic>? result;
  String? error;
  bool loading = false;

  final goalTypes = const [
    ('Education', Icons.school_outlined),
    ('Home', Icons.apartment_rounded),
    ('Travel', Icons.flight_takeoff_rounded),
    ('Wedding', Icons.celebration_outlined),
  ];

  Future<void> calculate() async {
    FocusScope.of(context).unfocus();
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await api.calculateGoal({
        'current_cost': controllerNumber(currentCost),
        'years': controllerNumber(years).round(),
        'current_corpus': controllerNumber(currentCorpus),
        'inflation_rate': controllerNumber(inflation) / 100,
        'annual_return': controllerNumber(returns) / 100,
        'annual_step_up': controllerNumber(stepUp) / 100,
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
    for (final controller in [currentCost, years, currentCorpus, inflation, returns, stepUp]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Goal planner',
      subtitle: 'Turn a life goal into a realistic, inflation-aware monthly plan.',
      trailing: const AppIconBox(icon: Icons.flag_outlined),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What are you planning for?', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: goalTypes
                .map(
                  (goal) => ChoicePill(
                    label: goal.$1,
                    icon: goal.$2,
                    selected: selectedGoal == goal.$1,
                    onTap: () => setState(() => selectedGoal = goal.$1),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$selectedGoal goal', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 5),
                Text('Start with today\'s cost. We will inflate it to the goal year.', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 18),
                MoneyField(controller: currentCost, label: 'Cost today'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: NumberField(controller: years, label: 'Years away', suffix: 'yrs')),
                    const SizedBox(width: 12),
                    Expanded(child: MoneyField(controller: currentCorpus, label: 'Already saved')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AssumptionTile(
            icon: Icons.tune_rounded,
            title: 'Planning assumptions',
            subtitle: '${inflation.text}% inflation · ${returns.text}% return · ${stepUp.text}% SIP step-up',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: NumberField(controller: inflation, label: 'Goal inflation', suffix: '%')),
                    const SizedBox(width: 12),
                    Expanded(child: NumberField(controller: returns, label: 'Expected return', suffix: '%')),
                  ],
                ),
                const SizedBox(height: 12),
                NumberField(controller: stepUp, label: 'Annual SIP step-up', suffix: '%'),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'These are planning assumptions, not guaranteed investment returns.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryAction(label: 'Build my funding plan', loading: loading, onPressed: calculate),
          if (error != null) ErrorBanner(error!),
          if (result != null) ...[
            const SizedBox(height: 18),
            _GoalResult(goalName: selectedGoal, result: result!),
          ],
        ],
      ),
    );
  }
}

class _GoalResult extends StatelessWidget {
  const _GoalResult({required this.goalName, required this.result});

  final String goalName;
  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    final stepUp = (result['monthly_sip_step_up'] as num?) ?? 0;
    final flat = (result['monthly_sip_flat'] as num?) ?? 0;
    final savings = flat - stepUp;

    return SectionCard(
      color: Colors.white,
      borderColor: AppColors.primary.withValues(alpha: .22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIconBox(icon: Icons.auto_graph_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$goalName funding plan', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 3),
                    Text('Start smaller and step up annually, or keep a flat SIP.', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ResultMetric(
            label: 'Start with this monthly SIP',
            value: money(stepUp),
            emphasis: true,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: ResultMetric(label: 'Future goal cost', value: money(result['future_cost']))),
              const SizedBox(width: 10),
              Expanded(child: ResultMetric(label: 'Flat monthly SIP', value: money(flat))),
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
                const Icon(Icons.insights_rounded, color: AppColors.navy),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    savings > 0
                        ? 'A step-up plan starts about ${money(savings)} lower per month than a flat SIP, then rises annually.'
                        : 'Your current assumptions make the flat and step-up plans broadly similar.',
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
