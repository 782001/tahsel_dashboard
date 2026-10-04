import 'package:flutter_bloc/flutter_bloc.dart';

/// A robust [Cubit] base class that prevents:
/// `Unhandled Exception: Bad state: Cannot emit new states after calling close`
/// by safely verifying [isClosed] before emitting any state.
abstract class SafeCubit<State> extends Cubit<State> {
  SafeCubit(super.initialState);

  @override
  void emit(State state) {
    if (!isClosed) {
      super.emit(state);
    }
  }
}
