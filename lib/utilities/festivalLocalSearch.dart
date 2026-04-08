import '../models/festivalModel.dart';

/// Client-side filter when offline and [festivals] is already loaded.
List<FestivalResource> filterFestivalsLocally(
  Iterable<FestivalResource> festivals,
  String query,
) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return festivals.toList();
  return festivals.where((f) {
    final nameOrganizer = (f.nameOrganizer ?? '').toLowerCase();
    final description = f.description.toLowerCase();
    final descriptionOrganizer = (f.descriptionOrganizer ?? '').toLowerCase();
    return nameOrganizer.contains(q) ||
        description.contains(q) ||
        descriptionOrganizer.contains(q);
  }).toList();
}
