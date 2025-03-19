import 'package:flutter/material.dart';
import 'package:esof/pages/map_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3E8E4D).withOpacity(0.9),
              Color(0xFF2E6E3D),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                // Logo and App Name
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.eco_rounded,
                        size: 72,
                        color: Colors.white,
                      ),
                      Text(
                        'EcoFinder',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Sustainable Shopping Guide',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                // Description Card
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'About EcoFinder',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E8E4D),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'EcoFinder helps you discover sustainable, fair-trade, and eco-friendly businesses. '
                            'Navigate through our interactive map, search for specific stores, and stay updated with the latest sustainability news.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Key Features:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E8E4D),
                        ),
                      ),
                      SizedBox(height: 8),
                      FeatureItem(icon: Icons.map, text: 'Interactive store map'),
                      FeatureItem(icon: Icons.search, text: 'Advanced search capabilities'),
                      FeatureItem(icon: Icons.list_alt, text: 'Filtered business listings'),
                      FeatureItem(icon: Icons.bookmark, text: 'Bookmark your favorites'),
                      FeatureItem(icon: Icons.newspaper, text: 'Sustainability news'),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                // Team Section
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Our Team',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E8E4D),
                        ),
                      ),
                      SizedBox(height: 20),
                      TeamMemberCard(
                        name: 'Arnaldo Ferraz Lopes',
                        email: 'up202307659@fe.up.pt',
                      ),
                      TeamMemberCard(
                        name: 'Diogo Sousa Campeão',
                        email: 'up202307177@fe.up.pt',
                      ),
                      TeamMemberCard(
                        name: 'José Pedro Marques Ferreira',
                        email: 'up202305478@fe.up.pt',
                      ),
                      TeamMemberCard(
                        name: 'Miguel Borges Pereira',
                        email: 'up202304387@fe.up.pt',
                      ),
                      TeamMemberCard(
                        name: 'Sérgio Miguel Cardoso Almeida',
                        email: 'up202305946@fe.up.pt',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40),

                // Big Button to Map
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapPage()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 28,
                          color: Color(0xFF3E8E4D),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'EXPLORE THE MAP',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E8E4D),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper Widget for Feature Items
class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureItem({
    required this.icon,
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Color(0xFF3E8E4D),
          ),
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Widget for Team Member Cards
class TeamMemberCard extends StatelessWidget {
  final String name;
  final String email;

  const TeamMemberCard({
    required this.name,
    required this.email,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFF3E8E4D).withOpacity(0.2),
            radius: 22,
            child: Text(
              name.substring(0, 1),
              style: TextStyle(
                color: Color(0xFF3E8E4D),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
