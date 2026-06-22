/// Lifecycle of a tracked app. `freed` = uninstalled → permanent summit trophy,
/// stops accruing an active streak (PRD §2).
enum AppStatus { active, freed }

/// An app the user has chosen to moderate.
class TrackedApp {
  const TrackedApp({
    required this.packageId,
    required this.displayName,
    required this.addedAt,
    this.status = AppStatus.active,
    this.freedAt,
  });

  final String packageId;
  final String displayName;
  final DateTime addedAt;
  final AppStatus status;
  final DateTime? freedAt;

  bool get isFreed => status == AppStatus.freed;

  TrackedApp copyWith({AppStatus? status, DateTime? freedAt, String? displayName}) => TrackedApp(
        packageId: packageId,
        displayName: displayName ?? this.displayName,
        addedAt: addedAt,
        status: status ?? this.status,
        freedAt: freedAt ?? this.freedAt,
      );
}
