class AssetModel {
  final String id;
  final String userId;
  final String portfolioId;
  final String name;
  final String tickerSymbol;
  final String category;
  final double totalQuantity;
  final double averageBuyPrice;
  final double currentPrice;

  const AssetModel({
    required this.id,
    required this.userId,
    required this.portfolioId,
    required this.name,
    required this.tickerSymbol,
    required this.category,
    required this.totalQuantity,
    required this.averageBuyPrice,
    required this.currentPrice,
  });

  AssetModel copyWith({
    String? id,
    String? userId,
    String? portfolioId,
    String? name,
    String? tickerSymbol,
    String? category,
    double? totalQuantity,
    double? averageBuyPrice,
    double? currentPrice,
  }) {
    return AssetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      portfolioId: portfolioId ?? this.portfolioId,
      name: name ?? this.name,
      tickerSymbol: tickerSymbol ?? this.tickerSymbol,
      category: category ?? this.category,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      averageBuyPrice: averageBuyPrice ?? this.averageBuyPrice,
      currentPrice: currentPrice ?? this.currentPrice,
    );
  }

  factory AssetModel.fromMap(Map<String, dynamic> map, String id) {
    return AssetModel(
      id: id,
      userId: map['user_id'] as String? ?? '',
      portfolioId: map['portfolio_id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      tickerSymbol: map['ticker_symbol'] as String? ?? '',
      category: map['category'] as String? ?? '',
      totalQuantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      averageBuyPrice: (map['average_buy_price'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (map['current_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'portfolio_id': portfolioId,
      'name': name,
      'ticker_symbol': tickerSymbol,
      'category': category,
      'quantity': totalQuantity,
      'average_buy_price': averageBuyPrice,
      'current_price': currentPrice,
    };
  }
}
