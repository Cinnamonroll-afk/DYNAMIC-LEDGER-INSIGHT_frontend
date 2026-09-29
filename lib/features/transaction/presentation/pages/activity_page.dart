import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fincontrol/features/transaction/bloc/transaction_bloc.dart';
import 'package:fincontrol/features/transaction/bloc/transaction_state.dart';
import 'package:fincontrol/features/transaction/bloc/transaction_event.dart';
import 'package:fincontrol/features/transaction/data/models/transaction_model.dart';
import 'package:fincontrol/features/transaction/presentation/widgets/add_transaction_sheet.dart';
import 'package:fincontrol/features/transaction/presentation/widgets/transaction_row.dart';
import 'package:fincontrol/core/widgets/glass_container.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fincontrol/features/notifications/presentation/pages/notifications_page.dart';
import 'package:fincontrol/features/settings/bloc/currency_cubit.dart';
import 'package:fincontrol/core/utils/currency_formatter.dart';
import 'package:fincontrol/l10n/app_localizations.dart';
import 'package:fincontrol/core/constants/app_categories.dart';
import 'package:fincontrol/features/home/logic/insight_summary.dart';
import 'package:fincontrol/features/transaction/logic/activity_period.dart';
import 'package:intl/intl.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  // Feedback #10: two tabs, navigable calendar periods, grouped list.
  int _tab = 0; // 0 = transactions, 1 = summary
  ActivityPeriod _period = ActivityPeriod.month;
  int _offset = 0; // 0 = current period, -1 = previous, …
  String _typeFilter = 'all'; // all | income | expense
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _pendingDelete = {}; // hidden while the Undo snackbar shows

  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _lang => Localizations.localeOf(context).languageCode == 'th' ? 'th' : 'en';

  String _fmtDate(String pattern, DateTime d) {
    try {
      return DateFormat(pattern, _lang).format(d);
    } catch (_) {
      return DateFormat(pattern).format(d);
    }
  }

  String _periodLabel(InsightRange r) {
    final l10n = AppLocalizations.of(context)!;
    switch (_period) {
      case ActivityPeriod.day:
        if (_offset == 0) return l10n.todayLabel;
        if (_offset == -1) return l10n.yesterdayLabel;
        return _fmtDate('d MMM y', r.start);
      case ActivityPeriod.week:
        return '${_fmtDate('d MMM', r.start)} – ${_fmtDate('d MMM y', r.lastDay)}';
      case ActivityPeriod.month:
        return _fmtDate('MMMM y', r.start);
      case ActivityPeriod.year:
        return _fmtDate('y', r.start);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final mutedTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cs = context.watch<CurrencyCubit>().state;
    final state = context.watch<TransactionBloc>().state;

    final all = state is TransactionLoaded
        ? state.transactions.where((t) => !_pendingDelete.contains(t.id)).toList()
        : <TransactionModel>[];
    final now = DateTime.now();
    final range = ActivityPeriods.range(_period, now, _offset);
    final prevRange = ActivityPeriods.range(_period, now, _offset - 1);
    final inPeriod = all.where((t) => range.contains(t.date)).toList();
    final inPrev = all.where((t) => prevRange.contains(t.date)).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            _buildHeader(context, textColor),
            const SizedBox(height: 16),
            _buildTabs(l10n, textColor, mutedTextColor, primaryColor),
            const SizedBox(height: 14),
            _buildPeriodSelector(l10n, mutedTextColor, primaryColor),
            const SizedBox(height: 8),
            _buildPeriodNavigator(range, textColor, mutedTextColor, l10n),
            const SizedBox(height: 10),
            _buildTotals(inPeriod, l10n, textColor, mutedTextColor, cs),
            const SizedBox(height: 20),
            if (state is TransactionLoading && all.isEmpty)
              const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
            else if (_tab == 0)
              ..._buildTransactionsTab(inPeriod, l10n, textColor, mutedTextColor, primaryColor, cs)
            else
              ..._buildSummaryTab(inPeriod, inPrev, l10n, textColor, mutedTextColor, cs),
          ],
        ),
      ),
    );
  }

  // ── Header / tabs / period ────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, Color? textColor) {
    return Row(
      children: [
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.activity,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textColor),
          ),
        ),
        IconButton.filledTonal(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage())),
        ),
      ],
    );
  }

  Widget _buildTabs(AppLocalizations l10n, Color? textColor, Color? muted, Color primary) {
    Widget tab(int i, IconData icon, String label) {
      final sel = _tab == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tab = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: sel ? primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: sel ? Colors.white : muted),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                      color: sel ? Colors.white : muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                    )),
              ],
            ),
          ),
        ),
      );
    }

    return GlassContainer(
      padding: const EdgeInsets.all(4),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          tab(0, Icons.receipt_long_outlined, l10n.transactions),
          tab(1, Icons.pie_chart_outline, l10n.summaryTab),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(AppLocalizations l10n, Color? muted, Color primary) {
    String label(ActivityPeriod p) => switch (p) {
          ActivityPeriod.day => l10n.day,
          ActivityPeriod.week => l10n.week,
          ActivityPeriod.month => l10n.month,
          ActivityPeriod.year => l10n.year,
        };
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<ActivityPeriod>(
        showSelectedIcon: false,
        segments: [
          for (final p in ActivityPeriod.values) ButtonSegment(value: p, label: Text(label(p))),
        ],
        selected: {_period},
        onSelectionChanged: (sel) => setState(() {
          _period = sel.first;
          _offset = 0;
        }),
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStateProperty.all(const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (st) => st.contains(WidgetState.selected) ? primary.withValues(alpha: 0.2) : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (st) => st.contains(WidgetState.selected) ? primary : muted,
          ),
          side: WidgetStateProperty.all(BorderSide(color: primary.withValues(alpha: 0.35))),
        ),
      ),
    );
  }

  Widget _buildPeriodNavigator(InsightRange range, Color? textColor, Color? muted, AppLocalizations l10n) {
    return Row(
      children: [
        IconButton(
          tooltip: l10n.previousPeriodTooltip,
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => setState(() => _offset--),
        ),
        Expanded(
          child: Text(
            _periodLabel(range),
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
        IconButton(
          tooltip: l10n.nextPeriodTooltip,
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: _offset < 0 ? () => setState(() => _offset++) : null,
        ),
      ],
    );
  }

  Widget _buildTotals(List<TransactionModel> txs, AppLocalizations l10n, Color? textColor, Color? muted, CurrencyState cs) {
    double inc = 0, exp = 0;
    for (final t in txs) {
      final type = t.type.toLowerCase();
      if (type == 'income') inc += t.amount.abs();
      if (type == 'expense') exp += t.amount.abs();
    }
    final net = inc - exp;
    String money(double v) => CurrencyFormatter.format(v, cs);

    Widget cell(String label, String value, Color color) => Expanded(
          child: Column(
            children: [
              Text(label, style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value, style: TextStyle(color: color, fontSize: 15.5, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        );

    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      borderRadius: BorderRadius.circular(18),
      child: Row(
        children: [
          cell(l10n.income, '+${money(inc)}', _green),
          cell(l10n.expense, '−${money(exp)}', _red),
          cell(l10n.netLabel, '${net >= 0 ? '+' : '−'}${money(net.abs())}', net >= 0 ? _green : _red),
        ],
      ),
    );
  }

  // ── Transactions tab ──────────────────────────────────────────────────────
  List<Widget> _buildTransactionsTab(List<TransactionModel> inPeriod, AppLocalizations l10n, Color? textColor,
      Color? muted, Color primary, CurrencyState cs) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final q = _searchQuery.trim().toLowerCase();
    final list = inPeriod.where((t) {
      final type = t.type.toLowerCase();
      if (_typeFilter != 'all' && type != _typeFilter) return false;
      if (q.isEmpty) return true;
      final cat = AppCategories.localizedLabel(t.category, _lang).toLowerCase();
      return t.note.toLowerCase().contains(q) || t.category.toLowerCase().contains(q) || cat.contains(q);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // group by calendar day
    final groups = <DateTime, List<TransactionModel>>{};
    for (final t in list) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      groups.putIfAbsent(d, () => []).add(t);
    }
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    String dayTitle(DateTime d) {
      final label = _fmtDate('EEE d MMM', d);
      if (d == today) return '${l10n.todayLabel} · $label';
      if (d == today.subtract(const Duration(days: 1))) return '${l10n.yesterdayLabel} · $label';
      return d.year == today.year ? label : _fmtDate('EEE d MMM y', d);
    }

    Widget filterChip(String key, String label) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(label),
            selected: _typeFilter == key,
            showCheckmark: false,
            onSelected: (_) => setState(() => _typeFilter = key),
            selectedColor: primary,
            labelStyle: TextStyle(color: _typeFilter == key ? Colors.white : muted, fontWeight: FontWeight.w700, fontSize: 13),
            side: BorderSide(color: _typeFilter == key ? primary : (muted ?? Colors.grey).withValues(alpha: 0.3)),
            shape: const StadiumBorder(),
          ),
        );

    return [
      TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: l10n.searchTransactions,
          hintStyle: TextStyle(color: muted),
          prefixIcon: Icon(Icons.search, color: muted),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.close, color: muted, size: 18),
                  onPressed: () => setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  }),
                ),
          filled: true,
          fillColor: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.04),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          filterChip('all', l10n.all),
          filterChip('income', l10n.income),
          filterChip('expense', l10n.expense),
        ],
      ),
      const SizedBox(height: 14),
      if (groups.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.receipt_long, color: muted?.withValues(alpha: 0.4), size: 44),
              const SizedBox(height: 12),
              Text(inPeriod.isEmpty ? l10n.noTransactionsInPeriod : l10n.noTransactionsMatch,
                  style: TextStyle(color: muted, fontSize: 14)),
            ],
          ),
        )
      else
        for (final entry in groups.entries) ...[
          _dayHeader(dayTitle(entry.key), entry.value, muted, cs),
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            borderRadius: BorderRadius.circular(18),
            child: Column(
              children: [
                for (int i = 0; i < entry.value.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: (textColor ?? Colors.grey).withValues(alpha: 0.07)),
                  _dismissibleRow(entry.value[i], l10n, textColor, muted, cs),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
    ];
  }

  Widget _dayHeader(String title, List<TransactionModel> txs, Color? muted, CurrencyState cs) {
    double net = 0;
    for (final t in txs) {
      final type = t.type.toLowerCase();
      if (type == 'income') net += t.amount.abs();
      if (type == 'expense') net -= t.amount.abs();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: TextStyle(color: muted, fontSize: 13, fontWeight: FontWeight.w700))),
          Text(
            '${net >= 0 ? '+' : '−'}${CurrencyFormatter.format(net.abs(), cs)}',
            style: TextStyle(color: net >= 0 ? _green : _red, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _dismissibleRow(TransactionModel t, AppLocalizations l10n, Color? textColor, Color? muted, CurrencyState cs) {
    return Dismissible(
      key: ValueKey('tx_${t.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: _red,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => _deleteWithUndo(t, l10n),
      child: InkWell(
        onTap: () => _showTransactionOptions(context, t),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: TransactionRow(transaction: t, currencyState: cs, textColor: textColor, mutedTextColor: muted),
        ),
      ),
    );
  }

  void _deleteWithUndo(TransactionModel t, AppLocalizations l10n) {
    final bloc = context.read<TransactionBloc>();
    setState(() => _pendingDelete.add(t.id));
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger
        .showSnackBar(SnackBar(
          content: Text(l10n.transactionDeleted),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(label: l10n.undoAction, onPressed: () {}),
        ))
        .closed
        .then((reason) {
      if (reason == SnackBarClosedReason.action) {
        if (mounted) setState(() => _pendingDelete.remove(t.id));
        return;
      }
      if (!bloc.isClosed) bloc.add(DeleteTransaction(t.id));
    });
  }

  // ── Summary tab ───────────────────────────────────────────────────────────
  List<Widget> _buildSummaryTab(List<TransactionModel> inPeriod, List<TransactionModel> inPrev, AppLocalizations l10n,
      Color? textColor, Color? muted, CurrencyState cs) {
    if (inPeriod.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(child: Text(l10n.noTransactionsInPeriod, style: TextStyle(color: muted, fontSize: 14))),
        ),
      ];
    }
    final range = ActivityPeriods.range(_period, DateTime.now(), _offset);
    return [
      if (_period != ActivityPeriod.day) ...[
        _buildTrendBars(inPeriod, range, l10n, textColor, muted, cs),
        const SizedBox(height: 16),
      ],
      _buildSpendingDonut(inPeriod, l10n, textColor, muted, cs),
      const SizedBox(height: 16),
      _buildComparison(inPeriod, inPrev, l10n, textColor, muted, cs),
      const SizedBox(height: 16),
      _buildCashFlowStatement(inPeriod, textColor, muted, cs),
    ];
  }

  /// Income vs expense per sub-period (days of a week, 7-day blocks of a
  /// month, months of a year). Tap a bar to see its amount.
  Widget _buildTrendBars(List<TransactionModel> txs, InsightRange range, AppLocalizations l10n,
      Color? textColor, Color? muted, CurrencyState cs) {
    final buckets = ActivityPeriods.buckets(_period, range);
    final inc = List<double>.filled(buckets.length, 0);
    final exp = List<double>.filled(buckets.length, 0);
    for (final t in txs) {
      final i = buckets.indexWhere((b) => b.contains(t.date));
      if (i < 0) continue;
      final type = t.type.toLowerCase();
      if (type == 'income') inc[i] += t.amount.abs();
      if (type == 'expense') exp[i] += t.amount.abs();
    }
    double maxY = 0;
    for (int i = 0; i < buckets.length; i++) {
      if (inc[i] > maxY) maxY = inc[i];
      if (exp[i] > maxY) maxY = exp[i];
    }
    if (maxY == 0) maxY = 1;

    String label(int i) {
      final b = buckets[i];
      switch (_period) {
        case ActivityPeriod.week:
          return _fmtDate('E', b.start);
        case ActivityPeriod.month:
          return b.start.day == b.lastDay.day ? '${b.start.day}' : '${b.start.day}-${b.lastDay.day}';
        case ActivityPeriod.year:
          return _fmtDate('MMM', b.start);
        case ActivityPeriod.day:
          return '';
      }
    }

    final barWidth = _period == ActivityPeriod.year ? 7.0 : 11.0;
    Widget legend(Color c, String t) => Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 6),
          Text(t, style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w600)),
        ]);

    return GlassContainer(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      borderRadius: BorderRadius.circular(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(l10n.trendTitle, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textColor)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Wrap(spacing: 14, children: [legend(_green, l10n.income), legend(_red, l10n.expense)]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.15,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY * 1.15 / 4,
                  getDrawingHorizontalLine: (_) => FlLine(color: (textColor ?? Colors.grey).withValues(alpha: 0.07), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= buckets.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(label(i), style: TextStyle(color: muted, fontSize: 10.5, fontWeight: FontWeight.w600)),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF1E293B),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                      '${label(group.x)}\n${rodIndex == 0 ? '+' : '\u2212'}${CurrencyFormatter.format(rod.toY, cs, decimals: 0)}',
                      TextStyle(color: rodIndex == 0 ? _green : _red, fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                ),
                barGroups: [
                  for (int i = 0; i < buckets.length; i++)
                    BarChartGroupData(
                      x: i,
                      barsSpace: 3,
                      barRods: [
                        BarChartRodData(
                          toY: inc[i],
                          color: _green,
                          width: barWidth,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                        BarChartRodData(
                          toY: exp[i],
                          color: _red,
                          width: barWidth,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingDonut(List<TransactionModel> txs, AppLocalizations l10n, Color? textColor, Color? muted, CurrencyState cs) {
    final byCat = <String, double>{};
    double total = 0;
    for (final t in txs) {
      if (t.type.toLowerCase() != 'expense') continue;
      byCat[t.category] = (byCat[t.category] ?? 0) + t.amount.abs();
      total += t.amount.abs();
    }
    const palette = [
      Color(0xFF6366F1), Color(0xFFF59E0B), Color(0xFFEC4899), Color(0xFF06B6D4),
      Color(0xFF10B981), Color(0xFF8B5CF6), Color(0xFF94A3B8),
    ];
    final sorted = byCat.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    // top 6 + others
    final shown = sorted.take(6).toList();
    final others = sorted.skip(6).fold<double>(0, (s, e) => s + e.value);
    final items = <MapEntry<String, double>>[...shown, if (others > 0) MapEntry(l10n.othersLabel, others)];

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.spendingBreakdown, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textColor)),
          const SizedBox(height: 12),
          if (total == 0)
            Text(l10n.noSpendingThisMonth, style: TextStyle(color: muted))
          else ...[
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 58,
                    sections: [
                      for (int i = 0; i < items.length; i++)
                        PieChartSectionData(
                          color: palette[i % palette.length],
                          value: items[i].value,
                          title: '',
                          radius: 26,
                        ),
                    ],
                  )),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.expense, style: TextStyle(color: muted, fontSize: 12)),
                      Text(CurrencyFormatter.format(total, cs, decimals: 0),
                          style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < items.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: palette[i % palette.length], shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(AppCategories.localizedLabel(items[i].key, _lang),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    Text('${(items[i].value / total * 100).toStringAsFixed(0)}%',
                        style: TextStyle(color: muted, fontSize: 12.5, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 96,
                      child: Text(CurrencyFormatter.format(items[i].value, cs, decimals: 0),
                          textAlign: TextAlign.right,
                          style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildComparison(List<TransactionModel> cur, List<TransactionModel> prev, AppLocalizations l10n,
      Color? textColor, Color? muted, CurrencyState cs) {
    double sum(List<TransactionModel> l, String type) =>
        l.where((t) => t.type.toLowerCase() == type).fold(0.0, (s, t) => s + t.amount.abs());
    final curInc = sum(cur, 'income'), curExp = sum(cur, 'expense');
    final prevInc = sum(prev, 'income'), prevExp = sum(prev, 'expense');

    Widget line(String label, double now, double before, {required bool higherIsGood}) {
      String change;
      Color color;
      if (before <= 0) {
        change = '—';
        color = muted ?? Colors.grey;
      } else {
        final pct = (now - before) / before * 100;
        final up = pct >= 0;
        change = '${up ? '▲' : '▼'} ${pct.abs().toStringAsFixed(0)}%';
        final good = up == higherIsGood;
        color = pct.abs() < 0.5 ? (muted ?? Colors.grey) : (good ? _green : _red);
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(label, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600))),
            Text(CurrencyFormatter.format(before, cs, decimals: 0), style: TextStyle(color: muted, fontSize: 12.5)),
            Icon(Icons.arrow_right_alt, color: muted, size: 18),
            Text(CurrencyFormatter.format(now, cs, decimals: 0),
                style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(width: 10),
            SizedBox(
              width: 58,
              child: Text(change, textAlign: TextAlign.right, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      );
    }

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.vsPreviousPeriod, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textColor)),
          const SizedBox(height: 8),
          line(l10n.income, curInc, prevInc, higherIsGood: true),
          line(l10n.expense, curExp, prevExp, higherIsGood: false),
        ],
      ),
    );
  }

  Widget _buildCashFlowStatement(List<TransactionModel> transactions, Color? textColor, Color? mutedTextColor, CurrencyState currencyState) {
    final l10n = AppLocalizations.of(context)!;
    // Build label → group lookup
    final Map<String, String> labelToGroup = {};
    for (final c in AppCategories.income) {
      labelToGroup[c.label] = c.group;
    }
    for (final c in AppCategories.expense) {
      labelToGroup[c.label] = c.group;
    }

    // Accumulate totals per group
    final Map<String, double> groupTotals = {};
    final Map<String, List<TransactionModel>> groupTx = {};
    for (final t in transactions) {
      final group = labelToGroup[t.category];
      if (group != null) {
        groupTotals[group] = (groupTotals[group] ?? 0) + t.amount.abs();
        groupTx.putIfAbsent(group, () => []).add(t);
      }
    }

    final double activeIncome   = groupTotals['Active Income']  ?? 0;
    final double passiveIncome  = groupTotals['Passive Income'] ?? 0;
    final double totalInflow    = activeIncome + passiveIncome;

    final double saving         = groupTotals['Saving']      ?? 0;
    final double fixed          = groupTotals['Fixed']       ?? 0;
    final double installment    = groupTotals['Installment'] ?? 0;
    final double variable       = groupTotals['Variable']    ?? 0;
    final double totalOutflow   = saving + fixed + installment + variable;

    final double netCashFlow    = totalInflow - totalOutflow;
    final bool   isPositive     = netCashFlow >= 0;

    String fmt(double v) => CurrencyFormatter.format(v, currencyState, decimals: 0);

    Widget statRow(String label, double amount, {bool isBold = false, Color? color}) {
      final c = color ?? textColor;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isBold ? 14 : 13,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                  color: c,
                ),
              ),
            ),
            Text(
              fmt(amount),
              style: TextStyle(
                fontSize: isBold ? 14 : 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: c,
              ),
            ),
          ],
        ),
      );
    }

    Widget expandableRow(String label, double total, String groupKey, Color accentColor) {
      final txList = groupTx[groupKey] ?? [];
      if (txList.isEmpty) return statRow(label, total);
      return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(left: 8, bottom: 4),
          iconColor: accentColor,
          collapsedIconColor: (textColor ?? Colors.grey).withValues(alpha: 0.4),
          title: Row(
            children: [
              Expanded(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor))),
              Text(fmt(total), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor)),
            ],
          ),
          children: txList.map((t) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Icon(_getCategoryIcon(t.category), size: 14, color: accentColor.withValues(alpha: 0.7)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    t.note.isNotEmpty ? t.note : t.category,
                    style: TextStyle(fontSize: 12, color: mutedTextColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(fmt(t.amount.abs()), style: TextStyle(fontSize: 12, color: mutedTextColor)),
              ],
            ),
          )).toList(),
        ),
      );
    }

    Widget sectionHeader(String title, Color color) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Row(
          children: [
            Container(
              width: 3, height: 16,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.8),
            ),
          ],
        ),
      );
    }

    Widget divider() => Divider(color: (textColor ?? Colors.grey).withValues(alpha: 0.15), height: 16);

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: textColor, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.cashFlowStatement,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Cash Inflows ──────────────────────────────────────
          sectionHeader(l10n.cashInflows, Colors.green),
          expandableRow(l10n.cfActiveIncome,  activeIncome,  'Active Income',  Colors.green),
          expandableRow(l10n.cfPassiveIncome, passiveIncome, 'Passive Income', Colors.green),
          divider(),
          statRow(l10n.totalInflows, totalInflow, isBold: true, color: Colors.green),
          const SizedBox(height: 16),

          // ── Cash Outflows ─────────────────────────────────────
          sectionHeader(l10n.cashOutflows, Colors.redAccent),
          expandableRow(l10n.cfSaving,      saving,      'Saving',      Colors.redAccent),
          expandableRow(l10n.cfFixed,       fixed,        'Fixed',       Colors.redAccent),
          expandableRow(l10n.cfInstallment,  installment,  'Installment', Colors.redAccent),
          expandableRow(l10n.cfVariable,    variable,     'Variable',    Colors.redAccent),
          divider(),
          statRow(l10n.totalOutflows, totalOutflow, isBold: true, color: Colors.redAccent),
          const SizedBox(height: 16),

          // ── Net Cash Flow ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: (isPositive ? Colors.green : Colors.redAccent).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: (isPositive ? Colors.green : Colors.redAccent).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? Colors.green : Colors.redAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.netCashFlow,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isPositive ? Colors.green : Colors.redAccent,
                    ),
                  ),
                ),
                Text(
                  (isPositive && netCashFlow > 0 ? '+' : '') + fmt(netCashFlow),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isPositive ? Colors.green : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionOptions(BuildContext context, TransactionModel record) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final isIncome = record.type.toLowerCase() == 'income';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isIncome ? Colors.green : Colors.redAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  record.note.isNotEmpty ? record.note : record.category,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor),
                ),
              ],
            ),
            Text(
              record.category,
              style: TextStyle(fontSize: 13, color: textColor?.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 24),
            // Edit
            _transactionOptionTile(
              color: Theme.of(context).colorScheme.primary,
              icon: Icons.edit_outlined,
              title: AppLocalizations.of(context)!.editAction,
              subtitle: AppLocalizations.of(context)!.editTransactionSubtitle,
              onTap: () {
                Navigator.pop(ctx);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddTransactionSheet(existingTransaction: record),
                );
              },
            ),
            const SizedBox(height: 10),
            // Delete
            _transactionOptionTile(
              color: Colors.redAccent,
              icon: Icons.delete_outline,
              title: AppLocalizations.of(context)!.deleteAction,
              subtitle: AppLocalizations.of(context)!.deleteTransactionSubtitle,
              onTap: () {
                context.read<TransactionBloc>().add(DeleteTransaction(record.id));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _transactionOptionTile({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(subtitle, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  IconData _getCategoryIcon(String category) => transactionCategoryIcon(category);
}
