import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/app_toast.dart';
import '../../l10n/app_localizations.dart';
import '../../data/dummy/dummy_projects.dart';
import '../../models/project.dart';

/// Projects screen showing user's saved projects for B2B bulk purchases
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  void _showCreateProjectDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).createProject),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).projectName,
            hintText: 'Contoh: Maintenance Line 4',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(ctx);
                AppToast.show(
                  context,
                  'Proyek "${controller.text}" berhasil dibuat!',
                  isError: false,
                );
              }
            },
            child: Text(AppLocalizations.of(context).confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate stats
    final activeProjects = dummyProjects.where((p) => p.status == ProjectStatus.active).length;
    final totalItems = dummyProjects.fold(0, (sum, p) => sum + p.itemCount);
    final totalEstimate = dummyProjects.fold(0, (sum, p) => sum + p.totalValue);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(l10n.myProjects),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showCreateProjectDialog,
            icon: const Icon(Icons.add),
            color: AppColors.mitsubishiRed,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats grid
            _buildStatsGrid(context, l10n, activeProjects, totalItems, totalEstimate),
            const SizedBox(height: 16),

            // Project cards
            ...dummyProjects.map((project) => _buildProjectCard(context, l10n, project, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    AppLocalizations l10n,
    int activeProjects,
    int totalItems,
    int totalEstimate,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            '$activeProjects',
            l10n.activeProjects,
            AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            '$totalItems',
            l10n.totalItems,
            AppColors.mitsubishiRed,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            CurrencyFormatter.formatCompact(totalEstimate),
            l10n.totalEstimate,
            AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, Color valueColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    AppLocalizations l10n,
    Project project,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(project.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => AppToast.show(
                    context,
                    'Link proyek "${project.name}" disalin',
                    isError: false,
                  ),
                  icon: Icon(Icons.share, size: 18),
                  color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                ),
              ],
            ),
          ),

          // Items preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: project.items.take(2).map((item) => _buildItemPreview(item, isDark)).toList(),
            ),
          ),

          // Footer with total and buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${project.items.length} item total',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Total: ${CurrencyFormatter.format(project.totalValue)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mitsubishiRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.pushNamed(AppRoute.checkout),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mitsubishiRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(l10n.checkoutProject),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => AppToast.show(
                          context,
                          'RFQ dikirim',
                          isError: false,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(l10n.requestRFQ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemPreview(ProjectItem item, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.productImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      item.productImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.inventory_2,
                        color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                        size: 20,
                      ),
                    ),
                  )
                : Icon(
                    Icons.inventory_2,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                    size: 20,
                  ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${item.quantity} unit × ${CurrencyFormatter.format(item.price)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              CurrencyFormatter.formatCompact(item.totalPrice),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return 'Dibuat ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}