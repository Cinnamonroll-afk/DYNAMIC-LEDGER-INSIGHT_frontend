import 'package:fincontrol/l10n/app_localizations.dart';
import 'package:fincontrol/features/wealth/presentation/pages/asset_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:fincontrol/features/wealth/data/models/asset_model.dart';
import 'package:fincontrol/features/wealth/data/repositories/market_api_repository.dart';
import 'package:fincontrol/core/widgets/glass_container.dart';

class InvestPage extends StatefulWidget {
  final String? portfolioId;
  const InvestPage({super.key, this.portfolioId});

  @override
  State<InvestPage> createState() => _InvestPageState();
}

class _InvestPageState extends State<InvestPage> {
  final MarketApiRepository _api = MarketApiRepository();
  String _selectedCategory = '';
  String _selectedSort = 'Default';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _mockAssets = [
    // Stocks
    {'name': 'Apple Inc.', 'ticker': 'AAPL', 'price': 189.30, 'change': 1.25, 'category': 'Stocks'},
    {'name': 'Microsoft Corp.', 'ticker': 'MSFT', 'price': 378.85, 'change': 0.75, 'category': 'Stocks'},
    {'name': 'Alphabet Inc.', 'ticker': 'GOOGL', 'price': 142.65, 'change': -0.45, 'category': 'Stocks'},
    {'name': 'Amazon.com', 'ticker': 'AMZN', 'price': 145.20, 'change': 0.89, 'category': 'Stocks'},
    {'name': 'NVIDIA Corp.', 'ticker': 'NVDA', 'price': 481.11, 'change': 2.30, 'category': 'Stocks'},
    {'name': 'Meta Platforms', 'ticker': 'META', 'price': 334.92, 'change': 1.10, 'category': 'Stocks'},
    {'name': 'Tesla Inc.', 'ticker': 'TSLA', 'price': 248.50, 'change': -2.34, 'category': 'Stocks'},
    
    // Crypto
    {'name': 'Bitcoin', 'ticker': 'BTC-USD', 'price': 42150.00, 'change': 5.67, 'category': 'Crypto'},
    {'name': 'Ethereum', 'ticker': 'ETH-USD', 'price': 2250.40, 'change': 3.12, 'category': 'Crypto'},
    {'name': 'Solana', 'ticker': 'SOL-USD', 'price': 72.30, 'change': 8.45, 'category': 'Crypto'},
    {'name': 'Binance Coin', 'ticker': 'BNB-USD', 'price': 245.80, 'change': 1.20, 'category': 'Crypto'},
    {'name': 'Ripple', 'ticker': 'XRP-USD', 'price': 0.62, 'change': -1.40, 'category': 'Crypto'},
    {'name': 'Cardano', 'ticker': 'ADA-USD', 'price': 0.45, 'change': 2.10, 'category': 'Crypto'},
    {'name': 'Dogecoin', 'ticker': 'DOGE-USD', 'price': 0.09, 'change': 4.50, 'category': 'Crypto'},

    // ETFs
    {'name': 'Vanguard S&P 500 ETF', 'ticker': 'VOO', 'price': 410.80, 'change': 0.45, 'category': 'ETFs'},
    {'name': 'Invesco QQQ Trust', 'ticker': 'QQQ', 'price': 390.25, 'change': 0.85, 'category': 'ETFs'},
    {'name': 'SPDR S&P 500 ETF', 'ticker': 'SPY', 'price': 447.18, 'change': 0.42, 'category': 'ETFs'},
    {'name': 'iShares Core S&P 500', 'ticker': 'IVV', 'price': 449.30, 'change': 0.44, 'category': 'ETFs'},
    {'name': 'Vanguard Total Stock', 'ticker': 'VTI', 'price': 225.10, 'change': 0.51, 'category': 'ETFs'},
    {'name': 'SPDR Dow Jones', 'ticker': 'DIA', 'price': 362.40, 'change': 0.20, 'category': 'ETFs'},
    {'name': 'ARK Innovation ETF', 'ticker': 'ARKK', 'price': 48.90, 'change': -1.25, 'category': 'ETFs'},

    // Mutual Funds
    {'name': 'Vanguard 500 Index Fund', 'ticker': 'VFIAX', 'price': 485.20, 'change': 0.50, 'category': 'Mutual Funds'},
    {'name': 'Fidelity Contrafund', 'ticker': 'FCNTX', 'price': 15.34, 'change': -0.12, 'category': 'Mutual Funds'},
    {'name': 'Fidelity 500 Index', 'ticker': 'FXAIX', 'price': 168.45, 'change': 0.48, 'category': 'Mutual Funds'},
    {'name': 'Schwab S&P 500', 'ticker': 'SWPPX', 'price': 72.15, 'change': 0.49, 'category': 'Mutual Funds'},
    {'name': 'Vanguard Total Stock', 'ticker': 'VTSAX', 'price': 112.30, 'change': 0.52, 'category': 'Mutual Funds'},
    {'name': 'Vanguard Wellington', 'ticker': 'VWENX', 'price': 74.20, 'change': 0.15, 'category': 'Mutual Funds'},
    {'name': 'T. Rowe Price Capital', 'ticker': 'PRWCX', 'price': 34.90, 'change': 0.22, 'category': 'Mutual Funds'},

    // Thai Stocks
    {'name': 'PTT Public Company', 'ticker': 'PTT.BK', 'price': 35.50, 'change': 0.25, 'category': 'Thai Stocks'},
    {'name': 'Airports of Thailand', 'ticker': 'AOT.BK', 'price': 65.25, 'change': -0.50, 'category': 'Thai Stocks'},
    {'name': 'Advanced Info Service', 'ticker': 'ADVANC.BK', 'price': 210.00, 'change': 1.10, 'category': 'Thai Stocks'},
    {'name': 'SCB X Public Company', 'ticker': 'SCB.BK', 'price': 105.50, 'change': 0.45, 'category': 'Thai Stocks'},
    {'name': 'CP All Public Company', 'ticker': 'CPALL.BK', 'price': 58.75, 'change': 0.80, 'category': 'Thai Stocks'},
    {'name': 'Bangkok Dusit Medical', 'ticker': 'BDMS.BK', 'price': 27.50, 'change': 0.30, 'category': 'Thai Stocks'},
    {'name': 'Kasikornbank', 'ticker': 'KBANK.BK', 'price': 130.50, 'change': -0.20, 'category': 'Thai Stocks'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchRealPrices();
  }

  void _fetchRealPrices() async {
    for (var i = 0; i < _mockAssets.length; i++) {
      final ticker = _mockAssets[i]['ticker'] as String;
      final data = await _api.getChartData(ticker, interval: '1d', range: '5d');
      if (data.isNotEmpty && data.length >= 2 && mounted) {
        final currentPrice = data.last;
        final previousClose = data[data.length - 2];
        final change = previousClose > 0 ? ((currentPrice - previousClose) / previousClose) * 100 : 0.0;
        
        setState(() {
          _mockAssets[i]['price'] = currentPrice;
          _mockAssets[i]['change'] = double.parse(change.toStringAsFixed(2));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            AppLocalizations.of(context)!.invest,
            style: TextStyle(
              color: textColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(color: textColor),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GlassContainer(
                      height: 50,
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(16),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: TextStyle(color: textColor, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.searchAssets,
                          hintStyle: TextStyle(color: mutedTextColor),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search, color: mutedTextColor),
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _showSortSheet(textColor, primaryColor),
                  child: GlassContainer(
                    width: 50,
                    height: 50,
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(16),
                    child: Icon(Icons.tune, color: textColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryButton('Stocks', 'Stocks', primaryColor, textColor, mutedTextColor),
                  const SizedBox(width: 12),
                  _buildCategoryButton('Crypto', 'Crypto', primaryColor, textColor, mutedTextColor),
                  const SizedBox(width: 12),
                  _buildCategoryButton('ETFs', 'ETFs', primaryColor, textColor, mutedTextColor),
                  const SizedBox(width: 12),
                  _buildCategoryButton('Mutual Funds', 'Mutual Funds', primaryColor, textColor, mutedTextColor),
                  const SizedBox(width: 12),
                  _buildCategoryButton('Thai Stocks', 'Thai Stocks', primaryColor, textColor, mutedTextColor),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.spotlight,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                List<Map<String, dynamic>> filteredAssets = _selectedCategory.isEmpty 
                    ? List<Map<String, dynamic>>.from(_mockAssets) 
                    : _mockAssets.where((a) => a['category'] == _selectedCategory).toList();
                
                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  filteredAssets = filteredAssets.where((a) => 
                    (a['name'] as String).toLowerCase().contains(query) ||
                    (a['ticker'] as String).toLowerCase().contains(query)
                  ).toList();
                }
                
                if (_selectedSort == 'Top Gainers') {
                  filteredAssets.sort((a, b) => (b['change'] as double).compareTo(a['change'] as double));
                } else if (_selectedSort == 'Top Losers') {
                  filteredAssets.sort((a, b) => (a['change'] as double).compareTo(b['change'] as double));
                } else if (_selectedSort == 'A-Z') {
                  filteredAssets.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
                }
                
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredAssets.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final asset = filteredAssets[index];
                    final isPositive = (asset['change'] as double) >= 0;
                    return GestureDetector(
                      onTap: () async {
                        final assetModel = AssetModel(
                          id: 'mock_$index',
                          userId: 'mock_user',
                          portfolioId: 'mock_portfolio',
                          name: asset['name'] as String,
                          tickerSymbol: asset['ticker'] as String,
                          category: asset['category'] as String,
                          totalQuantity: 0,
                          averageBuyPrice: (asset['price'] as double) - (asset['change'] as double),
                          currentPrice: asset['price'] as double,
                        );
                        final saved = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AssetDetailPage(asset: assetModel, portfolioId: widget.portfolioId),
                          ),
                        );
                        if (saved == true && context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        borderRadius: BorderRadius.circular(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                'assets/icons/${asset['ticker']}.png',
                                width: 24,
                                height: 24,
                                errorBuilder: (context, error, stackTrace) {
                                  final String ticker = asset['ticker'] as String;
                                  return Center(
                                    child: Text(
                                      ticker.isNotEmpty ? ticker.substring(0, 1) : '?',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    asset['ticker'] as String,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    asset['name'] as String,
                                    style: TextStyle(color: mutedTextColor, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${(asset['price'] as double).toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${isPositive ? '+' : ''}${asset['change']}%',
                                  style: TextStyle(
                                    color: isPositive ? Colors.greenAccent.shade400 : Colors.redAccent.shade400,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showSortSheet(Color? textColor, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return GlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, 
                  height: 4, 
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3), 
                    borderRadius: BorderRadius.circular(2)
                  )
                ),
              ),
              const SizedBox(height: 24),
              Text(AppLocalizations.of(context)!.sortBy, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 16),
              _buildSortOption(AppLocalizations.of(context)!.defaultSort, textColor, primaryColor),
              _buildSortOption('Top Gainers', textColor, primaryColor),
              _buildSortOption('Top Losers', textColor, primaryColor),
              _buildSortOption('A-Z', textColor, primaryColor),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String title, Color? textColor, Color primaryColor) {
    final isSelected = _selectedSort == title;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title, 
        style: TextStyle(
          color: isSelected ? primaryColor : textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 16,
        )
      ),
      trailing: isSelected ? Icon(Icons.check, color: primaryColor) : null,
      onTap: () {
        setState(() {
          _selectedSort = title;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildCategoryButton(String title, String localizedTitle, Color primaryColor, Color? textColor, Color? mutedTextColor) {
    final isSelected = _selectedCategory == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedCategory == title) {
            _selectedCategory = '';
          } else {
            _selectedCategory = title;
          }
        });
      },
      child: GlassContainer(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        borderRadius: BorderRadius.circular(22),
        color: isSelected ? primaryColor.withValues(alpha: 0.3) : null,
        child: Center(
          child: Text(
            title, 
            style: TextStyle(
              color: isSelected ? primaryColor : mutedTextColor, 
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}



