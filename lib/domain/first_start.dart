/// The first-start rule (02-design.md §8, permissions): the guided setup
/// comes once, on a fresh install. Someone who already has people never
/// sees it, whatever the flag says; HomeShell then also stores the flag so
/// that deleting everyone later does not bring the flow back.
bool showFirstStart({required bool done, required int peopleCount}) =>
    !done && peopleCount == 0;
