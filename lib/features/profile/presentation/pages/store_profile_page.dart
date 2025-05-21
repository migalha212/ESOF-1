import 'package:eco_finder/features/bookmarks/presentation/widgets/bookmark_button.dart';
import 'package:eco_finder/utils/navigation_items.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_finder/common_widgets/navbar_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart'; // Ensure this import is here

class StoreProfilePage extends StatelessWidget {
  final DocumentReference storeRef;

  const StoreProfilePage({Key? key, required this.storeRef}) : super(key: key);

  Future<void> _shareStoreDetails(
    BuildContext context,
    Map<String, dynamic> data,
    String storeName,
  ) async {
    String shareText = '$storeName\n\n';
    if (data['description'] != null && data['description'].isNotEmpty) {
      shareText += 'Description: ${data['description']}\n';
    }
    if (data['contactPhone'] != null && data['contactPhone'].isNotEmpty) {
      shareText += 'Contact: ${data['contactPhone']}\n';
    }
    if (data['website'] != null && data['website'].isNotEmpty) {
      shareText += 'Website: ${data['website']}\n';
    }
    if (data['address'] != null && data['address'].isNotEmpty) {
      shareText += 'Address: ${data['address']}\n';
    }

    try {
      await Share.share(shareText);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error sharing shop details.')),
      );
      debugPrint('Error when sharing: $e');
    }
  }

  Widget _buildCategoryTile(
    String category,
    Map<String, dynamic> categoryData,
  ) {
    String emoji = categoryData['emoji'] ?? '';
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 24)),
      title: Text(category),
    );
  }

  Widget _buildCertificationTile(String cert) {
    return ListTile(
      leading: const Icon(Icons.check_circle_outline, color: Colors.green),
      title: Text(cert),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: storeRef.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(color: Colors.green)),
            bottomNavigationBar: NavBar(selectedIndex: 0),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: const Color(0xFF3E8E4D),
              title: const Text(
                'Store not found',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: const Center(
              child: Text(
                'Store not found',
                style: TextStyle(color: Colors.green),
              ),
            ),
            bottomNavigationBar: const NavBar(selectedIndex: 0),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final String storeName = data['name'] ?? '';
        final Map<String, Map<String, dynamic>> primaryCategoriesData = {
          'Food': {
            'emoji': '🍏',
            'subcategories': ['Organic', 'Vegan', 'Biological'],
          },
          'Clothes': {
            'emoji': '👗',
            'subcategories': ['Recycled', 'Eco-Friendly', 'Second-Hand'],
          },
          'Collectibles': {
            'emoji': '🎁',
            'subcategories': ['Vintage', 'Limited edition', 'Antiques'],
          },
          'Decoration': {
            'emoji': '🏡',
            'subcategories': ['Furniture', 'Lighting', 'Art'],
          },
          'Eletronics': {
            'emoji': '📱',
            'subcategories': ['Smartphones', 'Computers', 'Accessories'],
          },
          'Toys': {
            'emoji': '🧸',
            'subcategories': ['Artisan', 'Second-Hand', 'Recycled'],
          },
          'Beauty and Hygiene': {
            'emoji': '💄',
            'subcategories': ['Cosmetics', 'Personal care', 'Fitness'],
          },
          'Artisanship': {
            'emoji': '🧵',
            'subcategories': ['Handmade', 'Recycled', 'Regional'],
          },
          'Books': {
            'emoji': '📚',
            'subcategories': ['Romance', 'Second-Hand', "Children's"],
          },
          'Sports and Leisure': {
            'emoji': '⚽',
            'subcategories': ['Gym', 'Outdoors', 'Indoor'],
          },
        };

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(0xFF3E8E4D),
            title: Text(
              storeName.isNotEmpty ? storeName : 'Shop',
              style: const TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareStoreDetails(context, data, storeName),
              ),
            ],
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
                        storeName.isNotEmpty ? storeName : 'Shop Name',
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
                      if (data['primaryCategories'] != null &&
                          data['primaryCategories'].isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Primary Categories:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...data['primaryCategories'].map((category) {
                              return _buildCategoryTile(
                                category,
                                primaryCategoriesData[category] ?? {},
                              );
                            }).toList(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      _buildInfoRow(
                        Icons.description_outlined,
                        'Description',
                        data['description'],
                      ),
                      _buildPhoneRow(
                        Icons.phone_outlined,
                        'Contact Phone',
                        data['contactPhone'],
                        context,
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
                        onTap: () async {
                          String? url = data['website'];
                          if (url != null && url.isNotEmpty) {
                            if (!url.startsWith('http://') &&
                                !url.startsWith('https://')) {
                              url = 'https://$url';
                            }
                            final Uri uri = Uri.parse(url);
                            try {
                              final bool launched = await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                              if (!launched) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Unable to open website URL.',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Erro opening Website URL.'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        'Address',
                        data['address'],
                        onTap: () async {
                          if (data['address'] != null &&
                              data['address'].isNotEmpty) {
                            final Uri uri = Uri.parse(
                              'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(data['address'])}',
                            );
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error opening Map.'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      if (data['certifications'] != null &&
                          data['certifications'].isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                              'Certificates / Awards:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...data['certifications']
                                .map((cert) => _buildCertificationTile(cert))
                                .toList(),
                          ],
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const NavBar(selectedIndex: 0),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    NavigationItems.navProfile.route,
                    arguments: data['uid'],
                  );
                },
                backgroundColor: const Color(0xFF3E8E4D),
                tooltip: "View Owner Profile",
                child: const Icon(Icons.person, color: Colors.white),
              ),
              SizedBox(height: 8),
              BookmarkButton(shopId: storeRef.id, shopReference: storeRef),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
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

  Widget _buildPhoneRow(
    IconData icon,
    String label,
    String? value,
    BuildContext context,
  ) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    final cleanedNumber = value.replaceAll(' ', '');

    return Padding(
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
                  ),
                ),
                const SizedBox(height: 4.0),
                SelectableText(
                  cleanedNumber,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: cleanedNumber));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Number Copied!')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
