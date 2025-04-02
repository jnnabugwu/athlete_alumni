import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/athlete.dart';

/// A card widget that displays athlete information
class AthleteCard extends StatelessWidget {
  /// The athlete to display
  final Athlete athlete;
  
  /// Whether to display a compact version of the card
  final bool isCompact;
  
  /// Callback for when the card is tapped
  final Function()? onTap;
  
  /// Whether the card is in development mode
  final bool isDevMode;

  /// Constructor
  const AthleteCard({
    Key? key,
    required this.athlete,
    this.isCompact = false,
    this.onTap,
    this.isDevMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap ?? () {
          // Navigate to athlete details screen
          if (isDevMode) {
            context.go('/athlete/${athlete.id}', extra: {'devBypass': true});
          } else {
            context.go('/athlete/${athlete.id}');
          }
        },
        child: isCompact ? _buildCompactCard(context) : _buildFullCard(context),
      ),
    );
  }

  /// Builds a compact version of the card
  Widget _buildCompactCard(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildProfileImage(height: 80, width: 80),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  athlete.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (athlete.university != null) ...[
                  Text(
                    athlete.university!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                ],
                Row(
                  children: [
                    _buildStatusBadge(context),
                    if (athlete.sport != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          athlete.sport!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  /// Builds the full version of the card
  Widget _buildFullCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileImage(height: 180, width: double.infinity),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      athlete.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(context),
                ],
              ),
              const SizedBox(height: 8),
              if (athlete.university != null) ...[
                Text(
                  athlete.university!,
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
              ],
              if (athlete.sport != null) ...[
                Text(
                  athlete.sport!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              const Divider(),
              const SizedBox(height: 8),
              _buildInfoRow(
                context, 
                'Major', 
                athlete.major.displayName,
              ),
              const SizedBox(height: 4),
              _buildInfoRow(
                context, 
                'Career', 
                athlete.career.displayName,
              ),
              if (athlete.graduationYear != null) ...[
                const SizedBox(height: 4),
                _buildInfoRow(
                  context, 
                  'Class of', 
                  athlete.graduationYear!.year.toString(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the profile image
  Widget _buildProfileImage({required double height, required double width}) {
    return SizedBox(
      height: height,
      width: width,
      child: athlete.profileImageUrl != null
          ? Image.network(
              athlete.profileImageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.person, size: 50),
                );
              },
            )
          : const Center(
              child: Icon(Icons.person, size: 50),
            ),
    );
  }

  /// Builds a row with label and value
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Builds a status badge
  Widget _buildStatusBadge(BuildContext context) {
    final Color backgroundColor = athlete.status == AthleteStatus.current
        ? Colors.green.shade100
        : Colors.orange.shade100;
    final Color textColor = athlete.status == AthleteStatus.current
        ? Colors.green.shade800
        : Colors.orange.shade800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        athlete.status.displayName,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} 