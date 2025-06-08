import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../analytics_controller.dart';

class MonthlyTrendChart extends StatelessWidget {
  final AnalyticsController controller;

  const MonthlyTrendChart({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trend Revenue Bulanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '6 Bulan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: controller.monthlyTrend.isEmpty
                ? _buildEmptyChart()
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _getHorizontalInterval(),
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: _getBottomTitles,
                            interval: 1,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: _getLeftTitles,
                            reservedSize: 60,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                          left: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      minX: 0,
                      maxX: (controller.monthlyTrend.length - 1).toDouble(),
                      minY: 0,
                      maxY: _getMaxY(),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _getSpots(),
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade600,
                            ],
                          ),
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 6,
                                color: Colors.green.shade600,
                                strokeWidth: 3,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade100.withOpacity(0.4),
                                Colors.green.shade50.withOpacity(0.1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          _buildTrendSummary(),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data trend',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Data trend akan muncul setelah beberapa bulan',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getSpots() {
    return controller.monthlyTrend.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final revenue = (data['revenue'] as double?) ?? 0.0;
      return FlSpot(index.toDouble(), revenue);
    }).toList();
  }

  double _getMaxY() {
    if (controller.monthlyTrend.isEmpty) return 100;
    
    double maxRevenue = 0.0;
    for (final data in controller.monthlyTrend) {
      final revenue = (data['revenue'] as double?) ?? 0.0;
      if (revenue > maxRevenue) {
        maxRevenue = revenue;
      }
    }
    
    return maxRevenue * 1.2; // Add 20% padding
  }

  double _getHorizontalInterval() {
    final maxY = _getMaxY();
    return maxY / 4; // Show 4 horizontal lines
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    if (value.toInt() >= controller.monthlyTrend.length) {
      return const SizedBox.shrink();
    }
    
    final data = controller.monthlyTrend[value.toInt()];
    final month = data['month'] as String? ?? '';
    
    // Extract month from "MM/YYYY" format
    final monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 
                       'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    
    try {
      final parts = month.split('/');
      if (parts.length == 2) {
        final monthNum = int.parse(parts[0]);
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            monthNames[monthNum],
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        );
      }
    } catch (e) {
      // Fallback to original string
    }
    
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        month,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
    return Text(
      _formatCurrency(value),
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey.shade600,
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  Widget _buildTrendSummary() {
    if (controller.monthlyTrend.length < 2) {
      return const SizedBox.shrink();
    }

    final currentMonth = controller.monthlyTrend.last;
    final previousMonth = controller.monthlyTrend[controller.monthlyTrend.length - 2];
    
    final currentRevenue = (currentMonth['revenue'] as double?) ?? 0.0;
    final previousRevenue = (previousMonth['revenue'] as double?) ?? 0.0;
    
    final growth = previousRevenue > 0 
        ? ((currentRevenue - previousRevenue) / previousRevenue) * 100 
        : 0.0;
    
    final isPositive = growth >= 0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isPositive 
                  ? 'Naik ${growth.abs().toStringAsFixed(1)}% dari bulan lalu'
                  : 'Turun ${growth.abs().toStringAsFixed(1)}% dari bulan lalu',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ),
          Text(
            'Rp ${(currentRevenue - previousRevenue).abs().toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
