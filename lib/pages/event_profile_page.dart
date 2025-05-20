import 'package:eco_finder/features/bookmarks/presentation/widgets/bookmark_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_finder/common_widgets/navbar_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EventProfilePage extends StatelessWidget {
  final DocumentReference eventRef;

  const EventProfilePage({Key? key, required this.eventRef}) : super(key: key);

  Future<void> _shareEventDetails(BuildContext context, Map<String, dynamic> data, String eventName) async {
    String shareText = '$eventName\n\n';
    if (data['description'] != null && data['description'].isNotEmpty) {
      shareText += 'Descrição: ${data['description']}\n';
    }
    if (data['hostShop'] != null && data['hostShop'].isNotEmpty) {
      shareText += 'Organizador: ${data['hostShop']}\n';
    }
    if (data['startDate'] != null && data['startDate'].isNotEmpty) {
      shareText += 'Data de Início: ${data['startDate']}\n';
    }
    if (data['endDate'] != null && data['endDate'].isNotEmpty) {
      shareText += 'Data de Fim: ${data['endDate']}\n';
    }
    if (data['website'] != null && data['website'].isNotEmpty) {
      shareText += 'Website: ${data['website']}\n';
    }
    if (data['address'] != null && data['address'].isNotEmpty) {
      shareText += 'Morada: ${data['address']}\n';
    }

    try {
      await Share.share(shareText);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível partilhar os detalhes do evento.')),
      );
      debugPrint('Erro ao partilhar: $e');
    }
  }

  Widget _buildCategoryTile(String category, Map<String, dynamic> categoryData) {
    String emoji = categoryData['emoji'] ?? '';
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 24)),
      title: Text(category),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: eventRef.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(color: Colors.green)),
            bottomNavigationBar: NavBar(selectedIndex: 1), // Assuming events are on a different nav item
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: const Text('Evento não encontrado', style: TextStyle(color: Colors.white)),
            ),
            body: const Center(
              child: Text('Evento não encontrado', style: TextStyle(color: Colors.green)),
            ),
            bottomNavigationBar: const NavBar(selectedIndex: 1),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final String eventName = data['name'] ?? '';
        final Map<String, Map<String, dynamic>> primaryCategoriesData = {
          'Alimentos': {'emoji': '🍏', 'subcategories': ['Orgânicos', 'Vegan', 'Biológicos']},
          'Roupas': {'emoji': '👗', 'subcategories': ['Reciclada', 'Eco-Friendly', 'Segunda Mão']},
          'Itens Colecionáveis': {'emoji': '🎁', 'subcategories': ['Vintage', 'Edição Limitada', 'Antiguidades']},
          'Decoração': {'emoji': '🏡', 'subcategories': ['Móveis', 'Iluminação', 'Arte']},
          'Eletrónicos': {'emoji': '📱', 'subcategories': ['Smartphones', 'Computadores', 'Acessórios']},
          'Brinquedos': {'emoji': '🧸', 'subcategories': ['Artesanais', 'Segunda Mão', 'Reciclados']},
          'Saúde & Beleza': {'emoji': '💄', 'subcategories': ['Cosméticos', 'Cuidados Pessoais', 'Fitness']},
          'Artesanato': {'emoji': '🧵', 'subcategories': ['Feito à mão', 'Reciclado', 'Regional']},
          'Livros': {'emoji': '📚', 'subcategories': ['Romance', 'Segunda Mão', 'Infantis']},
          'Desportos & Lazer': {'emoji': '⚽', 'subcategories': ['Ginasio', 'Ao ar livre', 'Indoor']},
        };

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.green,
            title: Text(eventName.isNotEmpty ? eventName : 'Evento', style: const TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareEventDetails(context, data, eventName),
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
                          eventName,
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
                        eventName.isNotEmpty ? eventName : 'Nome do Evento',
                        style: const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data['primaryCategories'] != null && data['primaryCategories'].isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Categorias:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...data['primaryCategories'].map((category) {
                              return _buildCategoryTile(category, primaryCategoriesData[category] ?? {});
                            }).toList(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      _buildInfoRow(Icons.description_outlined, 'Descrição', data['description']),
                      _buildInfoRow(Icons.store_outlined, 'Organizador', data['hostShop']),
                      _buildInfoRow(
                        Icons.calendar_today_outlined,
                        'Data de Início',
                        data['startDate'],
                      ),
                      _buildInfoRow(
                        Icons.event_outlined,
                        'Data de Fim',
                        data['endDate'],
                      ),
                      _buildInfoRow(
                        Icons.language_outlined,
                        'Website',
                        data['website'],
                        onTap: () async {
                          String? url = data['website'];
                          if (url != null && url.isNotEmpty) {
                            if (!url.startsWith('http://') && !url.startsWith('https://')) {
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
                                  const SnackBar(content: Text('Não foi possível abrir o link do website.')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ocorreu um erro ao abrir o link.')),
                              );
                            }
                          }
                        },
                      ),
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        'Morada',
                        data['address'],
                        onTap: () async {
                          if (data['address'] != null && data['address'].isNotEmpty) {
                            final Uri uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(data['address'])}');
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Não foi possível abrir o mapa.')),
                              );
                            }
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
            selectedIndex: 1, // Assuming events are on index 1 in your navbar
          ),
          // No bookmark button for events in this example, adjust as needed
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value, {VoidCallback? onTap}) {
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4.0),
                  Text(value, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}