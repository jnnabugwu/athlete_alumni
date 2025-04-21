import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import '../../../../core/models/athlete.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/upload_image_bloc.dart';
import '../../data/services/image_picker_service.dart';

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
  late TextEditingController _emailController;
  late AthleteStatus _athleteStatus;
  late AthleteMajor _selectedMajor;
  late AthleteCareer _selectedCareer;
  DateTime? _graduationYear;
  String? _profileImageUrl;
  File? _profileImageFile;
  List<String> _achievements = [];
  String _email = '';
  StreamSubscription? _uploadSubscription;
  
  // Image picker service
  final ImagePickerService _imagePickerService = sl<ImagePickerService>();
  
  // Upload bloc
  late UploadImageBloc _uploadImageBloc;

  final _formKey = GlobalKey<FormState>();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize the upload image bloc
    _uploadImageBloc = sl<UploadImageBloc>();
    
    _fullNameController = TextEditingController(text: widget.athlete.name ?? '');
    _usernameController = TextEditingController(text: widget.athlete.username ?? '');
    _universityController = TextEditingController(text: widget.athlete.university ?? '');
    _sportController = TextEditingController(text: widget.athlete.sport ?? '');
    _emailController = TextEditingController(text: '');
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
    // Debug the auth state
    final user = Supabase.instance.client.auth.currentUser;
    debugPrint('🔒 Auth check - Is user authenticated: ${user != null}');
    if (user != null) {
      debugPrint('🔒 Auth user ID: ${user.id}');
      debugPrint('🔒 Auth user email: ${user.email}');
      debugPrint('🔒 Auth user has identities: ${user.identities?.isNotEmpty}');
      
      // Log all available user data for debugging
      debugPrint('🔒 Auth user data: ${user.toJson()}');
    }
    
    // Check all possible sources for email and use the first valid one found
    
    // 1. Try from athlete object (if not empty)
    debugPrint('📧 Checking athlete email: "${widget.athlete.email}"');
    if (widget.athlete.email.isNotEmpty && widget.athlete.email != 'null') {
      setState(() {
        _email = widget.athlete.email;
        _emailController.text = _email;
        debugPrint('📧 Email set from athlete object: $_email');
      });
      return;
    }
    
    // 2. Try from Supabase auth currentUser.email
    if (user != null && user.email != null && user.email!.isNotEmpty) {
      setState(() {
        _email = user.email!;
        _emailController.text = _email;
        debugPrint('📧 Email set from Supabase auth: $_email');
      });
      return;
    }
    
    // 3. Try from user.userMetadata
    if (user != null && user.userMetadata != null) {
      final metadata = user.userMetadata!;
      
      // Check for email in various metadata fields
      for (final field in ['email', 'email_address', 'google_email']) {
        if (metadata.containsKey(field) && 
            metadata[field] != null && 
            metadata[field].toString().isNotEmpty) {
          setState(() {
            _email = metadata[field].toString();
            _emailController.text = _email;
            debugPrint('📧 Email set from user metadata field "$field": $_email');
          });
          return;
        }
      }
      
      // Log all metadata for debugging
      debugPrint('📧 All user metadata: $metadata');
    }
    
    // 4. Try from user identities (for OAuth providers like Google)
    if (user != null && user.identities != null && user.identities!.isNotEmpty) {
      for (final identity in user.identities!) {
        // Try to access the email from identity data
        final identityData = identity.identityData;
        debugPrint('🔍 Checking identity data: $identityData');
        
        if (identityData != null) {
          // Check for email in various identity fields
          for (final field in ['email', 'email_address']) {
            if (identityData.containsKey(field) && 
                identityData[field] != null && 
                identityData[field].toString().isNotEmpty) {
              setState(() {
                _email = identityData[field].toString();
                _emailController.text = _email;
                debugPrint('📧 Email set from identity data field "$field": $_email');
              });
              return;
            }
          }
        }
      }
    }
    
    // If still no email, try one more source - the session
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        // Try to extract email from the session
        final accessToken = session.accessToken;
        final refreshToken = session.refreshToken;
        
        debugPrint('🔑 Session exists: $session');
        debugPrint('🔑 Access token exists: $accessToken');
        debugPrint('🔑 Refresh token exists: ${refreshToken != null}');
        
        // Check if session has user info
        if (session.user != null && session.user.email != null && session.user.email!.isNotEmpty) {
          setState(() {
            _email = session.user.email!;
            _emailController.text = _email;
            debugPrint('📧 Email set from session user: $_email');
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking session: $e');
    }
    
    // If still no email, log the situation
    debugPrint('⚠️ Could not find email from any source');
    
    // Log the current user to help debug
    if (user != null) {
      debugPrint('📱 Current user id: ${user.id}');
      debugPrint('📱 Current user metadata: ${user.userMetadata}');
      debugPrint('📱 Current user app metadata: ${user.appMetadata}');
    } else {
      debugPrint('⚠️ No current user found in Supabase');
    }
    
    // Set a fallback email if we couldn't find any
    setState(() {
      _email = 'No email found';
      _emailController.text = _email;
      debugPrint('⚠️ Setting fallback email text: $_email');
    });
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
    _emailController.dispose();
    _uploadImageBloc.close();
    super.dispose();
  }

  Future<void> _pickImage() async {
  try {
    // Show the image source dialog
    final ImageResult? result = await _imagePickerService.showImageSourceDialog(context);
    
    if (result == null) {
      debugPrint('Image picking cancelled');
      return;
    }
    
    debugPrint('Image picked: ${result.fileName}');
    
    // Get the upload image bloc from context
    final uploadBloc = BlocProvider.of<UploadImageBloc>(context);
    
    // Cancel any existing subscription
    if(_uploadSubscription != null){
      _uploadSubscription?.cancel();
      _uploadSubscription = null;
    }
    
    // Upload the image using the bloc
    uploadBloc.add(UploadProfileImageEvent(
      athleteId: widget.athlete.id,
      imageBytes: result.imageBytes,
      fileName: result.fileName,
    ));
    
    // Create a new subscription to handle the completion
    _uploadSubscription = uploadBloc.stream.listen((state) {
      if (state is UploadImageSuccess) {
        print('Image uploaded: ${state.imageUrl}');
        setState(() {
          _profileImageUrl = state.imageUrl;
          _hasChanges = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully')),
        );
        
        // Reset the state to initial after success
        uploadBloc.add(ResetUploadStateEvent());
        
        // Cancel the subscription
        _uploadSubscription?.cancel();
        _uploadSubscription = null;
      } else if (state is UploadImageFailure) {
        debugPrint('Image upload failed: ${state.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: ${state.message}')),
        );
        
        // Reset the state to initial after failure
        uploadBloc.add(ResetUploadStateEvent());
        
        // Cancel the subscription
        _uploadSubscription?.cancel();
        _uploadSubscription = null;
      }
    });
  } catch (e) {
    debugPrint('Error picking/uploading image: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
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
              itemCount: 50,
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
      // FORCE VISIBLE LOGGING - will definitely show in console
      
      // Make sure we have a valid email from the email field
      final emailToSave = _email.isNotEmpty && _email != 'No email found' 
          ? _email 
          : widget.athlete.email;
          
      final updatedAthlete = widget.athlete.copyWith(
        name: _fullNameController.text,
        username: _usernameController.text,
        email: emailToSave,
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
        SnackBar(
          content: Text("Saving changes for athlete: ${updatedAthlete.name}"),
          duration: const Duration(seconds: 2),
        ),
      );
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
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email header section at the very top
              if (_email.isNotEmpty && _email != 'No email found')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_circle, size: 40, color: Colors.indigo),
                      const SizedBox(height: 8),
                      Text(
                        _email,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Signed in with Google',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              
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
          BlocBuilder<UploadImageBloc, UploadImageState>(
            builder: (context, state) {
              // Get the upload image bloc from context instead of using the instance variable
              _uploadImageBloc = BlocProvider.of<UploadImageBloc>(context);
              
              return Stack(
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
                    child: state is UploadImageLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          )
                        : _profileImageUrl == null
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
                        onPressed: state is UploadImageLoading ? null : _pickImage,
                      ),
                    ),
                  ),
                ],
              );
            },
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
          controller: _emailController,
          readOnly: true,
          enabled: false,
          decoration: InputDecoration(
            labelText: 'Email',
            border: const OutlineInputBorder(),
            fillColor: const Color(0xFFE3F2FD), // Light blue background
            filled: true,
            prefixIcon: _email.contains('@gmail.com')
                ? const Icon(Icons.alternate_email, color: Colors.red)
                : Icon(Icons.email, color: Theme.of(context).primaryColor),
            helperText: _email.contains('@gmail.com')
                ? 'Connected with Google Sign-In'
                : 'Your account email (cannot be changed)',
            labelStyle: TextStyle(
              color: _email.contains('@gmail.com') 
                ? Colors.red
                : Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
            // Add more debugging information in a suffix
            suffixIcon: _email.isEmpty || _email == 'No email found' 
                ? const Icon(Icons.warning, color: Colors.orange)
                : _email.contains('@gmail.com')
                    ? const Icon(Icons.verified_user, color: Colors.green)
                    : const Icon(Icons.check_circle, color: Colors.green),
          ),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _email.isEmpty || _email == 'No email found' 
                ? Colors.red 
                : _email.contains('@gmail.com')
                    ? Colors.red.shade800
                    : Colors.black,
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