import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyChart extends StatefulWidget {
  final Map<String, double> data;

  const WeeklyChart({super.key, required this.data});

  @override
  State<WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<WeeklyChart> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    // Delay slightly to trigger the "growing" animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barGroups = [];
    int index = 0;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxVal = widget.data.values.isEmpty ? 500.0 : widget.data.values.reduce((a, b) => a > b ? a : b) + 500.0;

    widget.data.forEach((day, calories) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              // If not loaded, start at 0 to create the "grow" effect
              toY: _isLoaded ? calories : 0,
              gradient: const LinearGradient(
                colors: [Color(0xFF3D5AFE), Color(0xFF00B0FF)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 16,
              borderRadius: BorderRadius.circular(6),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxVal,
                color: isDark ? const Color(0xFF3D5AFE).withOpacity(0.15) : const Color(0xFF3D5AFE).withOpacity(0.08),
              ),
            ),
          ],
        ),
      );
      index++;
    });

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          maxY: maxVal,
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= widget.data.keys.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      widget.data.keys.elementAt(value.toInt()),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), 
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
        ),
        duration: const Duration(milliseconds: 1000), // Duration of the grow animation
        curve: Curves.elasticOut, // Elastic bounce effect
      ),
    );
  }
}
