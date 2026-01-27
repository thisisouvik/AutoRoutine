import 'package:autoroutine/features/routines/cubit/template_cubit.dart';
import 'package:autoroutine/features/routines/cubit/template_state.dart';
import 'package:autoroutine/features/routines/presentation/create_template_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TemplateListScreen extends StatefulWidget {
  const TemplateListScreen({super.key});

  @override
  State<TemplateListScreen> createState() => _TemplateListScreenState();
}

class _TemplateListScreenState extends State<TemplateListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TemplateCubit>().loadTemplates();
  }

  void _confirmDelete(String templateId, String templateName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Delete "$templateName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TemplateCubit>().deleteTemplate(templateId);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmApply(String templateId, String templateName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apply Template'),
        content: Text(
          'Apply "$templateName" template?\n\nThis will add all routines from this template to your current schedule.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TemplateCubit>().applyTemplate(templateId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Applied: $templateName')));
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Templates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Template',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateTemplateScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TemplateCubit, TemplateState>(
        builder: (context, state) {
          if (state is TemplateLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TemplateLoaded) {
            if (state.templates.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('No templates yet'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Create First Template'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateTemplateScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.templates.length,
              itemBuilder: (context, index) {
                final template = state.templates[index];
                return Card(
                  child: ListTile(
                    title: Text(template.name),
                    subtitle: Text(
                      template.description ??
                          '${template.routines.length} routines',
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          child: const Text('Apply'),
                          onTap: () =>
                              _confirmApply(template.id, template.name),
                        ),
                        PopupMenuItem(
                          child: const Text('Delete'),
                          onTap: () =>
                              _confirmDelete(template.id, template.name),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          if (state is TemplateError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<TemplateCubit>().loadTemplates(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }
}
