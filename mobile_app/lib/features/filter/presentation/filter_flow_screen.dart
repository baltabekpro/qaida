import 'package:flutter/material.dart';

import '../../../app/data/mock_data.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../shared/widgets/qaida_scaffold.dart';

class FilterFlowScreen extends StatefulWidget {
  const FilterFlowScreen({super.key});

  @override
  State<FilterFlowScreen> createState() => _FilterFlowScreenState();
}

class _FilterFlowScreenState extends State<FilterFlowScreen> {
  static const _steps = <_FilterStepData>[
    _FilterStepData(
      title: 'С кем идёшь?',
      subtitle: 'Выбери один вариант',
      selectionMode: _FilterSelectionMode.single,
      options: [
        _FilterOptionData(
          label: 'Один',
          icon: Icons.person_rounded,
          tone: _FilterTone.base,
        ),
        _FilterOptionData(
          label: 'Пара',
          icon: Icons.diversity_1_rounded,
          tone: _FilterTone.peach,
        ),
        _FilterOptionData(
          label: 'Друзья',
          icon: Icons.groups_rounded,
          tone: _FilterTone.primary,
        ),
        _FilterOptionData(
          label: 'Семья',
          icon: Icons.family_restroom_rounded,
          tone: _FilterTone.green,
        ),
      ],
    ),
    _FilterStepData(
      title: 'Какой вайб нужен?',
      subtitle: 'Выбери настроение для вечера',
      selectionMode: _FilterSelectionMode.single,
      options: [
        _FilterOptionData(
          label: 'Уютно',
          icon: Icons.local_cafe_rounded,
          tone: _FilterTone.primary,
        ),
        _FilterOptionData(
          label: 'Романтично',
          icon: Icons.favorite_rounded,
          tone: _FilterTone.blush,
        ),
        _FilterOptionData(
          label: 'Празднично',
          icon: Icons.celebration_rounded,
          tone: _FilterTone.peach,
        ),
        _FilterOptionData(
          label: 'На воздухе',
          icon: Icons.park_rounded,
          tone: _FilterTone.green,
        ),
      ],
    ),
    _FilterStepData(
      title: 'Какой бюджет комфортен?',
      subtitle: 'Это поможет точнее подобрать места',
      selectionMode: _FilterSelectionMode.single,
      options: [
        _FilterOptionData(
          label: 'До 4 000 ₽',
          icon: Icons.savings_rounded,
          tone: _FilterTone.base,
        ),
        _FilterOptionData(
          label: '4 000–8 000 ₽',
          icon: Icons.payments_rounded,
          tone: _FilterTone.primary,
        ),
        _FilterOptionData(
          label: '8 000–15 000 ₽',
          icon: Icons.credit_card_rounded,
          tone: _FilterTone.peach,
        ),
        _FilterOptionData(
          label: 'Без разницы',
          icon: Icons.tune_rounded,
          tone: _FilterTone.indigo,
        ),
      ],
    ),
    _FilterStepData(
      title: 'Что ещё важно?',
      subtitle: 'Можно выбрать до трёх параметров',
      selectionMode: _FilterSelectionMode.multi,
      options: [
        _FilterOptionData(
          label: 'Открыто сейчас',
          icon: Icons.schedule_rounded,
          tone: _FilterTone.primary,
        ),
        _FilterOptionData(
          label: 'Парковка',
          icon: Icons.directions_car_rounded,
          tone: _FilterTone.primary,
        ),
        _FilterOptionData(
          label: 'Халал',
          icon: Icons.restaurant_rounded,
          tone: _FilterTone.base,
        ),
        _FilterOptionData(
          label: 'Терраса',
          icon: Icons.deck_rounded,
          tone: _FilterTone.green,
        ),
      ],
    ),
  ];

  int _stepIndex = 0;
  final Map<int, String> _singleSelections = {
    0: 'Друзья',
    1: 'Уютно',
    2: '4 000–8 000 ₽',
  };
  final Set<String> _extraSelections = {'Открыто сейчас', 'Парковка'};

  _FilterStepData get _currentStep => _steps[_stepIndex];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (_stepIndex + 1) / _steps.length;
    final canContinue = _canContinue();

