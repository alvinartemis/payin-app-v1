import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'analytics_controller.dart';
import 'widgets/sales_chart.dart';
import 'widgets/revenue_card.dart';
import 'widgets/invoice_status_chart.dart';
import 'widgets/top_clients_list.dart';
import 'widgets/monthly_trend_chart.dart';
import 'widgets/analytics_summary.dart';

class AnalyticsScreen extends GetView<AnalyticsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Analytics & Laporan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadAnalyticsData,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return RefreshIndicator(
          onRefresh: controller.loadAnalyticsData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Selector
                _buildPeriodSelector(),
                
                const SizedBox(height: 24),
                
                // Analytics Summary Cards
                AnalyticsSummary(controller: controller),
                
                const SizedBox(height: 24),
                
                // Revenue Cards
                Row(
                  children: [
                    Expanded(
                      child: RevenueCard(
                        title: 'Total Revenue',
                        value: controller.totalRevenueFormatted,
                        icon: Icons.attach_money,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: RevenueCard(
                        title: 'Rata-rata Invoice',
                        value: controller.averageInvoiceFormatted,
                        icon: Icons.receipt,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Sales Chart
                SalesChart(controller: controller),
                
                const SizedBox(height: 24),
                
                // Invoice Status Chart
                InvoiceStatusChart(controller: controller),
                
                const SizedBox(height: 24),
                
                // Monthly Trend Chart
                MonthlyTrendChart(controller: controller),
                
                const SizedBox(height: 24),
                
                // Top Clients List
                TopClientsList(controller: controller),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Periode Analisis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Wrap(
            spacing: 8,
            children: controller.periodOptions.map((period) {
              final isSelected = controller.selectedPeriod.value == period;
              return FilterChip(
                label: Text(controller.getPeriodText(period)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    controller.changePeriod(period);
                  }
                },
                backgroundColor: Colors.grey.shade100,
                selectedColor: Colors.blue.shade100,
                checkmarkColor: Colors.blue,
              );
            }).toList(),
          )),
        ],
      ),
    );
  }
}
