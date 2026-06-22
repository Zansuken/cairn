/// What the user did when the speed bump appeared for a tracked app.
///
/// Persisted as fixed integer indices because the native overlay writes them
/// straight into the append-only journal: resisted=0, allowed=1, shown=2. Do not
/// reorder — the values are a wire contract with the Kotlin side.
enum InterceptionOutcome {
  /// "Stay strong" — the user backed out. Excuses the matching OS open so the
  /// run is not broken.
  resisted,

  /// "Open anyway" — a real, chosen open. Counts as a slip.
  allowed,

  /// The bump was shown but no choice was recorded (the process died before an
  /// outcome, or the user left some other way). Does not excuse the open on its own.
  shown;

  static InterceptionOutcome fromIndex(int index) => InterceptionOutcome.values[index];
}
