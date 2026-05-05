import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/activity_provider.dart';
import '../../models/activity.dart';
import '../../constants/activity_constants.dart';

class LogActivityScreen extends StatefulWidget {
  const LogActivityScreen({super.key});

  @override
  State<LogActivityScreen> createState() => _LogActivityScreenState();
}

class _LogActivityScreenState extends State<LogActivityScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;

  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'Running';
  final _valueController = TextEditingController();
  final _caloriesController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..value = 1.0;
    _scaleAnimation = CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut);

    // Auto-calculate calories when value changes
    _valueController.addListener(_updateCalories);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _valueController.removeListener(_updateCalories);
    _valueController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _updateCalories() {
    if (_valueController.text.isEmpty) return;
    
    double? value = double.tryParse(_valueController.text);
    if (value != null) {
      double multiplier = ActivityConstants.caloriesPerUnit[_selectedType] ?? 1.0;
      double estimatedCalories = value * multiplier;
      _caloriesController.text = estimatedCalories.toStringAsFixed(0);
    }
  }

  final List<String> _activityTypes = [
    'Running',
    'Walking',
    'Cycling',
    'Gym',
    'Swimming',
    'Other'
  ];

  void _saveActivity() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      try {
        final activityProvider = Provider.of<ActivityProvider?>(context, listen: false);
        if (activityProvider != null) {
          final newActivity = Activity(
            type: _selectedType,
            value: double.parse(_valueController.text),
            unit: ActivityConstants.getUnitForType(_selectedType),
            timestamp: DateTime.now(),
            caloriesBurned: double.parse(_caloriesController.text),
          );

          // Add a 10-second timeout so it doesn't spin forever
          await activityProvider.addActivity(newActivity).timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw 'Connection timed out. Check your internet.',
          );
          
          if (mounted) Navigator.pop(context);
        } else {
          throw 'User session not found.';
        }
      } catch (e) {
        setState(() => _isSaving = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stride', style: TextStyle(color: onSurface, fontWeight: FontWeight.w800, fontSize: 24)),
            Text('Log Activity', style: TextStyle(color: onSurface.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Illustration/Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D5AFE).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    size: 64,
                    color: Color(0xFF3D5AFE),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Log Your Effort',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: onSurface),
              ),
              Text(
                'Track your progress and stay consistent.',
                style: TextStyle(fontSize: 16, color: onSurface.withOpacity(0.5)),
              ),
              const SizedBox(height: 40),
              
              // Activity Type
              _buildLabel('Activity Type'),
              DropdownButtonFormField<String>(
                value: _selectedType,
                dropdownColor: Theme.of(context).cardColor,
                style: TextStyle(color: onSurface, fontSize: 16),
                decoration: _inputDecoration(icon: Icons.category_outlined, isDark: isDark, onSurface: onSurface),
                items: _activityTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedType = val!);
                  _updateCalories();
                },
              ),
              const SizedBox(height: 20),
              
              // Value
              _buildLabel(_selectedType == 'Walking' || _selectedType == 'Running' ? 'Steps' : 'Duration (minutes)'),
              TextFormField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: onSurface),
                decoration: _inputDecoration(
                  icon: _selectedType == 'Walking' || _selectedType == 'Running' ? Icons.directions_walk : Icons.timer_outlined,
                  isDark: isDark,
                  onSurface: onSurface,
                  hint: _selectedType == 'Walking' || _selectedType == 'Running' ? '0 steps' : '0 minutes'
                ),
                validator: (val) => val!.isEmpty ? 'Please enter a value' : null,
              ),
              const SizedBox(height: 20),
              
              // Calories
              _buildLabel('Calories Burned'),
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: onSurface),
                decoration: _inputDecoration(
                  icon: Icons.local_fire_department_rounded,
                  isDark: isDark,
                  onSurface: onSurface,
                  hint: 'Estimated calories'
                ),
                validator: (val) => val!.isEmpty ? 'Please enter calories' : null,
              ),
              
              const SizedBox(height: 50),
              
              GestureDetector(
                onTapDown: (_) => _bounceController.reverse(),
                onTapUp: (_) => _bounceController.forward(),
                onTapCancel: () => _bounceController.forward(),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3D5AFE), Color(0xFF00B0FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3D5AFE).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveActivity,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _isSaving 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Save Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required IconData icon, required bool isDark, required Color onSurface, String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: onSurface.withOpacity(0.3)),
      prefixIcon: Icon(icon, color: const Color(0xFF3D5AFE).withOpacity(0.7)),
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF3D5AFE), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}
