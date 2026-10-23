part of 'location_set_bloc.dart';

@immutable
abstract class LocationSetState extends Equatable {
  const LocationSetState();

  @override
  List<Object> get props => [];
}

final class LocationSetInitial extends LocationSetState {}

final class LocationSetLoading extends LocationSetState {}

final class LocationSetLoaded extends LocationSetState {
  final LocationSetResponse locationSet;

  const LocationSetLoaded(this.locationSet);
  @override
  List<Object> get props => [locationSet];
}

final class LocationSetError extends LocationSetState {
  final String error;

  const LocationSetError(this.error);

  @override
  List<Object> get props => [error];
}
