import 'package:eco_finder/features/events/model/event.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eco_finder/utils/navigation_items.dart';
import 'package:intl/intl.dart';

class EventBottomSheet extends StatelessWidget {
  final Event event;

  const EventBottomSheet({super.key, required this.event});

  Widget _buildInfoRow(
      IconData icon,
      String label,
      String? value,
      ) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                  value,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow(
      IconData icon,
      String label,
      String? url,
      BuildContext context,
      ) {
    if (url == null || url.isEmpty) return const SizedBox.shrink();
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
                    content: Text('Não foi possível abrir o link.'),
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
                    url,
                    style: const TextStyle(fontSize: 14, color: Colors.blue, decoration: TextDecoration.underline),
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
    final startDate = DateTime.tryParse(event.startDate);
    final endDate = DateTime.tryParse(event.endDate);
    final formattedStartDate = startDate != null ? DateFormat('dd/MM/yyyy').format(startDate) : 'N/A';
    final formattedEndDate = endDate != null ? DateFormat('dd/MM/yyyy').format(endDate) : 'N/A';

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
                        event.name,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (event.description.isNotEmpty)
                      Text(
                        event.description,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 16),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.calendar_today_outlined, 'Início', formattedStartDate),
                    _buildInfoRow(Icons.event_outlined, 'Fim', formattedEndDate),
                    GestureDetector(
                      onTap: () {
                        final address = Uri.encodeComponent(event.address);
                        final url = 'https://www.google.com/maps/search/?api=1&query=$address';
                        launchUrl(Uri.parse(url));
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF3E8E4D)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              event.address,
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (event.website != null && event.website!.isNotEmpty)
                      _buildLinkRow(
                        Icons.language_outlined,
                        'Link',
                        event.website,
                        context,
                      ),
                    if (event.hostShop.isNotEmpty)
                      _buildInfoRow(Icons.store_outlined, 'Organizador', event.hostShop),
                  ],
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                print('Navigate to event profile for ID: ${event.id}');
                Navigator.pushNamed(
                  context,
                  NavigationItems.navEventProfile.route,
                  arguments: event.id,
                );
              },
              icon: const Icon(Icons.event, size: 20),
              label: const Text(
                'Ver página do evento',
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