part of 'material_set_bloc.dart';

@immutable
abstract class MaterialSetState extends Equatable {
  const MaterialSetState();
  @override
  List<Object> get props => [];
}

final class MaterialSetInitial extends MaterialSetState {}

final class MaterialSetLoading extends MaterialSetState {}

final class MaterialSetLoaded extends MaterialSetState {
  final ResponseMaterialset materialset;
  const MaterialSetLoaded(this.materialset);
  @override
  List<Object> get props => [materialset];
}

final class MaterialSetError extends MaterialSetState {}
