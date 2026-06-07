import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/models/project.dart';
import 'package:otomasiku_mobile/providers/project_provider.dart';

void main() {
  group('Bug #2 — ProjectNotifier is single source of truth', () {
    test('createProject adds project visible in state.projects', () {
      final notifier = ProjectNotifier();

      expect(notifier.state.projects, isEmpty);

      notifier.createProject('Line 4 Maintenance');

      expect(notifier.state.projects, hasLength(1));
      expect(notifier.state.projects.first.name, 'Line 4 Maintenance');
    });

    test('addItemToProject updates existing project items', () {
      final notifier = ProjectNotifier();
      notifier.createProject('Test Project');

      final projectId = notifier.state.projects.first.id;
      notifier.addItemToProject(
        projectId,
        const ProjectItem(
          id: 'item-1',
          productId: 'MIT-INV-001',
          productName: 'FR-A840-2.2K-1',
          price: 15000000,
          quantity: 2,
        ),
      );

      expect(notifier.state.projects.first.items, hasLength(1));
      expect(notifier.state.projects.first.items.first.productName, 'FR-A840-2.2K-1');
    });

    test('multiple creates are all visible in single projects list', () {
      final notifier = ProjectNotifier();
      notifier.createProject('Project A');
      notifier.createProject('Project B');

      expect(notifier.state.projects, hasLength(2));
      expect(notifier.state.projects[0].name, 'Project A');
      expect(notifier.state.projects[1].name, 'Project B');
    });
  });
}
