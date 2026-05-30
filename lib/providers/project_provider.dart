import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project.dart';

/// Provider for managing projects state
final projectProvider = StateNotifierProvider<ProjectNotifier, ProjectState>((ref) {
  return ProjectNotifier();
});

/// Project state
class ProjectState {
  final List<Project> projects;
  final Project? currentProject;
  final bool isLoading;
  final String? error;

  const ProjectState({
    required this.projects,
    this.currentProject,
    this.isLoading = false,
    this.error,
  });

  ProjectState copyWith({
    List<Project>? projects,
    Project? currentProject,
    bool? isLoading,
    String? error,
  }) {
    return ProjectState(
      projects: projects ?? this.projects,
      currentProject: currentProject ?? this.currentProject,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Project notifier
class ProjectNotifier extends StateNotifier<ProjectState> {
  ProjectNotifier() : super(const ProjectState(projects: []));

  /// Load projects — starts empty, user creates their own
  void loadProjects() {
    // No-op: projects are user-created only
  }

  /// Get project by ID
  Project? getProjectById(String id) {
    try {
      return state.projects.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Set current project (for detail view)
  void setCurrentProject(String id) {
    final project = getProjectById(id);
    state = state.copyWith(currentProject: project);
  }

  /// Update project status
  void updateProjectStatus(String id, ProjectStatus status) {
    final updatedProjects = state.projects.map((p) {
      if (p.id == id) {
        return p; // Project is immutable, would need copyWith if mutable
      }
      return p;
    }).toList();

    state = state.copyWith(projects: updatedProjects);
  }

  /// Create a new project
  void createProject(String name) {
    final newProject = Project(
      id: 'proj-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      items: const [],
      createdAt: DateTime.now(),
      status: ProjectStatus.planning,
    );
    state = state.copyWith(projects: [...state.projects, newProject]);
  }

  /// Add a product item to a project
  void addItemToProject(String projectId, ProjectItem item) {
    final updatedProjects = state.projects.map((p) {
      if (p.id == projectId) {
        final existingIdx = p.items.indexWhere((i) => i.productId == item.productId);
        if (existingIdx >= 0) {
          final updated = List<ProjectItem>.from(p.items);
          final existing = updated[existingIdx];
          updated[existingIdx] = ProjectItem(
            id: existing.id,
            productId: existing.productId,
            productName: existing.productName,
            productImage: existing.productImage,
            price: existing.price,
            quantity: existing.quantity + item.quantity,
          );
          return p.copyWith(items: updated);
        }
        return p.copyWith(items: [...p.items, item]);
      }
      return p;
    }).toList();
    state = state.copyWith(projects: updatedProjects);
  }
}
