part of 'flag_materials_bloc.dart';

@immutable
abstract class FlagMaterialsEvent extends Equatable {
  const FlagMaterialsEvent();

  @override
  List<Object?> get props => [];
}

class GetFlagMaterials extends FlagMaterialsEvent {
  final List<dynamic> flagMaterials;
  final String orderNo;
  final String qrValue;

  const GetFlagMaterials(this.flagMaterials, this.orderNo, this.qrValue);
}
