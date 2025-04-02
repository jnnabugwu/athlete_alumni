import 'package:flutter/material.dart';
import '../../../../core/models/athlete.dart';

class TypeSpecificSection extends StatelessWidget {
  final Athlete athlete;

  const TypeSpecificSection({
    Key? key,
    required this.athlete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCurrent = athlete.status == AthleteStatus.current;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCurrent ? Icons.school : Icons.work,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isCurrent ? 'Academic Information' : 'Career Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Container with a card-like appearance
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: isCurrent 
                ? _buildCurrentAthleteInfo(context)
                : _buildFormerAthleteInfo(context),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCurrentAthleteInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context, 
          'Major', 
          athlete.major.displayName,
          Icons.book,
        ),
        const Divider(height: 24),
        _buildInfoRow(
          context, 
          'Expected Graduation', 
          _formatGraduationYear(),
          Icons.calendar_today,
        ),
        if (athlete.email.isNotEmpty) ...[
          const Divider(height: 24),
          _buildInfoRow(
            context, 
            'Contact Email', 
            athlete.email,
            Icons.email,
          ),
        ],
      ],
    );
  }
  
  Widget _buildFormerAthleteInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context, 
          'Career', 
          athlete.career.displayName,
          Icons.work,
        ),
        const Divider(height: 24),
        _buildInfoRow(
          context, 
          'Graduation Year', 
          _formatGraduationYear(),
          Icons.school,
        ),
        if (athlete.email.isNotEmpty) ...[
          const Divider(height: 24),
          _buildInfoRow(
            context, 
            'Contact Email', 
            athlete.email,
            Icons.email,
          ),
        ],
      ],
    );
  }
  
  // Helper method to format graduation year from the model
  String _formatGraduationYear() {
    if (athlete.graduationYear == null) return 'Not specified';
    return athlete.graduationYear!.year.toString();
  }
  
  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        SizedBox(
          width: 140,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
} 