    return QaidaScaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _TopBar(
              onBack: _handleBack,
              onClose: () => Navigator.of(context).maybePop(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: _ProgressBlock(
              stepIndex: _stepIndex,
              totalSteps: _steps.length,
              progress: progress,
              isDark: isDark,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StepHeader(step: _currentStep, isDark: isDark),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _currentStep.options.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final option = _currentStep.options[index];
                      final selected = _isSelected(option.label);
                      return _FilterOptionCard(
                        option: option,
                        selected: selected,
                        isDark: isDark,
                        onTap: () => _handleOptionTap(option.label),
                      );
                    },
                  ),
                  if (_stepIndex == _steps.length - 1) ...[
                    const SizedBox(height: 20),
                    _SelectionSummary(
                      isDark: isDark,
                      chips: [
                        _SummaryChipData(
                          icon: Icons.groups_rounded,
                          label: _singleSelections[0] ?? '',
                        ),
                        _SummaryChipData(
                          icon: Icons.local_cafe_rounded,
                          label: _singleSelections[1] ?? '',
                        ),
                        _SummaryChipData(
                          icon: Icons.payments_rounded,
                          label: _singleSelections[2] ?? '',
                        ),
                      ].where((chip) => chip.label.isNotEmpty).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          _FooterAction(
            isDark: isDark,
            label: _stepIndex == _steps.length - 1
                ? 'Показать ${MockData.places.length} мест'
                : 'Далее',
            enabled: canContinue,
            onPressed: canContinue ? _handleContinue : null,
          ),
        ],
      ),
    );
  }

  bool _canContinue() {
    if (_currentStep.selectionMode == _FilterSelectionMode.single) {
      return _singleSelections[_stepIndex] != null;
    }
    return _extraSelections.isNotEmpty;
  }

  bool _isSelected(String label) {
    if (_currentStep.selectionMode == _FilterSelectionMode.single) {
      return _singleSelections[_stepIndex] == label;
    }
    return _extraSelections.contains(label);
  }

  void _handleOptionTap(String label) {
    setState(() {
      if (_currentStep.selectionMode == _FilterSelectionMode.single) {
        _singleSelections[_stepIndex] = label;
        return;
      }

      if (_extraSelections.contains(label)) {
        _extraSelections.remove(label);
        return;
      }

      if (_extraSelections.length < 3) {
        _extraSelections.add(label);
      }
    });
  }

  void _handleBack() {
    if (_stepIndex == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _stepIndex -= 1);
  }

  void _handleContinue() {
    if (_stepIndex == _steps.length - 1) {
      Navigator.of(context).pop({
        'companions': _singleSelections[0],
        'vibe': _singleSelections[1],
        'budget': _singleSelections[2],
        'details': _extraSelections.toList(),
      });
      return;
    }
    setState(() => _stepIndex += 1);
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack, required this.onClose});

  final VoidCallback onBack;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        Expanded(
          child: Text(
            'Фильтры',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: Icon(
            Icons.close_rounded,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({
    required this.stepIndex,
    required this.totalSteps,
    required this.progress,
    required this.isDark,
  });

  final int stepIndex;
  final int totalSteps;
  final double progress;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Шаг ${stepIndex + 1} из $totalSteps',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step, required this.isDark});

  final _FilterStepData step;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.title,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 31,
                height: 1.06,
                letterSpacing: -0.9,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          step.subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _FilterOptionCard extends StatelessWidget {
  const _FilterOptionCard({
    required this.option,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final _FilterOptionData option;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final decoration = _decoration();
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      scale: selected ? 1 : 0.985,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: decoration,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  top: selected ? 12 : 16,
                  right: selected ? 12 : 16,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    scale: selected ? 1 : 0.72,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 140),
                      opacity: selected ? 1 : 0,
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      AnimatedSlide(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        offset: selected ? Offset.zero : const Offset(0, 0.02),
                        child: Icon(option.icon, size: 34, color: AppColors.primary),
                      ),
                      const SizedBox(height: 12),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: isDark ? AppColors.darkText : const Color(0xFF1E293B),
                            ),
                        child: Text(option.label),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _decoration() {
    if (isDark) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.42)
              : Colors.white.withValues(alpha: 0.08),
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: selected
              ? const [Color(0xFF13203A), Color(0xFF0F172A)]
              : _darkToneColors(option.tone),
        ),
        boxShadow: [
          BoxShadow(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.16)
                : Colors.black.withValues(alpha: 0.12),
            blurRadius: selected ? 24 : 18,
            offset: const Offset(0, 8),
          ),
        ],
      );
    }

    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: selected
            ? const Color(0xFF9DBBFF)
            : const Color(0xEBCBD5E1),
        width: selected ? 1.25 : 1,
      ),
      color: selected ? const Color(0xFFF7FAFF) : Colors.white,
      boxShadow: [
        BoxShadow(
          color: selected ? const Color(0x122463EB) : const Color(0x0A0F172A),
          blurRadius: selected ? 14 : 10,
          offset: selected ? const Offset(0, 4) : const Offset(0, 2),
        ),
      ],
    );
  }

  List<Color> _darkToneColors(_FilterTone tone) {
    return switch (tone) {
      _FilterTone.peach => const [Color(0xFF161D28), Color(0xFF1C2330)],
      _FilterTone.blush => const [Color(0xFF171A29), Color(0xFF1F1B2A)],
      _FilterTone.green => const [Color(0xFF13211B), Color(0xFF172821)],
      _FilterTone.indigo => const [Color(0xFF141A2C), Color(0xFF1A2035)],
      _FilterTone.primary => const [Color(0xFF13203A), Color(0xFF182235)],
      _FilterTone.base => const [Color(0xFF111827), Color(0xFF172033)],
    };
  }
}

class _SelectionSummary extends StatelessWidget {
  const _SelectionSummary({required this.isDark, required this.chips});

  final bool isDark;
  final List<_SummaryChipData> chips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Выбрано',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
                  letterSpacing: 1.6,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (chip) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(chip.icon, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          chip.label,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({
    required this.isDark,
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final bool isDark;
  final String label;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            minimumSize: Size.fromHeight(label.startsWith('Показать') ? 54 : 52),
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.42),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (!label.startsWith('Показать')) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterStepData {
  const _FilterStepData({
    required this.title,
    required this.subtitle,
    required this.selectionMode,
    required this.options,
  });

  final String title;
  final String subtitle;
  final _FilterSelectionMode selectionMode;
  final List<_FilterOptionData> options;
}

class _FilterOptionData {
  const _FilterOptionData({
    required this.label,
    required this.icon,
    required this.tone,
  });

  final String label;
  final IconData icon;
  final _FilterTone tone;
}

class _SummaryChipData {
  const _SummaryChipData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

enum _FilterSelectionMode { single, multi }

enum _FilterTone { base, primary, peach, blush, green, indigo }