import 'package:fincontrol/features/transaction/presentation/widgets/add_transaction_sheet.dart';
import 'package:fincontrol/features/wealth/presentation/widgets/add_entry_sheet.dart';
import 'package:fincontrol/features/wealth/presentation/pages/create_new_portfolio.dart';
import 'package:fincontrol/features/wealth/presentation/pages/invest_page.dart';
import 'package:flutter/material.dart';
import 'package:fincontrol/l10n/app_localizations.dart';

class CreateActionMenu extends StatelessWidget {
  const CreateActionMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Solid background matching the premium UI
    final backgroundColor = isDarkMode ? const Color(0xFF272732) : Colors.white;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.whatWouldYouLikeToAdd,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 400;
                
                final items = [
                  _buildGridItem(
                    context,
                    icon: Icons.receipt_long,
                    title: AppLocalizations.of(context)!.transaction,
                    color: Colors.green,
                    textColor: textColor,
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const AddTransactionSheet(),
                      );
                    },
                  ),
                  _buildGridItem(
                    context,
                    icon: Icons.account_balance_wallet,
                    title: AppLocalizations.of(context)!.asset,
                    color: Colors.blue,
                    textColor: textColor,
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const AddEntrySheet(),
                      );
                    },
                  ),
                  _buildGridItem(
                    context,
                    icon: Icons.flag,
                    title: AppLocalizations.of(context)!.goal,
                    color: Colors.orange,
                    textColor: textColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePortfolioPage()));
                    },
                  ),
                  _buildGridItem(
                    context,
                    icon: Icons.trending_up,
                    title: AppLocalizations.of(context)!.invest,
                    color: primaryColor,
                    textColor: textColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const InvestPage()));
                    },
                  ),
                ];

                if (isWide) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: items.map((item) => Expanded(child: item)).toList(),
                  );
                } else {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: items[0]),
                          Expanded(child: items[1]),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: items[2]),
                          Expanded(child: items[3]),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required Color? textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
