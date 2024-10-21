part of 'weighing_cubit.dart';

enum WeighingStatus { weighing, scaleWeighing }

@immutable
class WeighingState extends Equatable {
  final String plant;
  final String materialCode;
  final String date;
  final WeighingStatus tab;

  const WeighingState(
      {this.plant = "",
      this.materialCode = "",
      this.date = "",
      this.tab = WeighingStatus.weighing});

  WeighingState copyWith(
      {String? plant,
      String? materialCode,
      String? date,
      WeighingStatus? tab}) {
    return WeighingState(
        plant: plant ?? this.plant,
        materialCode: materialCode ?? this.materialCode,
        date: date ?? this.date,
        tab: tab ?? this.tab);
  }

  @override
  List<Object> get props => [plant, materialCode, date, tab];
}
