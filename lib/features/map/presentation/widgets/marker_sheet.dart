import 'package:eco_finder/features/map/model/eco_market.dart';
import 'package:flutter/material.dart';
import 'package:eco_finder/utils/navigation_items.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreBottomSheet extends StatelessWidget {
  final EcoMarket business;

  const StoreBottomSheet({super.key, required this.business});

  Widget _buildWebsiteRow(
    IconData icon,
    String label,
    String? value,
    BuildContext context,
  ) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    String? url = value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () async {
          if (url != null) {
            String processedUrl = url;
            if (!processedUrl.startsWith('http://') &&
                !processedUrl.startsWith('https://')) {
              processedUrl = 'https://$processedUrl';
            }
            final Uri uri = Uri.parse(processedUrl);
            try {
              final bool launched = await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
              if (!launched) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Não foi possível abrir o link do website.'),
                  ),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ocorreu um erro ao abrir o link.'),
                ),
              );
            }
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF3E8E4D)),
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
                    value!,
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

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.45,
      widthFactor: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        business.name,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (business.description != null)
                      Text(
                        business.description!,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 16),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 10),
                    if (business.address != null)
                      GestureDetector(
                        onTap: () {
                          final address = Uri.encodeComponent(business.address!);
                          final url =
                              'https://www.google.com/maps/search/?api=1&query=$address';
                          launchUrl(Uri.parse(url));
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, color: Color(0xFF3E8E4D)),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                business.address!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),
                    if (business.website != null)
                      _buildWebsiteRow(
                        Icons.language_outlined,
                        'Website',
                        business.website,
                        context,
                      ),
                  ],
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  NavigationItems.navMapProfile.route,
                  arguments: business.reference,
                );
              },
              icon: const Icon(Icons.store, size: 20),
              label: const Text(
                'Ver página da loja',
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E8E4D),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
