import 'package:flutter/material.dart';

import '../api.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';

class RetirementScreen extends StatefulWidget {
  const RetirementScreen({super.key});

  @override
  State<RetirementScreen> createState() => _RetirementScreenState();
}

class _RetirementScreenState extends State<RetirementScreen> {
  final api = LifeMoneyApi();
  final age = TextEditingController(text: '38');
  final retirementAge = TextEditingController(text: '50');
  final life = TextEditingController(text: '90');
  final expense = TextEditingController(text: '100000');
  final corpus = TextEditingController(text: '20000000');
  final sip = TextEditingController(text: '100000');
  final inflation = TextEditingController(text: '6');
  final preReturn = TextEditingController(text: '10');
  final postReturn = TextEditingController(text: '8');
  final stepUp = TextEditingController(text: '10');

  Map<String, dynamic>? result;
  String? error;
  bool loading = false;

  Future<void> calculate() async {
    FocusScope.of(context).unfocus();
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await api.simulateRetirement({
        'current_age': controllerNumber(age).round(),
        'retirement_age': controllerNumber(retirementAge).round(),
        'life_expectancy': controllerNumber(life).round(),
        'current_monthly_expense': controllerNumber(expense),
        'current_corpus': controllerNumber(corpus),
        'monthly_investment': controllerNumber(sip),
        'annual_inflation': controllerNumber(inflation) / 100,
        'pre_retirement_return': controllerNumber(preReturn) / 100,
        'post_retirement_return': controllerNumber(postReturn) / 100,
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
    for (final controller in [age, retirementAge, life, expense, corpus, sip, inflation, preReturn, postReturn, stepUp]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Retirement / FIRE',
      subtitle: 'Test whether your lifestyle can survive inflation and decades of withdrawals.',
      trailing: const AppIconBox(
        icon: Icons.local_fire_department_outlined,
        background: Color(0xFFFFF4E5),
        foreground: Color(0xFFB96C00),
      ),
      child: Column(
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const AppIconBox(icon: Icons.timeline_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your FIRE runway', style: Theme.of(context).textTheme.titleLarge),
                          Text('Set the age you want work to become optional.', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: NumberField(controller: age, label: 'Current age', suffix: 'yrs')),
                    const SizedBox(width: 12),
                    Expanded(child: NumberField(controller: retirementAge, label: 'Retire at', suffix: 'yrs')),
                    const SizedBox(width: 12),
                    Expanded(child: NumberField(controller: life, label: 'Plan till', suffix: 'yrs')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lifestyle & wealth', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 14),
                MoneyField(controller: expense, label: 'Monthly lifestyle cost today'),
                const SizedBox(height: 12),
                MoneyField(controller: corpus, label: 'Current investable corpus'),
                const SizedBox(height: 12),
                MoneyField(controller: sip, label: 'Monthly investment'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AssumptionTile(
            icon: Icons.tune_rounded,
            title: 'Retirement assumptions',
            subtitle: '${inflation.text}% inflation · ${preReturn.text}% growth · ${postReturn.text}% post-FIRE',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: NumberField(controller: inflation, label: 'Inflation', suffix: '%')),
                    const SizedBox(width: 12),
                    Expanded(child: NumberField(controller: stepUp, label: 'SIP step-up', suffix: '%')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: NumberField(controller: preReturn, label: 'Pre-FIRE return', suffix: '%')),
                    const SizedBox(width: 12),
                    Expanded(child: NumberField(controller: postReturn, label: 'Post-FIRE return', suffix: '%')),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Use conservative assumptions for planning. Actual market returns and inflation will vary.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryAction(
            label: 'Simulate my retirement',
            loading: loading,
            icon: Icons.play_arrow_rounded,
            onPressed: calculate,
          ),
          if (error != null) ErrorBanner(error!),
          if (result != null) ...[
            const SizedBox(height: 18),
            _RetirementResult(result: result!),
          ],
        ],
      ),
    );
  }
}

class _RetirementResult extends StatelessWidget {
  const _RetirementResult({required this.result});

  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    final survives = result['survives_to_life_expectancy'] == true;
    final years = result['years_to_retirement']?.toString() ?? '—';
    final depletion = result['depletion_age']?.toString() ?? 'Not depleted';

    return SectionCard(
      borderColor: (survives ? AppColors.success : AppColors.danger).withValues(alpha: .25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (survives ? AppColors.success : AppColors.danger).withValues(alpha: .08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  survives ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                  size: 18,
                  color: survives ? AppColors.success : AppColors.danger,
                ),
                const SizedBox(width: 6),
                Text(
                  survives ? 'Plan survives to your planning age' : 'This plan needs adjustment',
                  style: TextStyle(
                    color: survives ? AppColors.success : AppColors.danger,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text('Your retirement picture', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          ResultMetric(
            label: 'Projected corpus when you retire',
            value: money(result['projected_corpus_at_retirement']),
            emphasis: true,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: ResultMetric(label: 'Years to FIRE', value: years)),
              const SizedBox(width: 10),
              Expanded(child: ResultMetric(label: 'Monthly cost at FIRE', value: money(result['expense_at_retirement_monthly']))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: ResultMetric(label: 'Corpus at plan end', value: money(result['corpus_at_life_expectancy']))),
              const SizedBox(width: 10),
              Expanded(child: ResultMetric(label: 'Depletion age', value: depletion)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.navySoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.navy),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'v0.2 uses deterministic annual returns. Monte Carlo and sequence-of-return risk are planned for the next modelling layer.',
                    style: TextStyle(color: AppColors.navy, height: 1.45, fontWeight: FontWeight.w600),
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
