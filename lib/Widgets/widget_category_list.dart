import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Models/FastKey/category_model.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  // Scroll controller to manage horizontal scrolling
  final ScrollController _scrollController = ScrollController();
  // Flags to show left and right scroll arrows
  bool _showLeftArrow = false;
  bool _showRightArrow = true;
  // Track selected item index
  int _selectedIndex = -1;

  // Ex: List of category data
  final List<CategoryModel> categories = [
    CategoryModel(name: 'Pickles1', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
    CategoryModel(name: 'Alcohol2', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
    CategoryModel(name: 'Juice3', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
    CategoryModel(name: 'Drinks4', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
    CategoryModel(name: 'Bread5', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
    CategoryModel(name: 'Coffee6', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
    CategoryModel(name: 'Category7', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
    CategoryModel(name: 'Pickles1', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
    CategoryModel(name: 'Alcohol2', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
    CategoryModel(name: 'Juice3', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
    CategoryModel(name: 'Drinks4', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
    CategoryModel(name: 'Bread5', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
    CategoryModel(name: 'Coffee6', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
    CategoryModel(name: 'Category7', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
  ];

  @override
  void initState() {
    super.initState();
    // Add listener to scroll controller for dynamic arrow visibility
    _scrollController.addListener(() {
      setState(() {
        // Show the left arrow if scrolling has occurred to the left
        _showLeftArrow = _scrollController.offset > 0;
        // Show the right arrow if we haven't reached the end of the list
        _showRightArrow = _scrollController.offset < _scrollController.position.maxScrollExtent;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size; // Get screen size
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Show left scroll button if needed
          if (_showLeftArrow)
            _buildScrollButton(Icons.arrow_back_ios, () {
              // Scroll left
              _scrollController.animateTo(
                _scrollController.offset - size.width,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }),
          Expanded(
            child: Container(
              height: 110, // Set height of the category list
              child: ListView.builder(
                controller: _scrollController, // Set scroll controller
                scrollDirection: Axis.horizontal, // Horizontal scrolling
                itemCount: categories.length, // Number of categories
                itemBuilder: (context, index) {
                  final category = categories[index];
                  bool isSelected = _selectedIndex == index; // Check if item is selected

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = isSelected ? -1 : index; // Toggle selection
                      });
                      // Print selected category for debugging
                      if (kDebugMode) {
                        print('Selected Category: ${category.name}');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.red : Colors.white, // Change color when selected
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Display category image
                            SvgPicture.asset(
                              category.imageAsset,
                              height: 40,
                              width: 40,
                            ),
                            const SizedBox(height: 8),
                            // Display category name
                            Text(
                              category.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            // Display item count
                            Text(
                              category.itemCount,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Show right scroll button if needed
          if (_showRightArrow)
            _buildScrollButton(Icons.arrow_forward_ios, () {
              // Scroll right
              _scrollController.animateTo(
                _scrollController.offset + size.width,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }),

           const SizedBox(width: 8),

          _buildScrollButton(Icons.add, (){ //Build #1.0.2 : changed add (+) button to arrow right side in tab section

          }),
        ],
      ),
    );
  }

  // Helper method to build scroll buttons (left and right)
  Widget _buildScrollButton(IconData icon, VoidCallback onPressed) {
    return Container(
      height: 110, // Set height of scroll button
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.redAccent),
        onPressed: onPressed, // Trigger scroll action when pressed
      ),
    );
  }
}

