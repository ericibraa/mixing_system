part of 'result_scale_2_bloc.dart';

@immutable
abstract class ResultScale2State extends Equatable {
  @override
  List<Object> get props => [];
}

final class ResultScale2Initial extends ResultScale2State {}

final class ResultScale2Loading extends ResultScale2State {}

final class ResultScale2Loaded extends ResultScale2State {
  final ResultScaleListResponse resultScale2;

  ResultScale2Loaded({required this.resultScale2});

  @override
  List<Object> get props => [ResultScale2State];
}

final class ResultScale2Error extends ResultScale2State {}
