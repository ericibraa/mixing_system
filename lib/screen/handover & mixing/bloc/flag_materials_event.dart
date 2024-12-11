part of 'flag_materials_bloc.dart';

@immutable
abstract class FlagMaterialsEvent extends Equatable {
  const FlagMaterialsEvent();

  @override
  List<Object?> get props => [];
}

class GetFlagMaterials extends FlagMaterialsEvent {
  final List<dynamic> flagMaterials;

  const GetFlagMaterials(this.flagMaterials);
}
