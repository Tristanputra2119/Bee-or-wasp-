import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/prediction_result.dart';
import '../utils/constants.dart';

class ResultCard extends StatelessWidget {
  final PredictionResult result;
  final VoidCallback? onDismiss;

  const ResultCard({
    super.key,
    required this.result,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final classColor = ClassInfo.colors[result.className] ?? AppColors.primary(context);
    final classIcon = ClassInfo.icons[result.className] ?? Icons.help_outline;
    final displayName = ClassInfo.displayNames[result.className] ?? result.className;
    final description = ClassInfo.descriptions[result.className] ?? '';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface(context).withOpacity(0.9),
            AppColors.surfaceLight(context).withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: classColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: classColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with main result
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    classColor.withOpacity(0.2),
                    classColor.withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: classColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      classIcon,
                      size: 40,
                      color: classColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Class name
                  Text(
                    displayName,
                    style: AppTextStyles.heading2(context).copyWith(
                      color: classColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.caption(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Confidence
                  _buildConfidenceBadge(context, classColor),
                ],
              ),
            ),
            // Chart section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Predictions',
                    style: AppTextStyles.heading3(context),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildBarChart(context),
                  ),
                ],
              ),
            ),
            // Dismiss button
            if (onDismiss != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: TextButton(
                  onPressed: onDismiss,
                  child: Text(
                    'Try Another Image',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(BuildContext context, Color color) {
    final percent = result.confidencePercent;
    String confidenceLevel;
    Color badgeColor;

    if (result.isHighConfidence) {
      confidenceLevel = 'High Confidence';
      badgeColor = AppColors.success(context);
    } else if (result.isMediumConfidence) {
      confidenceLevel = 'Medium Confidence';
      badgeColor = AppColors.warning(context);
    } else {
      confidenceLevel = 'Low Confidence';
      badgeColor = AppColors.error(context);
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: badgeColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                result.isHighConfidence
                    ? Icons.check_circle
                    : result.isMediumConfidence
                        ? Icons.info
                        : Icons.warning,
                size: 16,
                color: badgeColor,
              ),
              const SizedBox(width: 8),
              Text(
                confidenceLevel,
                style: AppTextStyles.caption(context).copyWith(
                  color: badgeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${percent.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.surface(context),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final prediction = result.allPredictions[group.x.toInt()];
              return BarTooltipItem(
                '${prediction.className}\n${prediction.confidencePercent.toStringAsFixed(1)}%',
                AppTextStyles.caption(context).copyWith(color: AppColors.textPrimary(context)),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= result.allPredictions.length) {
                  return const SizedBox.shrink();
                }
                final prediction = result.allPredictions[value.toInt()];
                final icon = ClassInfo.icons[prediction.className] ?? Icons.help_outline;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Icon(
                    icon,
                    size: 20,
                    color: ClassInfo.colors[prediction.className] ?? AppColors.textMuted(context),
                  ),
                );
              },
              reservedSize: 32,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 25,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: AppTextStyles.caption(context).copyWith(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.textMuted(context).withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: result.allPredictions.asMap().entries.map((entry) {
          final index = entry.key;
          final prediction = entry.value;
          final color = ClassInfo.colors[prediction.className] ?? AppColors.textMuted(context);
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: prediction.confidencePercent,
                color: color,
                width: 32,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 100,
                  color: color.withOpacity(0.1),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
