import 'package:flutter_test/flutter_test.dart';
import 'package:isu_camp_app/features/dashboard/models/campus_models.dart';
import 'package:isu_camp_app/features/dashboard/models/navigation_history.dart';
import 'package:isu_camp_app/features/dashboard/services/navigation_history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  NavigationHistoryEntry entry({
    required String id,
    required DateTime time,
    NavigationHistoryStatus status = NavigationHistoryStatus.previewed,
  }) {
    return NavigationHistoryEntry(
      id: id,
      destinationId: 'osas',
      destinationName: 'Office of Student Affairs and Services',
      destinationAcronym: 'OSAS',
      originLabel: 'ISU Main Gate',
      routeType: RouteType.shortest,
      transportMode: TransportMode.walking,
      distanceMeters: 120,
      estimatedMinutes: 2,
      status: status,
      createdAt: time,
      updatedAt: time,
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('history is saved per user and sorted newest first', () async {
    final older = entry(id: 'older', time: DateTime(2026, 9, 18, 9));
    final newer = entry(id: 'newer', time: DateTime(2026, 9, 19, 10));

    await NavigationHistoryService.upsert('student', older);
    await NavigationHistoryService.upsert('student', newer);

    final results = await NavigationHistoryService.load('student');
    expect(results.map((item) => item.id), ['newer', 'older']);
    expect(await NavigationHistoryService.load('another-user'), isEmpty);
  });

  test('starting navigation updates the preview entry without duplicating it',
      () async {
    final preview = entry(id: 'same-session', time: DateTime(2026, 9, 19, 10));
    final started = preview.copyWith(
      status: NavigationHistoryStatus.navigationStarted,
      updatedAt: DateTime(2026, 9, 19, 10, 1),
    );

    await NavigationHistoryService.upsert('student', preview);
    await NavigationHistoryService.upsert('student', started);

    final results = await NavigationHistoryService.load('student');
    expect(results, hasLength(1));
    expect(results.single.status, NavigationHistoryStatus.navigationStarted);
  });

  test('history supports individual delete and clear all', () async {
    await NavigationHistoryService.upsert(
      'student',
      entry(id: 'one', time: DateTime(2026, 9, 19, 10)),
    );
    await NavigationHistoryService.upsert(
      'student',
      entry(id: 'two', time: DateTime(2026, 9, 19, 11)),
    );

    await NavigationHistoryService.delete('student', 'one');
    expect(
      (await NavigationHistoryService.load('student')).single.id,
      'two',
    );

    await NavigationHistoryService.clear('student');
    expect(await NavigationHistoryService.load('student'), isEmpty);
  });
}
