import 'package:eco_finder/features/map/presentation/pages/map_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_finder/common_widgets/navbar_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Importa o teu widget NavBar

class StoreProfilePage extends StatelessWidget {
  final DocumentReference storeRef;

  const StoreProfilePage({super.key, required this.storeRef});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: storeRef.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(color: Colors.green)),
            bottomNavigationBar: NavBar(
              selectedIndex: 0,
            ), // Adiciona a NavBar aqui
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: const Text(
                'Loja não encontrada',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: const Center(
              child: Text(
                'Loja não encontrada',
                style: TextStyle(color: Colors.green),
              ),
            ),
            bottomNavigationBar: const NavBar(
              selectedIndex: 0,
            ), // Adiciona a NavBar aqui
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final String storeName = data['name'] ?? '';

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(0xFF3E8E4D), // green color
            title: Text(
              storeName.isNotEmpty ? storeName : 'Loja',
              style: const TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, {
                  'latitude': data['latitude'], // Replace with actual latitude
                  'longitude':
                      data['longitude'], // Replace with actual longitude
                });
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data['imageUrl'] != null)
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 250.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(data['imageUrl']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16.0,
                        left: 16.0,
                        child: Text(
                          storeName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 3.0,
                                color: Colors.black87,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    height: 150.0,
                    color: Colors.green.shade700,
                    child: Center(
                      child: Text(
                        storeName.isNotEmpty ? storeName : 'Nome da Loja',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        Icons.category_outlined,
                        'Categoria',
                        data['primaryCategories']?.join(', '),
                      ),
                      _buildInfoRow(
                        Icons.description_outlined,
                        'Descrição',
                        data['description'],
                      ),
                      _buildInfoRow(
                        Icons.phone_outlined,
                        'Telefone',
                        data['contactPhone'],
                      ),
                      _buildInfoRow(
                        Icons.email_outlined,
                        'Email',
                        data['email'],
                      ),
                      _buildInfoRow(
                        Icons.language_outlined,
                        'Website',
                        data['website'],
                      ),
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        'Morada',
                        data['address'],
                        onTap: () {
                          if (data['latitude'] != null &&
                              data['longitude'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => MapPage(
                                      initialPosition: LatLng(
                                        data['latitude'],
                                        data['longitude'],
                                      ),
                                      initialZoom: 16.0, // Default zoom level
                                    ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Location data not available for this store.',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const NavBar(
            selectedIndex: 0,
          ), // Adiciona a NavBar aqui com selectedIndex 0
        );
      },
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String? value, {
    VoidCallback? onTap,
  }) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.green.shade700),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
