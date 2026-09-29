// "+" menu (Feedback #11): vertical list ordered by how often each action is
// used — expense, income, invest, new goal — with one-line descriptions and
// the app-wide colours (red = expense, green = income, blue = invest).
// Manual asset entry is a small link for things not in the market list.

import 'package:flutter/material.dart';
import 'package:fincontrol/features/transaction/presentation/widgets/add_transaction_sheet.dart';
import 'package:fincontrol/features/wealth/presentation/widgets/add_entry_sheet.dart';
import 'package:fincontrol/features/wealth/presentation/pages/create_new_portfolio.dart';
import 'package:fincontrol/features/wealth/presentation/pages/invest_page.dart';
import 'package:fincontrol/l10n/app_localizations.dart';

class CreateActionMenu extends StatelessWidget {
  const CreateActionMenu({super.key});

  static const _red = Color(0xFFEF4444);
  static const _green = Color(0xFF10B981);
  static const _orange = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E2A) : Colors.white;
    final textColor = theme.textTheme.bodyLarge?.color;
    final muted = theme.textTheme.bodySmall?.color;
    final primary = theme.colorScheme.primary;

    // The menu is closed first, then the next screen opens from the page below.
    void openSheet(Widget sheet) {
      final nav = Navigator.of(context);
      nav.pop();
      showModalBottomSheet(
        context: nav.context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => sheet,
      );
    }

    void openPage(Widget page) {
      final nav = Navigator.of(context);
      nav.pop();
      nav.push(MaterialPageRoute(builder: (_) => page));
    }

    Widget item({
      required IconData icon,
      required Color color,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: color.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(color: textColor, fontSize: 16.5, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text(subtitle, style: TextStyle(color: muted, fontSize: 12.5)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: muted),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.whatWouldYouLikeToAdd,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: textColor),
            ),
            const SizedBox(height: 18),
            item(
              icon: Icons.remove_rounded,
              color: _red,
              title: l10n.expenses,
              subtitle: l10n.expenseSubtitle,
              onTap: () => openSheet(const AddTransactionSheet(initialType: TransactionType.expense)),
            ),
            item(
              icon: Icons.add_rounded,
              color: _green,
              title: l10n.income,
              subtitle: l10n.incomeSubtitle,
              onTap: () => openSheet(const AddTransactionSheet(initialType: TransactionType.income)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Divider(height: 1, color: (textColor ?? Colors.grey).withValues(alpha: 0.1)),
            ),
            item(
              icon: Icons.trending_up_rounded,
              color: primary,
              title: l10n.invest,
              subtitle: l10n.investSubtitle,
              onTap: () => openPage(const InvestPage()),
            ),
            item(
              icon: Icons.flag_rounded,
              color: _orange,
              title: l10n.newGoal,
              subtitle: l10n.newGoalSubtitle,
              onTap: () => openPage(const CreatePortfolioPage()),
            ),
            TextButton.icon(
              onPressed: () => openSheet(const AddEntrySheet()),
              icon: Icon(Icons.edit_note_rounded, color: muted, size: 20),
              label: Text(l10n.addAssetManually, style: TextStyle(color: muted, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
