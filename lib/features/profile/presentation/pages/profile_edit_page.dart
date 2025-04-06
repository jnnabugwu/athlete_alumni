import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../core/models/athlete.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _universityController;
  late TextEditingController _sportController;
  late AthleteStatus _athleteStatus;
  late AthleteMajor _selectedMajor;
  late AthleteCareer _selectedCareer;
  DateTime? _graduationYear;
  String? _profileImageUrl;
  File? _profileImageFile;
  List<String> _achievements = [];
  String _email = '';

  final _formKey = GlobalKey<FormState>();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.athlete.name ?? '');
    _usernameController = TextEditingController(text: widget.athlete.username ?? '');
    _universityController = TextEditingController(text: widget.athlete.university ?? '');
    _sportController = TextEditingController(text: widget.athlete.sport ?? '');
    _athleteStatus = widget.athlete.status;
    _selectedMajor = widget.athlete.major;
    _selectedCareer = widget.athlete.career;
    _graduationYear = widget.athlete.graduationYear;
    _profileImageUrl = widget.athlete.profileImageUrl;
    _achievements = widget.athlete.achievements?.toList() ?? [];
    
    // Initialize email from athlete object or try to get it from Supabase
    _initializeEmail();

    _fullNameController.addListener(_onFormChanged);
    _usernameController.addListener(_onFormChanged);
    _universityController.addListener(_onFormChanged);
    _sportController.addListener(_onFormChanged);
  }

  void _initializeEmail() {
    // First try to get email from athlete object
    if (widget.athlete.email != null && widget.athlete.email!.isNotEmpty) {
      _email = widget.athlete.email!;
      debugPrint('📧 Email from athlete object: $_email');
      return;
    }
    
    // If not available, try to get it from Supabase auth
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && user.email != null && user.email!.isNotEmpty) {
      setState(() {
        _email = user.email!;
        debugPrint('📧 Email from Supabase auth: $_email');
      });
    } else {
      debugPrint('⚠️ Could not find email from athlete object or Supabase auth');
    }
  }

  void _onFormChanged() {
    setState(() {
      _hasChanges = true;
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _universityController.dispose();
    _sportController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() {
      _profileImageUrl = null;
      _profileImageFile = null;
      _hasChanges = true;
    });
    
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
    final initialYear = _graduationYear?.year ?? DateTime.now().year;
    
    final int? selectedYear = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Graduation Year'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (BuildContext context, int index) {
                final year = DateTime.now().year - 30 + index;
                return ListTile(
                  title: Text(year.toString(), textAlign: TextAlign.center),
                  selected: year == initialYear,
                  onTap: () => Navigator.of(context).pop(year),
                );
              },
            ),
          ),
        );
      },
    );
    
    if (selectedYear != null) {
      setState(() {
        _graduationYear = DateTime(selectedYear);
        _hasChanges = true;
      });
    }
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedAthlete = widget.athlete.copyWith(
        name: _fullNameController.text,
        username: _usernameController.text,
        email: _email,
        status: _athleteStatus,
        major: _selectedMajor,
        career: _selectedCareer,
        university: _universityController.text.isEmpty ? null : _universityController.text,
        sport: _sportController.text.isEmpty ? null : _sportController.text,
        achievements: _achievements.isEmpty ? null : _achievements,
        graduationYear: _graduationYear,
        profileImageUrl: _profileImageUrl,
      );
      
      // Show notification that changes are being saved
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saving changes... You will be redirected to the home page.'),
          duration: Duration(seconds: 2),
        ),
      );
      
      debugPrint("ProfileEditPage: Saving changes for athlete ID: ${updatedAthlete.id}, email: ${updatedAthlete.email}");
      widget.onSave(updatedAthlete);
      
      // Navigation will be handled by the parent EditProfileScreen
      // after the save is processed and the bloc emits EditProfileSaveSuccess
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
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Profile',
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
              _buildProfileImageSection(),
              const SizedBox(height: 24),
              
              _buildCommonFieldsSection(),
              const SizedBox(height: 24),
              
              _buildAthleteTypeSection(),
              const SizedBox(height: 16),
              _athleteStatus == AthleteStatus.current
                  ? _buildCurrentAthleteSection()
                  : _buildFormerAthleteSection(),
              const SizedBox(height: 24),
              
              _buildAchievementsSection(),
              const SizedBox(height: 36),
              
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
          'Personal Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _fullNameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a username';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _email,
          readOnly: true,
          enabled: false,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            fillColor: Color(0xFFF5F5F5),
            filled: true,
          ),
        ),
        const SizedBox(height: 24),
        
        Text(
          'University Information',
          style: Theme.of(context).textTheme.titleLarge,
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
        DropdownButtonFormField<AthleteMajor>(
          value: _selectedMajor,
          decoration: const InputDecoration(
            labelText: 'Major',
            border: OutlineInputBorder(),
          ),
          items: AthleteMajor.values
              .map((major) => DropdownMenuItem(
                    value: major,
                    child: Text(major.displayName),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              if (value != null) {
                _selectedMajor = value;
                _hasChanges = true;
              }
            });
          },
          validator: (value) {
            if (_athleteStatus == AthleteStatus.current && value == null) {
              return 'Please select your major';
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
        DropdownButtonFormField<AthleteCareer>(
          value: _selectedCareer,
          decoration: const InputDecoration(
            labelText: 'Career',
            border: OutlineInputBorder(),
          ),
          items: AthleteCareer.values
              .map((career) => DropdownMenuItem(
                    value: career,
                    child: Text(career.displayName),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              if (value != null) {
                _selectedCareer = value;
                _hasChanges = true;
              }
            });
          },
          validator: (value) {
            if (_athleteStatus == AthleteStatus.former && value == null) {
              return 'Please select your career';
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
    return Column(
      children: [
        Row(
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
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.person),
          label: const Text('Back to Profile'),
          onPressed: () {
            if (_hasChanges) {
              _showDiscardDialog();
            } else {
              Navigator.of(context).pop();
            }
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            minimumSize: const Size(double.infinity, 0), // Full width
          ),
        ),
      ],
    );
  }
} 