import 'package:eco_finder/features/events/model/event.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EventBottomSheet extends StatelessWidget {
  final Event event;

  const EventBottomSheet({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (event.imageUrl != null &&
                event.imageUrl!.isNotEmpty &&
                event.imageUrl!.startsWith('http'))
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    event.imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                event.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(event.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF3E8E4D)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    event.address,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.store, color: Color(0xFF3E8E4D)),
                const SizedBox(width: 6),
                Text(event.hostShop, style: const TextStyle(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF3E8E4D)),
                const SizedBox(width: 6),
                Text(
                  'De ${event.startDate} até ${event.endDate}',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            // Show website link if present
            if (event.website != null && event.website!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.link, color: Color(0xFF3E8E4D)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final url =
                              event.website!.startsWith('http')
                                  ? event.website!
                                  : 'https://${event.website!}';
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Não foi possível abrir o link.'),
                              ),
                            );
                          }
                        },
                        child: Text(
                          event.website!,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
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
