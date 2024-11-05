part of 'label_bloc.dart';

@immutable
abstract class LabelState extends Equatable {
  @override
  List<Object> get props => [];
}

final class LabelInitial extends LabelState {}

final class LabelLoading extends LabelState {}

final class LabelLoaded extends LabelState {
  final LabelResponse label;

  LabelLoaded({required this.label});
  @override
  List<Object> get props => [label];
}

final class LabelError extends LabelState {}
