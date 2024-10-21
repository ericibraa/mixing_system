part of 'tong_bloc.dart';

@immutable
abstract class TongState extends Equatable {
  const TongState();
  @override
  List<Object> get props => [];
}

final class TongInitial extends TongState {}

final class TongLoading extends TongState {}

final class TongLoaded extends TongState {
  final TongResponse tong;

  const TongLoaded(this.tong);
  @override
  List<Object> get props => [tong];
}

final class TongError extends TongState {}
