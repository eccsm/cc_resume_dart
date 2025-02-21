// lib/widgets/experience_card.dart

import 'package:flutter/material.dart';

class ExperienceCard extends StatelessWidget {
  final String title;
  final String role;
  final String location;
  final List<String> points;
  final List<String>? notableProjects; // Optional

  const ExperienceCard({
    super.key,
    required this.title,
    required this.role,
    required this.location,
    required this.points,
    this.notableProjects,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamically adjust icon size based on screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double bulletSize = screenWidth > 1200
        ? 14
        : screenWidth > 800
            ? 12
            : 10;

    return Card(
      color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Title
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            // Role and Location
            Text(
              '$role | $location',
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 8),
            // Responsibilities
            ...points.map(
              (point) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.brightness_1,
                    size: bulletSize,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            // Notable Projects
            if (notableProjects != null && notableProjects!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Notable Projects:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ...notableProjects!.map(
                (project) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: bulletSize,
                      color: Colors.indigo,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        project,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
