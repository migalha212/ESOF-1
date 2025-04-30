import 'package:eco_finder/features/map/model/eco_market.dart';
import 'package:flutter/material.dart';
import 'package:eco_finder/utils/navigation_items.dart';

class StoreBottomSheet extends StatelessWidget {
  final EcoMarket business;

  const StoreBottomSheet({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.45,
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
            Text(
              business.name,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  business.description ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),
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
