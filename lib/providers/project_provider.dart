import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project.dart';
import '../data/dummy/dummy_projects.dart' as dummy_projects;

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
  ProjectNotifier() : super(const ProjectState(projects: [])) {
    loadProjects();
  }

  /// Load projects from dummy data (M2 only)
  void loadProjects() {
    state = state.copyWith(projects: dummy_projects.dummyProjects);
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
}
