import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanager/presentations/cubits/active_tasks_cubit.dart';
import '../../utils/time_utils.dart';

class AddTaskScreen extends StatefulWidget {
  final VoidCallback? toggleTheme;
  final bool? isDarkMode;

  const AddTaskScreen({
    super.key,
    this.toggleTheme,
    this.isDarkMode,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _selectedMinutes = 1;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _createTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();

    // Use the cubit - this will handle notifications automatically
    context.read<ActiveTasksCubit>().createTask(
          title: title,
          timeLimitMinutes: _selectedMinutes,
        );

    // Show success message and return
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Task "$title" created! Timer started for $_selectedMinutes minutes. 🔔 You\'ll get a reminder 10 seconds before time\'s up!',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
      ),
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Task'),
        elevation: 0,
        actions: [
          if (widget.toggleTheme != null && widget.isDarkMode != null)
            IconButton(
              icon: Icon(
                widget.isDarkMode! ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: widget.toggleTheme,
              tooltip: widget.isDarkMode! ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            ),
        ],
      ),
      body: BlocListener<ActiveTasksCubit, ActiveTasksState>(
        listener: (context, state) {
          if (state is ActiveTasksError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Failed to create task: ${state.message}'),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Details Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.task_alt, color: Colors.blue, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Task Details',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // TextField for task title
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Task Title',
                            hintText: 'What do you need to focus on?',
                            prefixIcon: Icon(Icons.edit),
                            helperText: 'Enter a descriptive title for your task',
                          ),
                          maxLength: 100,
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a task title';
                            }
                            if (value.trim().length < 3) {
                              return 'Task title must be at least 3 characters';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _createTask(),
                        ),

                        SizedBox(height: 24),

                        // Time Limit Section
                        Text(
                          'Time Limit',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Select how long you want to focus on this task',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                        ),
                        SizedBox(height: 12),

                        // Dropdown for time selection
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: isDark ? Colors.grey.shade800 : Colors.white,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedMinutes,
                              icon: Icon(Icons.arrow_drop_down),
                              isExpanded: true,
                              dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
                              items: TimeUtils.getTimePickerOptions().map((minutes) {
                                return DropdownMenuItem<int>(
                                  value: minutes,
                                  child: Row(
                                    children: [
                                      Icon(Icons.timer, size: 18, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          TimeUtils.formatMinutes(minutes),
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedMinutes = value!;
                                });
                              },
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Time preview with notification info
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.blue.shade900.withValues(alpha: 0.3) : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? Colors.blue.shade700 : Colors.blue.shade200,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.schedule, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Timer will start immediately for $_selectedMinutes ${_selectedMinutes == 1 ? 'minute' : 'minutes'}',
                                      style: TextStyle(
                                        color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.notifications_active, color: Colors.blue, size: 16),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'You\'ll get a notification 10 seconds before time expires',
                                      style: TextStyle(
                                        color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Info Card
                Card(
                  color: isDark ? Colors.orange.shade900.withValues(alpha: 0.3) : Colors.orange.shade50,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: isDark ? Colors.orange.shade300 : Colors.orange,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'How it works:',
                              style: TextStyle(
                                color: isDark ? Colors.orange.shade300 : Colors.orange.shade700,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Task timer starts immediately after creation\n'
                          '• You\'ll get a notification 10 seconds before time runs out\n'
                          '• Click "Mark as Done" to complete before time expires\n'
                          '• If time expires, task automatically moves to "Missed"\n'
                          '• Focus and beat the clock!',
                          style: TextStyle(
                            color: isDark ? Colors.orange.shade300 : Colors.orange.shade700,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Spacer(),

                // Add Task Button
                BlocBuilder<ActiveTasksCubit, ActiveTasksState>(
                  builder: (context, state) {
                    final isLoading = state is ActiveTasksLoading;

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _createTask,
                        icon: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Icon(Icons.add_task, size: 20),
                        label: Text(
                          isLoading ? 'Creating Task...' : 'Add Task & Start Timer',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
