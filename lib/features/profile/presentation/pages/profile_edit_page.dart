import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../../../core/models/athlete.dart';

class ProfileEditPage extends StatefulWidget {
  final Athlete athlete;
  final Function(Athlete) onSave;

  const ProfileEditPage({
    Key? key,
    required this.athlete,
    required this.onSave,
  }) : super(key: key);

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _majorController;
  late TextEditingController _careerController;
  late TextEditingController _universityController;
  late TextEditingController _sportController;
  late AthleteStatus _athleteStatus;
  DateTime? _graduationYear;
  String? _profileImageUrl;
  File? _profileImageFile;
  List<String> _achievements = [];

  final _formKey = GlobalKey<FormState>();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with athlete data
    _nameController = TextEditingController(text: widget.athlete.name);
    _emailController = TextEditingController(text: widget.athlete.email);
    _majorController = TextEditingController(text: widget.athlete.major);
    _careerController = TextEditingController(text: widget.athlete.career);
    _universityController = TextEditingController(text: widget.athlete.university ?? '');
    _sportController = TextEditingController(text: widget.athlete.sport ?? '');
    _athleteStatus = widget.athlete.status;
    _graduationYear = widget.athlete.graduationYear;
    _profileImageUrl = widget.athlete.profileImageUrl;
    _achievements = widget.athlete.achievements?.toList() ?? [];

    // Listen for changes to track if the form is dirty
    _nameController.addListener(_onFormChanged);
    _emailController.addListener(_onFormChanged);
    _majorController.addListener(_onFormChanged);
    _careerController.addListener(_onFormChanged);
    _universityController.addListener(_onFormChanged);
    _sportController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    setState(() {
      _hasChanges = true;
    });
  }

  @override
  void dispose() {
    // Clean up controllers
    _nameController.dispose();
    _emailController.dispose();
    _majorController.dispose();
    _careerController.dispose();
    _universityController.dispose();
    _sportController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Image picker functionality would go here
    // For now, we'll just simulate it
    setState(() {
      _profileImageUrl = null; // Clear existing URL when new image is picked
      _profileImageFile = null; // A real implementation would set this to the picked image
      _hasChanges = true;
    });
    
    // Show a snackbar to indicate this is a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image picker placeholder - would integrate with camera/gallery')),
    );
  }

  void _addAchievement() {
    setState(() {
      _achievements.add('New Achievement');
      _hasChanges = true;
    });
  }

  void _removeAchievement(int index) {
    setState(() {
      _achievements.removeAt(index);
      _hasChanges = true;
    });
  }

  void _updateAchievement(int index, String value) {
    setState(() {
      _achievements[index] = value;
      _hasChanges = true;
    });
  }

  void _selectGraduationYear() async {
    final initialDate = _graduationYear ?? DateTime.now();
    final firstDate = DateTime(DateTime.now().year - 50);
    final lastDate = DateTime(DateTime.now().year + 10);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      // Only select years, not full dates
      initialEntryMode: DatePickerEntryMode.input,
      initialDatePickerMode: DatePickerMode.year,
    );
    
    if (picked != null && picked != _graduationYear) {
      setState(() {
        _graduationYear = DateTime(picked.year);
        _hasChanges = true;
      });
    }
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      // Create updated athlete
      final updatedAthlete = widget.athlete.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        status: _athleteStatus,
        major: _majorController.text,
        career: _careerController.text,
        university: _universityController.text.isEmpty ? null : _universityController.text,
        sport: _sportController.text.isEmpty ? null : _sportController.text,
        achievements: _achievements.isEmpty ? null : _achievements,
        graduationYear: _graduationYear,
        // In a real implementation, this would handle the image file upload
        // and update the URL after upload
        profileImageUrl: _profileImageUrl,
      );
      
      // Call save callback
      widget.onSave(updatedAthlete);
      
      // Navigate back
      Navigator.of(context).pop();
    }
  }

  void _showDiscardDialog() {
    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('Are you sure you want to discard your changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('DISCARD'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _showDiscardDialog,
        ),
        actions: [
          TextButton(
            onPressed: _hasChanges ? _saveChanges : null,
            child: const Text('SAVE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              _buildProfileImageSection(),
              const SizedBox(height: 24),
              
              // Common Fields Section
              _buildCommonFieldsSection(),
              const SizedBox(height: 24),
              
              // Type Selection & Specific Fields
              _buildAthleteTypeSection(),
              const SizedBox(height: 16),
              _athleteStatus == AthleteStatus.current
                  ? _buildCurrentAthleteSection()
                  : _buildFormerAthleteSection(),
              const SizedBox(height: 24),
              
              // Achievements Section
              _buildAchievementsSection(),
              const SizedBox(height: 36),
              
              // Save/Cancel Buttons
              _buildBottomButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                  image: _profileImageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(_profileImageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _profileImageUrl == null
                    ? Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey.shade400,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: 18,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    onPressed: _pickImage,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Change Profile Picture',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonFieldsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            // Basic email validation
            if (!value.contains('@') || !value.contains('.')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _universityController,
          decoration: const InputDecoration(
            labelText: 'University',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _sportController,
          decoration: const InputDecoration(
            labelText: 'Sport',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildAthleteTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Athlete Status',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        SegmentedButton<AthleteStatus>(
          segments: const [
            ButtonSegment<AthleteStatus>(
              value: AthleteStatus.current,
              label: Text('Current Athlete'),
              icon: Icon(Icons.school),
            ),
            ButtonSegment<AthleteStatus>(
              value: AthleteStatus.former,
              label: Text('Former Athlete'),
              icon: Icon(Icons.work),
            ),
          ],
          selected: {_athleteStatus},
          onSelectionChanged: (Set<AthleteStatus> selection) {
            setState(() {
              _athleteStatus = selection.first;
              _hasChanges = true;
            });
          },
          showSelectedIcon: false,
        ),
      ],
    );
  }

  Widget _buildCurrentAthleteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Academic Information',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _majorController,
          decoration: const InputDecoration(
            labelText: 'Major',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (_athleteStatus == AthleteStatus.current && (value == null || value.isEmpty)) {
              return 'Please enter your major';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: _selectGraduationYear,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Expected Graduation Year',
              border: const OutlineInputBorder(),
              suffixIcon: Icon(
                Icons.calendar_today,
                color: Theme.of(context).primaryColor,
              ),
            ),
            child: Text(
              _graduationYear != null
                  ? _graduationYear!.year.toString()
                  : 'Select a year',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormerAthleteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Career Information',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _careerController,
          decoration: const InputDecoration(
            labelText: 'Career',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (_athleteStatus == AthleteStatus.former && (value == null || value.isEmpty)) {
              return 'Please enter your career';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: _selectGraduationYear,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Graduation Year',
              border: const OutlineInputBorder(),
              suffixIcon: Icon(
                Icons.calendar_today,
                color: Theme.of(context).primaryColor,
              ),
            ),
            child: Text(
              _graduationYear != null
                  ? _graduationYear!.year.toString()
                  : 'Select a year',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton.icon(
              onPressed: _addAchievement,
              icon: const Icon(Icons.add),
              label: const Text('ADD'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._achievements.asMap().entries.map((entry) {
          int index = entry.key;
          String achievement = entry.value;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: achievement,
                    decoration: InputDecoration(
                      labelText: 'Achievement ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => _updateAchievement(index, value),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeAchievement(index),
                ),
              ],
            ),
          );
        }).toList(),
        if (_achievements.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'No achievements added yet.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _showDiscardDialog,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('CANCEL'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _hasChanges ? _saveChanges : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('SAVE'),
          ),
        ),
      ],
    );
  }
} 