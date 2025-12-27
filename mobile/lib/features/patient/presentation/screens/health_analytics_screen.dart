
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';

class HealthAnalyticsScreen extends StatelessWidget {
  const HealthAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Health Analytics', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGoldNudge(context),
            const SizedBox(height: 24),
            Text(
              'Vital Trends',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color),
            ),
            const SizedBox(height: 16),
            _buildChartCard(
              context,
              title: 'Blood Pressure',
              chart: _buildBPChart(),
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            _buildChartCard(
              context,
              title: 'Heart Rate (BPM)',
              chart: _buildHeartRateChart(),
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 24),
            Text(
              'Lab Result History',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color),
            ),
            const SizedBox(height: 16),
            _buildMetricGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGoldNudge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.limeGreen, Colors.teal],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.black, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unlock Advanced AI Insights',
                  style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Upgrade to GOLD for predictive health alerts.',
                  style: GoogleFonts.outfit(color: Colors.black87, fontSize: 13),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: AppTheme.limeGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, {required String title, required Widget chart, required Color color}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(color: theme.textTheme.bodySmall?.color, fontSize: 14)),
          const SizedBox(height: 20),
          Expanded(child: chart),
        ],
      ),
    );
  }

  Widget _buildBPChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 120),
              const FlSpot(1, 118),
              const FlSpot(2, 125),
              const FlSpot(3, 122),
              const FlSpot(4, 120),
            ],
            isCurved: true,
            color: Colors.redAccent,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.redAccent.withOpacity(0.1),
            ),
          ),
          LineChartBarData(
            spots: [
              const FlSpot(0, 80),
              const FlSpot(1, 78),
              const FlSpot(2, 85),
              const FlSpot(3, 82),
              const FlSpot(4, 80),
            ],
            isCurved: true,
            color: Colors.orangeAccent,
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 72, color: Colors.blueAccent, width: 16)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 75, color: Colors.blueAccent, width: 16)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 68, color: Colors.blueAccent, width: 16)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 82, color: Colors.blueAccent, width: 16)]),
          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 70, color: Colors.blueAccent, width: 16)]),
        ],
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildMetricGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildMetricItem(context, 'Glucose', '95 mg/dL', 'Normal', Colors.green),
        _buildMetricItem(context, 'Cholesterol', '210 mg/dL', 'High', Colors.red),
        _buildMetricItem(context, 'BMI', '23.5', 'Normal', Colors.green),
        _buildMetricItem(context, 'SpO2', '98%', 'Normal', Colors.green),
      ],
    );
  }

  Widget _buildMetricItem(BuildContext context, String label, String value, String status, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.outfit(color: theme.textTheme.bodySmall?.color, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.outfit(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(status, style: GoogleFonts.outfit(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
