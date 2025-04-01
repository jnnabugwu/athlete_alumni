import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_constants.dart';
import '../../domain/entities/athlete.dart';

class FeaturedAthletesWidget extends StatelessWidget {
  const FeaturedAthletesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data - will be replaced with actual data from Supabase later
    final List<Athlete> featuredAthletes = [
      Athlete(
        id: '1',
        name: 'Michael Johnson',
        profileImageUrl: 'assets/images/athletes/michael.jpg',
        university: 'Stanford University',
        sport: 'Track & Field',
        status: 'Former Athlete',
        position: 'Product Manager at Tech Company',
        location: 'San Francisco, CA',
        mentorConnections: 12,
      ),
      Athlete(
        id: '2',
        name: 'Sophia Williams',
        profileImageUrl: 'assets/images/athletes/sophia.jpg',
        university: 'UCLA',
        sport: 'Women\'s Basketball',
        status: 'Current Athlete',
        position: 'Business Administration Major',
        location: 'Los Angeles, CA',
        graduationYear: 2024,
      ),
      Athlete(
        id: '3',
        name: 'David Thompson',
        profileImageUrl: 'assets/images/athletes/david.jpg',
        university: 'Princeton',
        sport: 'Football',
        status: 'Former Athlete',
        position: 'Marketing Director at Sports Brand',
        location: 'New York, NY',
        mentorConnections: 17,
      ),
    ];

    // Responsive layout handling
    final screenWidth = MediaQuery.of(context).size.width;
    bool isNarrow = screenWidth < 800;

    if (isNarrow) {
      // Stack vertically on narrow screens
      return Column(
        children: featuredAthletes.map((athlete) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AthleteCard(athlete: athlete),
          );
        }).toList(),
      );
    } else {
      // Horizontal scrollable list for wider screens
      return SizedBox(
        height: 460, // Fixed height for scrollable container
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: featuredAthletes.length,
          itemBuilder: (context, index) {
            return SizedBox(
              width: 320,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: AthleteCard(athlete: featuredAthletes[index]),
              ),
            );
          },
        ),
      );
    }
  }
}

class AthleteCard extends StatelessWidget {
  final Athlete athlete;

  const AthleteCard({
    Key? key,
    required this.athlete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Generate a gradient color based on the athlete index
    List<List<Color>> gradients = [
      [Colors.blue.shade300, Colors.blue.shade900],
      [Colors.purple.shade300, Colors.purple.shade900],
      [Colors.amber.shade300, Colors.amber.shade900],
    ];
    
    int colorIndex = athlete.id.hashCode % gradients.length;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gradient header
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradients[colorIndex],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Profile image (positioned to overlap the gradient)
          Transform.translate(
            offset: const Offset(0, -40),
            child: Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 38,
                  backgroundImage: AssetImage(athlete.profileImageUrl),
                ),
              ),
            ),
          ),
          
          // Athlete info
          Transform.translate(
            offset: const Offset(0, -20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    athlete.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${athlete.university}, ${athlete.sport}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: athlete.status == 'Current Athlete' 
                          ? AppColors.currentAthleteBackground 
                          : AppColors.formerAthleteBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      athlete.status,
                      style: TextStyle(
                        color: athlete.status == 'Current Athlete' 
                            ? AppColors.currentAthleteText 
                            : AppColors.formerAthleteText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.work, athlete.position),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.location_on, athlete.location),
                  const SizedBox(height: 8),
                  athlete.graduationYear != null
                      ? _buildInfoRow(Icons.school, 'Graduation year: ${athlete.graduationYear}')
                      : _buildInfoRow(Icons.connect_without_contact, '${athlete.mentorConnections} mentoring connections'),
                  
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.message, size: 16),
                          label: const Text('Message'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Use direct string for now to avoid undefined reference
                            GoRouter.of(context).go('/athletes/${athlete.id}');
                          },
                          child: const Text('View Profile'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}