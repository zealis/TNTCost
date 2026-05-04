import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../view_models/stats_view_model.dart';
import '../utils/date_utils.dart' as app_date;
import '../utils/money_utils.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  String _filterPeriod = 'month'; // week, month, year
  DateTime _selectedDate = DateTime.now();
  String _currentType = 'expense'; // expense, income

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  void loadStats() {
    DateTime startDate, endDate;
    
    switch (_filterPeriod) {
      case 'week':
        startDate = app_date.AppDateUtils.getStartOfWeek(_selectedDate);
        endDate = app_date.AppDateUtils.getEndOfWeek(_selectedDate);
        break;
      case 'month':
        startDate = app_date.AppDateUtils.getStartOfMonth(_selectedDate);
        endDate = app_date.AppDateUtils.getEndOfMonth(_selectedDate);
        break;
      case 'year':
        startDate = app_date.AppDateUtils.getStartOfYear(_selectedDate);
        endDate = app_date.AppDateUtils.getEndOfYear(_selectedDate);
        break;
      default:
        startDate = app_date.AppDateUtils.getStartOfMonth(_selectedDate);
        endDate = app_date.AppDateUtils.getEndOfMonth(_selectedDate);
    }
    
    ref.read(statsViewModelProvider.notifier).loadStats(
      startDate: startDate,
      endDate: endDate,
      type: _currentType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsViewModelProvider);
    final totalIncome = stats['totalIncome'] ?? 0.0;
    final totalExpense = stats['totalExpense'] ?? 0.0;
    final balance = stats['balance'] ?? 0.0;
    final categoryStats = (stats['categoryStats'] as Map<dynamic, dynamic>?)?.map((key, value) => MapEntry(key.toString(), (value as num).toDouble())) ?? {};
    final categoryCounts = (stats['categoryCounts'] as Map<dynamic, dynamic>?)?.map((key, value) => MapEntry(key.toString(), (value as num).toInt())) ?? {};
    final trendData = (stats['trendData'] as List<dynamic>?)?.map((item) => item as Map<String, dynamic>).toList() ?? [];
    final isLoading = stats['isLoading'] ?? false;
    
    final incomeSpots = _getIncomeSpots(trendData);
    final expenseSpots = _getExpenseSpots(trendData);
    final maxY = _calculateMaxY(trendData);
    final interval = maxY / 5;

    return Scaffold(
      appBar: AppBar(
        title: const Text('数据统计'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => setState(() {
                                _filterPeriod = 'week';
                                loadStats();
                              }),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _filterPeriod == 'week' ? Colors.blue : Colors.grey,
                              ),
                              child: const Text('周'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => setState(() {
                                _filterPeriod = 'month';
                                loadStats();
                              }),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _filterPeriod == 'month' ? Colors.blue : Colors.grey,
                              ),
                              child: const Text('月'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => setState(() {
                                _filterPeriod = 'year';
                                loadStats();
                              }),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _filterPeriod == 'year' ? Colors.blue : Colors.grey,
                              ),
                              child: const Text('年'),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _selectedDate = pickedDate;
                                loadStats();
                              });
                            }
                          },
                          child: Text('${_selectedDate.year}-${_selectedDate.month}'),
                        ),
                      ],
                    ),
                  ),
                  
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '收支概览',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  const Text('收入'),
                                  Text(
                                    MoneyUtils.formatMoney(totalIncome),
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('支出'),
                                  Text(
                                    MoneyUtils.formatMoney(totalExpense),
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('结余'),
                                  Text(
                                    MoneyUtils.formatMoney(balance),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '支出分类占比',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => setState(() {
                                      _currentType = 'expense';
                                      loadStats();
                                    }),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _currentType == 'expense' ? Colors.blue : Colors.grey,
                                    ),
                                    child: const Text('支出'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => setState(() {
                                      _currentType = 'income';
                                      loadStats();
                                    }),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _currentType == 'income' ? Colors.blue : Colors.grey,
                                    ),
                                    child: const Text('收入'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isSmallScreen = constraints.maxWidth < 600;
                                  
                                  return isSmallScreen
                                      ? Column(
                                          children: [
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                SizedBox(
                                                  height: 250,
                                                  child: PieChart(
                                                    PieChartData(
                                                      sections: _getPieSections(categoryStats, _currentType == 'expense' ? totalExpense : totalIncome),
                                                      centerSpaceRadius: 50,
                                                      sectionsSpace: 2,
                                                      pieTouchData: PieTouchData(
                                                        touchCallback: (event, response) {},
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      _currentType == 'expense' ? '总支出' : '总收入',
                                                      style: const TextStyle(fontSize: 14, color: Colors.black),
                                                    ),
                                                    Text(
                                                      MoneyUtils.formatMoney(_currentType == 'expense' ? totalExpense : totalIncome),
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            SizedBox(
                                              width: double.infinity,
                                              child: _buildCategoryLabels(categoryStats, categoryCounts, _currentType == 'expense' ? totalExpense : totalIncome),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Expanded(
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  SizedBox(
                                                    height: 300,
                                                    child: PieChart(
                                                      PieChartData(
                                                        sections: _getPieSections(categoryStats, _currentType == 'expense' ? totalExpense : totalIncome),
                                                        centerSpaceRadius: 60,
                                                        sectionsSpace: 2,
                                                        pieTouchData: PieTouchData(
                                                          touchCallback: (event, response) {},
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        _currentType == 'expense' ? '总支出' : '总收入',
                                                        style: const TextStyle(fontSize: 16, color: Colors.black),
                                                      ),
                                                      Text(
                                                        MoneyUtils.formatMoney(_currentType == 'expense' ? totalExpense : totalIncome),
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: _buildCategoryLabels(categoryStats, categoryCounts, _currentType == 'expense' ? totalExpense : totalIncome),
                                            ),
                                          ],
                                        );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '收支趋势',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 300,
                            child: LineChart(
                              LineChartData(
                                minY: 0,
                                maxY: maxY,
                                clipData: FlClipData.all(),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: interval,
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: incomeSpots,
                                    isCurved: true,
                                    preventCurveOverShooting: true,
                                    curveSmoothness: 0.35,
                                    color: Colors.green,
                                    barWidth: 3,
                                    dotData: FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Colors.green.withOpacity(0.1),
                                    ),
                                  ),
                                  LineChartBarData(
                                    spots: expenseSpots,
                                    isCurved: true,
                                    preventCurveOverShooting: true,
                                    curveSmoothness: 0.35,
                                    color: Colors.red,
                                    barWidth: 3,
                                    dotData: FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Colors.red.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 50,
                                      interval: interval,
                                      getTitlesWidget: (value, meta) {
                                        if (value < 0) return const SizedBox.shrink();
                                        return Text(
                                          MoneyUtils.formatCompact(value),
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        return _getBottomTitle(value.toInt(), trendData);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  List<FlSpot> _getIncomeSpots(List<Map<String, dynamic>> trendData) {
    final spots = <FlSpot>[];
    for (int i = 0; i < trendData.length; i++) {
      final data = trendData[i];
      double value = (data['income'] ?? 0.0);
      if (value < 0) value = 0;
      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }

  List<FlSpot> _getExpenseSpots(List<Map<String, dynamic>> trendData) {
    final spots = <FlSpot>[];
    for (int i = 0; i < trendData.length; i++) {
      final data = trendData[i];
      double value = (data['expense'] ?? 0.0);
      if (value < 0) value = 0;
      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }

  double _calculateMaxY(List<Map<String, dynamic>> trendData) {
    double maxValue = 0;
    for (final data in trendData) {
      final income = (data['income'] ?? 0.0);
      final expense = (data['expense'] ?? 0.0);
      maxValue = [maxValue, income, expense].reduce((a, b) => a > b ? a : b);
    }
    return maxValue > 0 ? maxValue * 1.1 : 100;
  }

  Widget _getBottomTitle(int index, List<Map<String, dynamic>> trendData) {
    if (index >= trendData.length) return const Text('');
    
    final data = trendData[index];
    final date = DateTime.parse(data['date']);
    
    switch (_filterPeriod) {
      case 'week':
        const weekdays = ['日', '一', '二', '三', '四', '五', '六'];
        return Text('周${weekdays[date.weekday % 7]}');
      case 'month':
        return Text('${date.day}日');
      case 'year':
        return Text('${date.month}月');
      default:
        return Text('${date.day}日');
    }
  }

  List<PieChartSectionData> _getPieSections(Map<String, double> categoryStats, double totalExpense) {
    final List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];
    
    final sections = <PieChartSectionData>[];
    categoryStats.entries.forEach((entry) {
      final index = categoryStats.entries.toList().indexOf(entry);
      final color = colors[index % colors.length];
      final percentage = (entry.value / (totalExpense > 0 ? totalExpense : 1)) * 100;
      
      sections.add(PieChartSectionData(
        value: entry.value,
        title: percentage > 5 ? '${entry.key}\n${percentage.toStringAsFixed(1)}%' : '',
        color: color,
        radius: 60,
      ));
    });
    
    return sections;
  }

  Widget _buildCategoryLabels(Map<String, double> categoryStats, Map<String, int> categoryCounts, double totalExpense) {
    final List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];
    
    final sortedEntries = categoryStats.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    final labels = <Widget>[];
    sortedEntries.forEach((entry) {
      final index = sortedEntries.indexOf(entry);
      final color = colors[index % colors.length];
      final percentage = (entry.value / (totalExpense > 0 ? totalExpense : 1)) * 100;
      final count = categoryCounts[entry.key] ?? 0;
      
      labels.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        color: color,
                        margin: const EdgeInsets.only(right: 8),
                      ),
                      Text(
                        entry.key,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(fontSize: 12, color: color),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        MoneyUtils.formatMoney(entry.value),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$count笔',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ],
          ),
        ),
      );
    });
    
    return Column(children: labels);
  }
}
