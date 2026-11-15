import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/providers.dart';
import 'package:kept/app/services.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/demo_data.dart';
import 'package:kept/domain/person.dart';

void main() {
  late AppServices services;
  late ProviderContainer container;

  setUp(() {
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
      allowDemo: true,
    );
    container = ProviderContainer(
      overrides: [servicesProvider.overrideWithValue(services)],
    );
  });
  tearDown(() async {
    container.dispose();
    await services.close();
  });

  /// The people list once it shows [length] people.
  Future<List<Person>> peopleWhen(int length) async {
    final sub = container.listen(peopleProvider, (_, _) {});
    try {
      for (var i = 0; i < 100; i++) {
        final people = sub.read().value;
        if (people != null && people.length == length) return people;
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      fail('people never reached $length: ${sub.read()}');
    } finally {
      sub.close();
    }
  }

  test('demo mode shows the demo set and leaves the real people', () async {
    final real = services.peopleFor(demo: false);
    final anna = await real.add(name: 'Anna Real', closeness: Closeness.close);
    final ben = await real.add(name: 'Ben Real', closeness: Closeness.family);
    expect((await peopleWhen(2)).map((p) => p.name), ['Anna Real', 'Ben Real']);

    final today = DateTime(2026, 11, 16);
    await services.setDemoMode(true, today: today);
    final demo = await peopleWhen(16);
    expect(
      demo.map((p) => p.id).toSet(),
      demoPeople(today).map((p) => p.id).toSet(),
    );
    expect(container.read(peopleRepositoryProvider), isNot(same(real)));

    // A change in demo mode goes to the demo database only.
    await container
        .read(peopleRepositoryProvider)
        .add(name: 'Zoe Demo', closeness: Closeness.close);
    await peopleWhen(17);

    await services.setDemoMode(false);
    expect(await peopleWhen(2), [anna, ben]);

    // Switching on again starts the demo set from scratch.
    await services.setDemoMode(true, today: today);
    expect(
      (await peopleWhen(16)).map((p) => p.name),
      isNot(contains('Zoe Demo')),
    );
    expect((await services.settings.load()).demoMode, isTrue);
  });

  test('without demo allowed the switch does nothing', () async {
    final release = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => throw StateError('must not open'),
      allowDemo: false,
    );
    await release.setDemoMode(true);
    expect((await release.settings.load()).demoMode, isFalse);
    expect(release.peopleFor(demo: true), same(release.peopleFor(demo: false)));
    await release.close();
  });
}
