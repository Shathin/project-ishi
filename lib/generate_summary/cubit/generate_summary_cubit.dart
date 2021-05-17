import 'package:bloc/bloc.dart';

part 'generate_summary_state.dart';

class GenerateSummaryCubit extends Cubit<GenerateSummaryState> {
  GenerateSummaryCubit() : super(GenerateSummaryState());

  /// Invoked when the "Generate Summary" operation is requested
  void operationGenSummary() => emit(state.genInProgress());

  /// Invoked when the "Generate Summary" operation is completed
  void operationGenSummaryComplete() => emit(state.genComplete());

  /// Invoked when the "Generate Summary" operation has failed
  void operationGenSummaryFailed() => emit(state.genFailed());
}
