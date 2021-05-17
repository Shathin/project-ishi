part of 'generate_summary_cubit.dart';

enum GenerateSummaryStatus {
  pageLoadComplete,
  genInProgress,
  genComplete,
  genFailed,
}

class GenerateSummaryState {
  final GenerateSummaryStatus status;

  GenerateSummaryState({this.status = GenerateSummaryStatus.pageLoadComplete});

  /// Invoked when the "Generate Summary" operation is requested
  GenerateSummaryState genInProgress() =>
      GenerateSummaryState(status: GenerateSummaryStatus.genInProgress);

  /// Invoked when the "Generate Summary" operation is complete
  GenerateSummaryState genComplete() =>
      GenerateSummaryState(status: GenerateSummaryStatus.genComplete);

  /// Invoked when the "Generate Summary" operation has failed
  GenerateSummaryState genFailed() =>
      GenerateSummaryState(status: GenerateSummaryStatus.genFailed);
}
