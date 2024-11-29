part of 'wadah_set_bloc.dart';

@immutable
abstract class WadahSetState extends Equatable {
  const WadahSetState();

  @override
  List<Object> get props => [];
}

final class WadahSetInitial extends WadahSetState {}

final class WadahSetLoading extends WadahSetState {}

final class WadahSetLoaded extends WadahSetState {
  final TongResponse wadahSet;

  const WadahSetLoaded(this.wadahSet);
  @override
  List<Object> get props => [wadahSet];
}

final class WadahSetError extends WadahSetState {}
