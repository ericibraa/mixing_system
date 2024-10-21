part of 'material_bloc.dart';

@immutable
abstract class MaterialsEvent extends Equatable {
  const MaterialsEvent();

  @override
  List<Object> get props => [];
}

class SendPlant extends MaterialsEvent {
  final String plant;
  final String search;

  const SendPlant({required this.plant, this.search = ''});
  @override
  List<Object> get props => [plant, search];
}
