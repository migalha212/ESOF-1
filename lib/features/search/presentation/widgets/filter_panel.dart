import 'package:flutter/material.dart';

class FilterPanel extends StatelessWidget{
  final Map<String, String> categories;
  final List<String> selectedCategories;
  final void Function(String category, bool isSelected) onCategoryToggle;
  final VoidCallback onApply;
  final bool isExpanded;
  final ScrollController scrollController;

  const FilterPanel({
    super.key,
    required this.categories,
    required this.selectedCategories,
    required this.onCategoryToggle,
    required this.onApply,
    required this.isExpanded,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isExpanded ? 300 : 0,
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        scrollbarOrientation: ScrollbarOrientation.left,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              ...categories.entries.map((entry) {
                final bool selected = selectedCategories.contains(entry.key);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: Text('${entry.value} ${entry.key}'),
                  trailing: Icon(
                    selected ? Icons.check_box : Icons.check_box_outline_blank,
                    color: selected ? Colors.green : null,
                  ),
                  onTap: () => onCategoryToggle(entry.key, selected),
                );
              }),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E8E4D),
                ),
                child: const Text('Apply'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}