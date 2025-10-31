import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:snacky/features/products/presentation/providers/product_provider.dart';
import 'package:snacky/features/categories/presentation/providers/categorie_provider.dart';
import 'package:snacky/features/orders/presentation/providers/order_provider.dart';
import 'package:snacky/features/promotions/presentation/providers/promotion_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _categoriesCount = 0;
  int _productsCount = 0;
  int _ordersCount = 0;
  int _promotionsCount = 0;
  int _clientsCount = 0;
  double _totalRevenue = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    ref.read(categorieListNotifier.notifier).getCategories();
    ref.read(productListNotifier.notifier).getProduits();
    ref.read(orderListNotifier.notifier).getOrders();
    ref.read(promotionListNotifier.notifier).getPromotions();
  }

  void _animateCounter(int targetValue, Function(int) onUpdate) {
    int currentValue = 0;
    int steps = 30;
    int increment = (targetValue / steps).ceil();

    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (currentValue >= targetValue) {
        onUpdate(targetValue);
        timer.cancel();
      } else {
        currentValue += increment;
        if (currentValue > targetValue) currentValue = targetValue;
        onUpdate(currentValue);
      }
    });
  }

  void _animateRevenue(double targetValue, Function(double) onUpdate) {
    double currentValue = 0;
    int steps = 30;
    double increment = targetValue / steps;

    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (currentValue >= targetValue) {
        onUpdate(targetValue);
        timer.cancel();
      } else {
        currentValue += increment;
        if (currentValue > targetValue) currentValue = targetValue;
        onUpdate(currentValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categorieState = ref.watch(categorieListNotifier);
    final productState = ref.watch(productListNotifier);
    final orderState = ref.watch(orderListNotifier);
    final promotionState = ref.watch(promotionListNotifier);

    // Calculer le nombre de clients uniques
    final uniqueClients = orderState.orders
        .map((order) => order.nomClient.toLowerCase().trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .length;

    // Calculer le chiffre d'affaires total (commandes terminées uniquement)
    final totalRevenue = orderState.orders
        .where((order) => order.statut.toLowerCase() == 'terminé')
        .fold<double>(0, (sum, order) => sum + order.coutTotal);

    // Animer les compteurs une seule fois quand les données arrivent
    if (!categorieState.isLoading &&
        categorieState.categories.isNotEmpty &&
        _categoriesCount == 0) {
      _animateCounter(categorieState.categories.length, (value) {
        if (mounted) setState(() => _categoriesCount = value);
      });
    }
    if (!productState.isLoading &&
        productState.products.isNotEmpty &&
        _productsCount == 0) {
      _animateCounter(productState.products.length, (value) {
        if (mounted) setState(() => _productsCount = value);
      });
    }
    if (!orderState.isLoading &&
        orderState.orders.isNotEmpty &&
        _ordersCount == 0) {
      _animateCounter(orderState.orders.length, (value) {
        if (mounted) setState(() => _ordersCount = value);
      });
    }
    if (!promotionState.isLoading &&
        promotionState.promotions.isNotEmpty &&
        _promotionsCount == 0) {
      _animateCounter(promotionState.promotions.length, (value) {
        if (mounted) setState(() => _promotionsCount = value);
      });
    }
    if (!orderState.isLoading && uniqueClients > 0 && _clientsCount == 0) {
      _animateCounter(uniqueClients, (value) {
        if (mounted) setState(() => _clientsCount = value);
      });
    }

    // Animer le chiffre d'affaires
    if (!orderState.isLoading && totalRevenue > 0 && _totalRevenue == 0) {
      _animateRevenue(totalRevenue, (value) {
        if (mounted) setState(() => _totalRevenue = value);
      });
    }

    final isLoading =
        categorieState.isLoading ||
        productState.isLoading ||
        orderState.isLoading ||
        promotionState.isLoading;

    // Préparer les données pour les graphiques
    final orderStatusData = _getOrderStatusData(orderState.orders);
    final monthlyOrdersData = _getMonthlyOrdersData(orderState.orders);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),
            ),
            Text(" / ", style: TextStyle(color: Colors.grey.shade400)),
            const Text(
              "Statistiques",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.orange),
              onPressed: _loadData,
              tooltip: 'Rafraîchir',
            ),
          ),
        ],
      ),
      body: /*isLoading
          ? Center(
        child: SpinKitThreeBounce(
          color: AppColors.accentOrange,
          size: 30.0,
        ),
      )
          : */ RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              const Text(
                "Vue d'ensemble",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Statistiques en temps réel de votre application",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),

              // 💰 Carte du Chiffre d'Affaires Total (GRANDE CARTE)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepOrange.shade400, Colors.red.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Chiffre d'affaires total",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${_totalRevenue.toStringAsFixed(0)} F CFA",
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Commandes terminées uniquement",
                            style: TextStyle(fontSize: 13, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "+${totalRevenue > 0 ? ((totalRevenue / (orderState.orders.where((o) => o.statut.toLowerCase() == 'terminé').length > 0 ? orderState.orders.where((o) => o.statut.toLowerCase() == 'terminé').length : 1))).toStringAsFixed(0) : '0'}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Cartes de statistiques
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: "Catégories",
                      value: _categoriesCount,
                      icon: Icons.category,
                      color: Colors.purple,
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade400,
                          Colors.purple.shade600,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: "Produits",
                      value: _productsCount,
                      icon: Icons.fastfood,
                      color: Colors.orange,
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade400,
                          Colors.orange.shade600,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: "Commandes",
                      value: _ordersCount,
                      icon: Icons.shopping_cart,
                      color: Colors.blue,
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: "Promotions",
                      value: _promotionsCount,
                      icon: Icons.local_offer,
                      color: Colors.green,
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: "Clients",
                      value: _clientsCount,
                      icon: Icons.people,
                      color: Colors.teal,
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade400, Colors.teal.shade600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Graphiques
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Graphique des statuts de commandes
                  Expanded(
                    flex: 2,
                    child: _buildChartCard(
                      title: "Statuts des commandes",
                      child: _buildPieChart(orderStatusData),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Graphique des commandes mensuelles
                  Expanded(
                    flex: 3,
                    child: _buildChartCard(
                      title: "Évolution des commandes",
                      child: _buildBarChart(monthlyOrdersData),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Statistiques supplémentaires
              _buildChartCard(
                title: "Analyse des ventes",
                child: _buildRevenueChart(orderState.orders),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              Icon(Icons.trending_up, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(height: 300, child: child),
        ],
      ),
    );
  }

  Map<String, int> _getOrderStatusData(List orders) {
    final data = <String, int>{};
    for (var order in orders) {
      final status = order.statut.toLowerCase();
      data[status] = (data[status] ?? 0) + 1;
    }
    return data;
  }

  List<Map<String, dynamic>> _getMonthlyOrdersData(List orders) {
    final monthlyData = <int, int>{};
    for (var order in orders) {
      if (order.createdAt != null) {
        final month = order.createdAt!.month;
        monthlyData[month] = (monthlyData[month] ?? 0) + 1;
      }
    }
    return List.generate(12, (index) {
      return {'month': index + 1, 'count': monthlyData[index + 1] ?? 0};
    });
  }

  Widget _buildPieChart(Map<String, int> data) {
    if (data.isEmpty) {
      return const Center(child: Text("Aucune donnée disponible"));
    }

    final colors = {
      'en cours': Colors.blue,
      'validé': Colors.purple,
      'terminé': Colors.green,
      'annulé': Colors.red,
    };

    final labels = {
      'en cours': 'En cours',
      'validé': 'Validé',
      'terminé': 'Terminé',
      'annulé': 'Annulé',
    };

    return Row(
      children: [
        // Graphique circulaire
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: data.entries.map((entry) {
                final color = colors[entry.key] ?? Colors.grey;
                final total = data.values.reduce((a, b) => a + b);
                final percentage = ((entry.value / total) * 100)
                    .toStringAsFixed(1);

                return PieChartSectionData(
                  value: entry.value.toDouble(),
                  title: '$percentage%',
                  color: color,
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Légendes
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.entries.map((entry) {
              final color = colors[entry.key] ?? Colors.grey;
              final label = labels[entry.key] ?? entry.key;
              final total = data.values.reduce((a, b) => a + b);
              final percentage = ((entry.value / total) * 100).toStringAsFixed(
                1,
              );

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${entry.value} commandes ($percentage%)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> data) {
    final monthNames = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            data
                .map((d) => d['count'] as int)
                .reduce((a, b) => a > b ? a : b)
                .toDouble() +
            5,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < monthNames.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      monthNames[value.toInt()],
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: (entry.value['count'] as int).toDouble(),
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRevenueChart(List orders) {
    final monthlyRevenue = <int, double>{};
    for (var order in orders) {
      if (order.createdAt != null && order.statut.toLowerCase() == 'terminé') {
        final month = order.createdAt!.month;
        monthlyRevenue[month] = (monthlyRevenue[month] ?? 0) + order.coutTotal;
      }
    }

    final spots = List.generate(12, (index) {
      return FlSpot(index.toDouble(), monthlyRevenue[index + 1] ?? 0);
    });

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10000,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const months = [
                  'Jan',
                  'Fév',
                  'Mar',
                  'Avr',
                  'Mai',
                  'Jun',
                  'Jul',
                  'Aoû',
                  'Sep',
                  'Oct',
                  'Nov',
                  'Déc',
                ];
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      months[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value / 1000).toStringAsFixed(0)}K',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [Colors.orange.shade400, Colors.orange.shade600],
            ),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade200.withOpacity(0.3),
                  Colors.orange.shade100.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
