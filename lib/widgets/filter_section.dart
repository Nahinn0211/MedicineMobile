import 'package:flutter/material.dart';

class FilterSection extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final Function(String) onFilterSelected;
  final Function() onAdvancedFilterTap;

  const FilterSection({
    Key? key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.onAdvancedFilterTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Bộ lọc',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var filter in filters)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(filter),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildAdvancedFilterButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    return ChoiceChip(
      label: Text(filter),
      selected: selectedFilter == filter,
      selectedColor: Colors.blue.shade100,
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(
        color: selectedFilter == filter
            ? Colors.blue.shade800
            : Colors.grey.shade800,
        fontWeight: selectedFilter == filter
            ? FontWeight.bold
            : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selectedFilter == filter
              ? Colors.blue.shade300
              : Colors.transparent,
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          onFilterSelected(filter);
        }
      },
    );
  }

  Widget _buildAdvancedFilterButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: const Icon(Icons.filter_list, color: Colors.blue),
        tooltip: 'Bộ lọc nâng cao',
        onPressed: onAdvancedFilterTap,
      ),
    );
  }
}