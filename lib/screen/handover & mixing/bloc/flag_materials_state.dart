part of 'flag_materials_bloc.dart';

@immutable
abstract class FlagMaterialsState extends Equatable {
  const FlagMaterialsState();

  @override
  List<Object> get props => [];
}

final class FlagMaterialsInitial extends FlagMaterialsState {}

final class FlagMaterialsLoading extends FlagMaterialsState {}

final class FlagMaterialsSuccess extends FlagMaterialsState {
  final String flagMaterials;

  const FlagMaterialsSuccess(this.flagMaterials);
  @override
  List<Object> get props => [flagMaterials];
}

final class FlagMaterialsError extends FlagMaterialsState {
  final String error;
  const FlagMaterialsError(this.error);

  @override
  List<Object> get props => [error];
}
