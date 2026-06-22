/// The finalized verdict for a single day window.
///
/// `unverified` means detection data was unavailable (permission revoked, or the
/// OS event log rolled off before reconciliation). It is never counted as clean
/// and never silently counted as a slip — it breaks the chain honestly.
enum DayState { clean, slipped, unverified }
