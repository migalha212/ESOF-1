import 'package:flutter/material.dart';
import 'package:eco_finder/utils/navigation_items.dart';
import 'package:eco_finder/features/add_business/location_picker_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<void> addEvent(SustainableEvent event) async {
    try {
      await _db.collection('events').add(event.toMap());
    } catch (e) {
      throw Exception('Erro ao adicionar evento: $e');
    }
  }

  Future<List<String>> getShopNames(String query) async {
    final snapshot = await _db
        .collection('businesses')
        .where('name_lowercase', isGreaterThanOrEqualTo: query.toLowerCase())
        .where('name_lowercase', isLessThan: query.toLowerCase() + 'z' * 10)
        .get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final EventService _eventService = EventService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _hostShopController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  final Map<String, Map<String, dynamic>> _primaryCategories = {
    'Workshops': {'emoji': '🛠️', 'subcategories': []},
    'Feiras': {'emoji': '🎪', 'subcategories': []},
    'Palestras': {'emoji': '🗣️', 'subcategories': []},
    'Exposições': {'emoji': '🖼️', 'subcategories': []},
    'Atividades ao ar livre': {'emoji': '🌳', 'subcategories': []},
    'Música': {'emoji': '🎶', 'subcategories': []},
    'Teatro': {'emoji': '🎭', 'subcategories': []},
    'Cinema': {'emoji': '🎬', 'subcategories': []},
    'Infantil': {'emoji': '🧸', 'subcategories': []},
    'Outros': {'emoji': '🏷️', 'subcategories': []},
  };

  final List<String> _selectedPrimaryCategories = [];
  final Map<String, List<String>> _selectedSubcategories = {};
  List<String> _filteredShopNames = [];
  bool _showSuggestions = false;

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _submitEvent() async {
    if (_formKey.currentState!.validate() && _selectedPrimaryCategories.isNotEmpty) {
      List<String> primaries = List.from(_selectedPrimaryCategories);
      Map<String, dynamic> subs = {};
      _selectedSubcategories.forEach((k, v) => subs[k] = v);

      SustainableEvent event = SustainableEvent(
        id: '',
        name: _nameController.text,
        description: _descriptionController.text,
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        primaryCategories: primaries,
        subcategories: subs,
        address: _addressController.text,
        website: _websiteController.text,
        imageUrl: _imageUrlController.text,
        hostShop: _hostShopController.text,
        startDate: _startDateController.text,
        endDate: _endDateController.text,
      );
      try {
        await _eventService.addEvent(event);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento adicionado com sucesso!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao adicionar evento: $e')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos uma categoria primária e preencha todos os campos obrigatórios')),
      );
    }
  }

  void _filterShops(String query) async {
    if (query.isNotEmpty) {
      final shops = await _eventService.getShopNames(query);
      setState(() {
        _filteredShopNames = shops;
        _showSuggestions = true;
      });
    } else {
      setState(() {
        _filteredShopNames = [];
        _showSuggestions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Evento Sustentável'),
        backgroundColor: const Color(0xFF3E8E4D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, NavigationItems.navMap.route);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Evento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                (value == null || value.isEmpty)
                    ? 'Por favor, insira o nome do evento'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                (value == null || value.isEmpty)
                    ? 'Por favor, insira uma descrição'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'URL da Imagem do Evento',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.image, color: Color(0xFF3E8E4D)),
                  hintText: 'https://exemplo.com/imagem_evento.jpg',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _imageUrlController.clear();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Categorias Primárias (Max. 3)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ..._primaryCategories.entries.map(
                    (entry) => _buildPrimaryCategoryTile(entry.key, entry.value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Data de Início',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today_outlined, color: Color(0xFF3E8E4D)),
                ),
                onTap: () => _selectDate(context, _startDateController),
                validator: (value) =>
                (value == null || value.isEmpty)
                    ? 'Por favor, selecione a data de início'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _endDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Data de Fim',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today_outlined, color: Color(0xFF3E8E4D)),
                ),
                onTap: () => _selectDate(context, _endDateController),
                validator: (value) =>
                (value == null || value.isEmpty)
                    ? 'Por favor, selecione a data de fim'
                    : null,
              ),
              const SizedBox(height: 16),
              LocationPicker(
                latitudeController: _latitudeController,
                longitudeController: _longitudeController,
                addressController: _addressController,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hostShopController,
                decoration: const InputDecoration(
                  labelText: 'Organizador/Loja',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store_outlined, color: Color(0xFF3E8E4D)),
                ),
                onChanged: _filterShops,
                validator: (value) =>
                value == null || value.isEmpty ? 'Por favor, insira o organizador/loja' : null,
              ),
              if (_showSuggestions && _filteredShopNames.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  margin: const EdgeInsets.only(top: 2),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredShopNames.length,
                    itemBuilder: (context, index) {
                      final shopName = _filteredShopNames[index];
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _hostShopController.text = shopName;
                            _showSuggestions = false;
                            _filteredShopNames = [];
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Text(shopName),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  labelText: 'Link para o Evento (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link_outlined, color: Color(0xFF3E8E4D)),
                  hintText: 'https://exemplo.com/evento',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E8E4D),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 8,
                ),
                child: const Text(
                  'Adicionar Evento',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryCategoryTile(String category, Map<String, dynamic> data) {
    bool selected = _selectedPrimaryCategories.contains(category);
    return Card(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: ExpansionTile(
          key: PageStorageKey(category),
          initiallyExpanded: selected,
          title: Row(
            children: [
              Text('${data['emoji']} $category'),
              const Spacer(),
              InkWell(
                onTap: () {
                  setState(() {
                    if (selected) {
                      _selectedPrimaryCategories.remove(category);
                      _selectedSubcategories.remove(category);
                    } else {
                      if (_selectedPrimaryCategories.length < 3) {
                        _selectedPrimaryCategories.add(category);
                        _selectedSubcategories[category] = [];
                      }
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.rectangle,
                  ),
                  child: Icon(
                    selected ? Icons.check_box : Icons.check_box_outline_blank,
                    color: selected ? Colors.green : null,
                  ),
                ),
              ),
            ],
          ),
          onExpansionChanged: (expanded) {
            if (expanded && !selected) {
              if (_selectedPrimaryCategories.length < 3) {
                setState(() {
                  _selectedPrimaryCategories.add(category);
                  _selectedSubcategories[category] = [];
                });
              }
            }
          },
          children: [
            Wrap(
              spacing: 8,
              children: List<String>.from(data['subcategories']).map((sub) {
                bool subSelected = _selectedSubcategories[category]?.contains(sub) ?? false;
                return ChoiceChip(
                  label: Text(sub),
                  selected: subSelected,
                  onSelected: (bool sel) {
                    setState(() {
                      if (sel) {
                        _selectedSubcategories[category] ??= [];
                        _selectedSubcategories[category]!.add(sub);
                      } else {
                        _selectedSubcategories[category]?.remove(sub);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _selectedPrimaryCategories.remove(category);
                    _selectedSubcategories.remove(category);
                  });
                },
                child: const Text('Desselecionar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SustainableEvent {
  String id;
  String name;
  String description;
  double latitude;
  double longitude;
  List<String> primaryCategories;
  Map<String, dynamic> subcategories;
  String address;
  String? website;
  String? imageUrl;
  String hostShop;
  String startDate;
  String endDate;

  SustainableEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.primaryCategories,
    required this.subcategories,
    required this.address,
    this.website,
    this.imageUrl,
    required this.hostShop,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'name_lowercase': name.toLowerCase(),
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'primaryCategories': primaryCategories,
      'subcategories': subcategories,
      'address': address,
      'website': website,
      'imageUrl': imageUrl,
      'hostShop': hostShop,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}