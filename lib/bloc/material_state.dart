part of 'material_bloc.dart';

@immutable
abstract class MaterialsState extends Equatable {
  const MaterialsState();
  @override
  List<Object> get props => [];
}

final class MaterialsInitial extends MaterialsState {}

final class MaterialsLoading extends MaterialsState {}

final class MaterialsLoaded extends MaterialsState {
  final MaterialResponse material;
  const MaterialsLoaded(this.material);
  @override
  List<Object> get props => [material];
}

final class MaterialsError extends MaterialsState {
  final String error;

  const MaterialsError(this.error);

  @override
  List<Object> get props => [error];
}
