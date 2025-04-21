import 'package:eco_finder/pages/navigation_items.dart';
import 'package:flutter/material.dart';

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
              Color(0xFF3E8E4D).withValues(alpha: 0.9),
              Color(0xFF2E6E3D),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            // Adicionado para os Positioned widgets
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),

                    // Logo e Nome do App
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
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
                              color: Colors.white.withValues(alpha: 0.9),
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // Descrição do Projeto
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
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
                          FeatureItem(
                            icon: Icons.map,
                            text: 'Interactive store map',
                          ),
                          FeatureItem(
                            icon: Icons.search,
                            text: 'Advanced search capabilities',
                          ),
                          FeatureItem(
                            icon: Icons.list_alt,
                            text: 'Filtered business listings',
                          ),
                          FeatureItem(
                            icon: Icons.bookmark,
                            text: 'Bookmark your favorites',
                          ),
                          FeatureItem(
                            icon: Icons.newspaper,
                            text: 'Sustainability news',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // Seção da Equipe
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
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

                    SizedBox(height: 100),
                    // Espaço extra para os botões flutuantes
                  ],
                ),
              ),

              // Botões flutuantes
              Positioned(
                bottom: 80,
                right: 16,
                child: FloatingActionButton.extended(
                  heroTag: null,
                  onPressed: () {
                    print('Add Business button pressed');
                    Navigator.pushNamed(
                      context,
                      NavigationItems.navAddBusiness.route,
                    );
                  },
                  backgroundColor: Color(0xFF3E8E4D),
                  icon: Icon(Icons.add),
                  label: Text('Add Business'),
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton.extended(
                  heroTag: null,
                  onPressed: () {
                    Navigator.pushNamed(context, NavigationItems.navMap.route);
                  },
                  backgroundColor: Colors.white,
                  icon: Icon(Icons.map, color: Color(0xFF3E8E4D)),
                  label: Text(
                    'Explore Map',
                    style: TextStyle(color: Color(0xFF3E8E4D)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureItem({required this.icon, required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Color(0xFF3E8E4D)),
          SizedBox(width: 10),
          Text(text, style: TextStyle(fontSize: 15, color: Colors.black87)),
        ],
      ),
    );
  }
}

// Helper Widget for Team Member Cards
class TeamMemberCard extends StatelessWidget {
  final String name;
  final String email;

  const TeamMemberCard({required this.name, required this.email, super.key});

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
            backgroundColor: Color(0xFF3E8E4D).withValues(alpha: 0.2),
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 3),
                Text(
                  email,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
