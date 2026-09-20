import 'package:equatable/equatable.dart';
import 'package:fincontrol/features/wealth/data/models/asset_model.dart';

abstract class AssetState extends Equatable {
  const AssetState();
  
  @override
  List<Object> get props => [];
}

class AssetInitial extends AssetState {}

class AssetLoading extends AssetState {}

class AssetLoaded extends AssetState {
  final List<AssetModel> assets;
  
  const AssetLoaded(this.assets);
  
  @override
  List<Object> get props => [assets];
}

class AssetError extends AssetState {
  final String message;
  
  const AssetError(this.message);
  
  @override
  List<Object> get props => [message];
}
