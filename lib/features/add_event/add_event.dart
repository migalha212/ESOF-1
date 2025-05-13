import 'package:eco_finder/utils/navigation_items.dart';
import 'package:flutter/material.dart';
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

  final Map<String, String> _primaryCategories = {
    'Workshops': '🛠️',
    'Feiras': '🎪',
    'Palestras': '🗣️',
    'Exposições': '🖼️',
    'Atividades ao ar livre': '🌳',
    'Música': '🎶',
    'Teatro': '🎭',
    'Cinema': '🎬',
    'Infantil': '🧸',
    'Outros': '🏷️',
  };

  String? _selectedPrimaryCategory;

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          controller.text = DateFormat('yyyy-MM-dd HH:mm').format(DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          ));
        });
      }
    }
  }

  void _submitEvent() async {
    if (_formKey.currentState!.validate() && _selectedPrimaryCategory != null) {
      SustainableEvent event = SustainableEvent(
        id: '',
        name: _nameController.text,
        description: _descriptionController.text,
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        primaryCategory: _selectedPrimaryCategory!,
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
        const SnackBar(content: Text('Selecione uma categoria primária e preencha todos os campos obrigatórios')),
      );
    }
  }

  Widget _buildImagePreview() {
    if (_imageUrlController.text.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pré-visualização da imagem:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.network(
              _imageUrlController.text,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 40),
                      SizedBox(height: 8),
                      Text('Erro ao carregar imagem',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xFF3E8E4D),
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
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
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),
              _buildImagePreview(),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Categoria Principal',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined, color: Color(0xFF3E8E4D)),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedPrimaryCategory,
                  items: _primaryCategories.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text('${entry.value} ${entry.key}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPrimaryCategory = value;
                    });
                  },
                  validator: (value) => value == null ? 'Selecione uma categoria' : null,
                ),
              ),
              const SizedBox(height: 16),
              LocationPicker(
                latitudeController: _latitudeController,
                longitudeController: _longitudeController,
                addressController: _addressController,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  labelText: 'Website do Evento (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.language_outlined, color: Color(0xFF3E8E4D)),
                  hintText: 'https://exemplo.com/evento',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hostShopController,
                decoration: const InputDecoration(
                  labelText: 'Organizador/Loja',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store_outlined, color: Color(0xFF3E8E4D)),
                ),
                validator: (value) =>
                (value == null || value.isEmpty)
                    ? 'Por favor, insira o organizador/loja'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Data e Hora de Início',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event_outlined, color: Color(0xFF3E8E4D)),
                ),
                onTap: () => _selectDate(context, _startDateController),
                validator: (value) =>
                (value == null || value.isEmpty)
                    ? 'Por favor, selecione a data e hora de início'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _endDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Data e Hora de Fim',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event_outlined, color: Color(0xFF3E8E4D)),
                ),
                onTap: () => _selectDate(context, _endDateController),
                validator: (value) =>
                (value == null || value.isEmpty)
                    ? 'Por favor, selecione a data e hora de fim'
                    : null,
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
}

class SustainableEvent {
  String id;
  String name;
  String description;
  double latitude;
  double longitude;
  String primaryCategory;
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
    required this.primaryCategory,
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
      'primaryCategory': primaryCategory,
      'address': address,
      'website': website,
      'imageUrl': imageUrl,
      'hostShop': hostShop,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}