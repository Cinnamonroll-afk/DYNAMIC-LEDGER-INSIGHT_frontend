import 'package:fincontrol/features/wealth/presentation/widgets/add_entry_sheet.dart';
import 'package:fincontrol/features/notifications/presentation/pages/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:fincontrol/features/wealth/data/models/asset_model.dart';
import 'package:fincontrol/features/wealth/data/repositories/market_api_repository.dart';
import 'package:fincontrol/core/widgets/glass_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fincontrol/l10n/app_localizations.dart';
import 'package:fincontrol/features/settings/bloc/currency_cubit.dart';
import 'package:fincontrol/core/utils/currency_formatter.dart';

class AssetDetailPage extends StatefulWidget {
  final AssetModel asset;
  final String? portfolioId;
  const AssetDetailPage({super.key, required this.asset, this.portfolioId});
  @override
  State<AssetDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetDetailPage> {
  final MarketApiRepository _apiRepository = MarketApiRepository();
  String _selectedTimeframe = '1D';
  Future<List<double>>? _chartDataFuture;
  
  double? _fetchedPrice;
  double? _fetchedChangeValue;
  double? _fetchedChangePercent;
  
  Map<String, dynamic>? _fetchedStats;

  @override
  void initState() {
    super.initState();
    _fetchChartData(_selectedTimeframe);
    _fetchStats();
  }

  void _fetchStats() async {
    final stats = await _apiRepository.getAssetStats(widget.asset.tickerSymbol);
    if (mounted) {
      setState(() {
        _fetchedStats = stats;
      });
    }
  }

  void _fetchChartData(String timeframe) {
    String range = '1d';
    String interval = '15m';

    switch (timeframe) {
      case '1W': range = '5d'; interval = '1h'; break;
      case '1M': range = '1mo'; interval = '1d'; break;
      case '6M': range = '6mo'; interval = '1d'; break;
      case 'YTD': range = 'ytd'; interval = '1d'; break;
      case '1Y': range = '1y'; interval = '1d'; break;
      case '1D':
      default: range = '1d'; interval = '15m'; break;
    }

    final future = _apiRepository.getChartData(widget.asset.tickerSymbol, interval: interval, range: range);
    future.then((data) {
      if (data.isNotEmpty && mounted) {
        final current = data.last;
        final first = data.first;
        final change = current - first;
        final percent = first > 0 ? (change / first) * 100 : 0.0;
        
        setState(() {
          _fetchedPrice = current;
          _fetchedChangeValue = change;
          _fetchedChangePercent = percent;
        });
      }
    });

    setState(() {
      _selectedTimeframe = timeframe;
      _chartDataFuture = future;
    });
  }

  String _formatNumber(num? value) {
    if (value == null) return '-';
    if (value >= 1e12) return '${(value / 1e12).toStringAsFixed(2)}T';
    if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(2)}B';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(2)}M';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(2)}k';
    return value.toStringAsFixed(2);
  }

  Widget _buildChart(List<double> data, bool isPositive) {
    if (data.isEmpty) {
      return Icon(Icons.show_chart, size: 100, color: isPositive ? Colors.greenAccent.shade400 : Colors.redAccent.shade400);
    }
    
    final spots = data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
    final minY = data.reduce((a, b) => a < b ? a : b);
    final maxY = data.reduce((a, b) => a > b ? a : b);
    final color = isPositive ? Colors.greenAccent.shade400 : Colors.redAccent.shade400;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: minY * 0.999,
        maxY: maxY * 1.001,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 2.25,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.22),
                  color.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, currencyState) {
        final asset = widget.asset;
        final String baseCurrency = _fetchedStats?['currency'] ?? (asset.tickerSymbol.endsWith('.BK') ? 'THB' : 'USD');
        
        final double displayPriceRaw = _fetchedPrice ?? _fetchedStats?['regularMarketPrice']?.toDouble() ?? asset.currentPrice;
        final double changeValueRaw = _fetchedChangeValue ?? _fetchedStats?['regularMarketChange']?.toDouble() ?? (asset.currentPrice - asset.averageBuyPrice);
        
        final double displayPrice = CurrencyFormatter.convert(displayPriceRaw, currencyState, fromCurrency: baseCurrency);
        final double changeValue = CurrencyFormatter.convert(changeValueRaw, currencyState, fromCurrency: baseCurrency);
        final double changePercent = _fetchedChangePercent ?? _fetchedStats?['regularMarketChangePercent']?.toDouble() ?? (asset.averageBuyPrice > 0 ? (changeValueRaw / asset.averageBuyPrice) * 100 : 0.0);
        final bool isPositive = changeValue >= 0;
        
        final openRaw = _fetchedStats?['regularMarketOpen'];
        final highRaw = _fetchedStats?['regularMarketDayHigh'];
        final lowRaw = _fetchedStats?['regularMarketDayLow'];
        final prevCloseRaw = _fetchedStats?['regularMarketPreviousClose'];
        final volume = _fetchedStats?['regularMarketVolume'];
        final mktCapRaw = _fetchedStats?['marketCap'];

        final open = openRaw != null ? CurrencyFormatter.convert(openRaw.toDouble(), currencyState, fromCurrency: baseCurrency) : null;
        final high = highRaw != null ? CurrencyFormatter.convert(highRaw.toDouble(), currencyState, fromCurrency: baseCurrency) : null;
        final low = lowRaw != null ? CurrencyFormatter.convert(lowRaw.toDouble(), currencyState, fromCurrency: baseCurrency) : null;
        final prevClose = prevCloseRaw != null ? CurrencyFormatter.convert(prevCloseRaw.toDouble(), currencyState, fromCurrency: baseCurrency) : null;
        final mktCap = mktCapRaw != null ? CurrencyFormatter.convert(mktCapRaw.toDouble(), currencyState, fromCurrency: baseCurrency) : null;

    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final mutedTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDarkMode 
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
            )
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF8FAFC), Color(0xFFE0E7FF)],
            ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  _buildTopBar(context, textColor, mutedTextColor, primaryColor, isDarkMode),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 128),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildIdentityRow(asset, textColor, mutedTextColor, primaryColor, isDarkMode),
                          const SizedBox(height: 14),
                          _buildTagsRow(asset, textColor, mutedTextColor, primaryColor, isDarkMode),
                          const SizedBox(height: 22),
                          _buildPriceBlock(displayPrice, changeValue, changePercent, isPositive, textColor, mutedTextColor, currencyState),
                          const SizedBox(height: 18),
                          _buildChartCard(displayPrice, isPositive, textColor, mutedTextColor, primaryColor, currencyState),
                          const SizedBox(height: 14),
                          _buildRangeRow(textColor, mutedTextColor, primaryColor, isDarkMode),
                          const SizedBox(height: 22),
                          _buildStatsCard(open, high, low, prevClose, volume, mktCap, textColor, mutedTextColor, currencyState),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              _buildBottomBar(asset, textColor, mutedTextColor, primaryColor, isDarkMode),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, Color? textColor, Color? mutedTextColor, Color primaryColor, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconButton(Icons.arrow_back, () => Navigator.pop(context), textColor),
          Row(
            children: [
              _buildIconButton(Icons.notifications_outlined, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
              }, textColor),
              const SizedBox(width: 8),
              _buildIconButton(Icons.bookmark, () {}, primaryColor, isSelected: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, Color? iconColor, {bool isSelected = false}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? iconColor?.withValues(alpha: 0.2) : null,
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildIdentityRow(AssetModel asset, Color? textColor, Color? mutedTextColor, Color primaryColor, bool isDarkMode) {
    final exchange = _fetchedStats?['exchange'] ?? 'MARKET';
    final type = _fetchedStats?['quoteType'] ?? 'Asset';
    
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(13),
          ),
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Image.asset(
              'assets/icons/${asset.tickerSymbol}.png',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Text(
                  asset.tickerSymbol.isNotEmpty ? asset.tickerSymbol.substring(0, 1) : '?',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                asset.name,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: -0.01,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                '$exchange · $type',
                style: TextStyle(
                  fontSize: 13,
                  color: mutedTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagsRow(AssetModel asset, Color? textColor, Color? mutedTextColor, Color primaryColor, bool isDarkMode) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (asset.category.isNotEmpty) _buildTag(asset.category, false, mutedTextColor, primaryColor),
        if (asset.tickerSymbol.isNotEmpty) _buildTag(asset.tickerSymbol, false, mutedTextColor, primaryColor),
        _buildTag(AppLocalizations.of(context)!.trackedMarket, true, mutedTextColor, primaryColor),
      ],
    );
  }

  Widget _buildTag(String text, bool isMarket, Color? mutedTextColor, Color primaryColor) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      borderRadius: BorderRadius.circular(100),
      color: isMarket ? primaryColor.withValues(alpha: 0.2) : null,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: isMarket ? primaryColor : mutedTextColor,
        ),
      ),
    );
  }

  Widget _buildPriceBlock(double price, double changeValue, double changePercent, bool isPositive, Color? textColor, Color? mutedTextColor, CurrencyState currencyState) {
    final now = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              CurrencyFormatter.format(price, currencyState, fromCurrency: currencyState.selectedCurrency),
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: -0.02,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 7, right: 9, top: 4, bottom: 4),
              decoration: BoxDecoration(
                color: isPositive ? Colors.greenAccent.shade400.withValues(alpha: 0.2) : Colors.redAccent.shade400.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isPositive ? Colors.greenAccent.shade400 : Colors.redAccent.shade400,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${CurrencyFormatter.format(changeValue.abs(), currencyState, showSignForPositive: true, fromCurrency: currencyState.selectedCurrency)} (${changePercent.toStringAsFixed(2)}%)',
                    style: TextStyle(
                      color: isPositive ? Colors.greenAccent.shade400 : Colors.redAccent.shade400,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'today',
              style: TextStyle(
                fontSize: 13,
                color: mutedTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Last updated $now (delayed 15 min)',
          style: TextStyle(
            fontSize: 12,
            color: mutedTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard(double displayPrice, bool isPositive, Color? textColor, Color? mutedTextColor, Color primaryColor, CurrencyState currencyState) {
    return GlassContainer(
      padding: const EdgeInsets.only(top: 18, left: 6, right: 6, bottom: 14),
      borderRadius: BorderRadius.circular(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRICE AT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: mutedTextColor,
                    letterSpacing: 0.03,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.format(displayPrice, currencyState, fromCurrency: currencyState.selectedCurrency),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.greenAccent.shade400 : Colors.redAccent.shade400,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Now · 15:00', // Simplified for demo
                  style: TextStyle(
                    fontSize: 11.5,
                    color: mutedTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: FutureBuilder<List<double>>(
              future: _chartDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Icon(Icons.show_chart, size: 60, color: isPositive ? Colors.greenAccent.shade400 : Colors.redAccent.shade400),
                  );
                }
                return _buildChart(snapshot.data!, isPositive);
              },
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAxisText('10:24', false, primaryColor, mutedTextColor),
                _buildAxisText('11:33', false, primaryColor, mutedTextColor),
                _buildAxisText('12:42', false, primaryColor, mutedTextColor),
                _buildAxisText('13:51', false, primaryColor, mutedTextColor),
                _buildAxisText('15:00', true, primaryColor, mutedTextColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAxisText(String text, bool isNow, Color primaryColor, Color? mutedTextColor) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
        color: isNow ? primaryColor : mutedTextColor,
      ),
    );
  }

  Widget _buildRangeRow(Color? textColor, Color? mutedTextColor, Color primaryColor, bool isDarkMode) {
    return Row(
      children: [
        _buildRangePill('1D', primaryColor, mutedTextColor),
        _buildRangePill('1W', primaryColor, mutedTextColor),
        _buildRangePill('1M', primaryColor, mutedTextColor),
        _buildRangePill('6M', primaryColor, mutedTextColor),
        _buildRangePill('YTD', primaryColor, mutedTextColor),
        _buildRangePill('1Y', primaryColor, mutedTextColor),
      ],
    );
  }

  Widget _buildRangePill(String text, Color primaryColor, Color? mutedTextColor) {
    final bool isActive = _selectedTimeframe == text;
    return Expanded(
      child: GestureDetector(
        onTap: () => _fetchChartData(text),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isActive ? [
              BoxShadow(color: primaryColor.withValues(alpha: 0.28), blurRadius: 14, offset: const Offset(0, 6)),
            ] : null,
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : mutedTextColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(num? open, num? high, num? low, num? prevClose, num? volume, num? mktCap, Color? textColor, Color? mutedTextColor, CurrencyState currencyState) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KEY STATS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: mutedTextColor,
              letterSpacing: 0.04,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatItem(AppLocalizations.of(context)!.openPrice, _formatNumber(open), null, textColor, mutedTextColor)),
              Expanded(child: _buildStatItem(AppLocalizations.of(context)!.highPrice, _formatNumber(high), Colors.greenAccent.shade400, textColor, mutedTextColor)),
              Expanded(child: _buildStatItem(AppLocalizations.of(context)!.lowPrice, _formatNumber(low), Colors.redAccent.shade400, textColor, mutedTextColor)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatItem('Prev. close', open != null ? _formatNumber(prevClose) : '-', null, textColor, mutedTextColor)),
              Expanded(child: _buildStatItem('Volume', _formatNumber(volume), null, textColor, mutedTextColor)),
              Expanded(child: _buildStatItem('Mkt cap', open != null ? _formatNumber(mktCap) : '-', null, textColor, mutedTextColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color? color, Color? textColor, Color? mutedTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            color: mutedTextColor,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
            color: color ?? textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(AssetModel asset, Color? textColor, Color? mutedTextColor, Color primaryColor, bool isDarkMode) {
    final state = _fetchedStats?['marketState'] ?? 'REGULAR';
    String stateLabel = 'Market Open';
    if (state == 'CLOSED') stateLabel = 'Market Closed';
    if (state == 'PRE') stateLabel = 'Pre-market';
    if (state == 'POST') stateLabel = 'Post-market';

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GlassContainer(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 14, bottom: 32),
        borderRadius: BorderRadius.zero,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_fetchedStats?['exchange'] ?? 'Market'} session',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: mutedTextColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        stateLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Trades on ${_fetchedStats?['exchange'] ?? 'Exchange'}',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: mutedTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 6,
                shadowColor: primaryColor.withValues(alpha: 0.5),
              ),
              onPressed: () async {
                final saved = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddEntrySheet(asset: asset, portfolioId: widget.portfolioId),
                );
                if (saved == true && context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Invest',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
