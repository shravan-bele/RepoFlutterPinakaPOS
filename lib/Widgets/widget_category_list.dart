// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import '../Models/FastKey/category_model.dart';
//
// class CategoryList extends StatefulWidget {
//   const CategoryList({super.key});
//
//   @override
//   _CategoryListState createState() => _CategoryListState();
// }
//
// class _CategoryListState extends State<CategoryList> {
//   // Scroll controller to manage horizontal scrolling
//   final ScrollController _scrollController = ScrollController();
//   // Flags to show left and right scroll arrows
//   bool _showLeftArrow = false;
//   bool _showRightArrow = true;
//   // Track selected item index
//   int _selectedIndex = -1;
//
//   // Ex: List of category data
//   final List<CategoryModel> categories = [
//     CategoryModel(name: 'Pickles1', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
//     CategoryModel(name: 'Alcohol2', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
//     CategoryModel(name: 'Juice3', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
//     CategoryModel(name: 'Drinks4', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
//     CategoryModel(name: 'Bread5', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
//     CategoryModel(name: 'Coffee6', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
//     CategoryModel(name: 'Category7', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
//     CategoryModel(name: 'Pickles1', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
//     CategoryModel(name: 'Alcohol2', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
//     CategoryModel(name: 'Juice3', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
//     CategoryModel(name: 'Drinks4', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
//     CategoryModel(name: 'Bread5', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
//     CategoryModel(name: 'Coffee6', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
//     CategoryModel(name: 'Category7', itemCount: '30 Items', imageAsset: 'assets/svg/password_placeholder.svg'),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     // Add listener to scroll controller for dynamic arrow visibility
//     _scrollController.addListener(() {
//       setState(() {
//         // Show the left arrow if scrolling has occurred to the left
//         _showLeftArrow = _scrollController.offset > 0;
//         // Show the right arrow if we haven't reached the end of the list
//         _showRightArrow = _scrollController.offset < _scrollController.position.maxScrollExtent;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size; // Get screen size
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           // Show left scroll button if needed
//           if (_showLeftArrow)
//             _buildScrollButton(Icons.arrow_back_ios, () {
//               // Scroll left
//               _scrollController.animateTo(
//                 _scrollController.offset - size.width,
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//               );
//             }),
//           Expanded(
//             child: Container(
//               height: 110, // Set height of the category list
//               child: ListView.builder(
//                 controller: _scrollController, // Set scroll controller
//                 scrollDirection: Axis.horizontal, // Horizontal scrolling
//                 itemCount: categories.length, // Number of categories
//                 itemBuilder: (context, index) {
//                   final category = categories[index];
//                   bool isSelected = _selectedIndex == index; // Check if item is selected
//
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _selectedIndex = isSelected ? -1 : index; // Toggle selection
//                       });
//                       // Print selected category for debugging
//                       if (kDebugMode) {
//                         print('Selected Category: ${category.name}');
//                       }
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 5.0),
//                       child: Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: isSelected ? Colors.red : Colors.white, // Change color when selected
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.black12),
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             // Display category image
//                             SvgPicture.asset(
//                               category.imageAsset,
//                               height: 40,
//                               width: 40,
//                             ),
//                             const SizedBox(height: 8),
//                             // Display category name
//                             Text(
//                               category.name,
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: isSelected ? Colors.white : Colors.black,
//                               ),
//                             ),
//                             // Display item count
//                             Text(
//                               category.itemCount,
//                               style: TextStyle(
//                                 color: isSelected ? Colors.white : Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//           // Show right scroll button if needed
//           if (_showRightArrow)
//             _buildScrollButton(Icons.arrow_forward_ios, () {
//               // Scroll right
//               _scrollController.animateTo(
//                 _scrollController.offset + size.width,
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//               );
//             }),
//
//            const SizedBox(width: 8),
//
//           _buildScrollButton(Icons.add, (){ //Build #1.0.2 : changed add (+) button to arrow right side in tab section
//
//           }),
//         ],
//       ),
//     );
//   }
//
//   // Helper method to build scroll buttons (left and right)
//   Widget _buildScrollButton(IconData icon, VoidCallback onPressed) {
//     return Container(
//       height: 110, // Set height of scroll button
//       padding: const EdgeInsets.all(1),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.black12),
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: IconButton(
//         icon: Icon(icon, color: Colors.redAccent),
//         onPressed: onPressed, // Trigger scroll action when pressed
//       ),
//     );
//   }
// }
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../Models/FastKey/category_model.dart';

class CategoryList extends StatefulWidget {
  final bool isHorizontal; // Build #1.0.6
  const CategoryList({super.key, required this.isHorizontal});

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  // Scroll controller to manage horizontal scrolling
  final ScrollController _scrollController = ScrollController();
  // Flags to show left and right scroll arrows
  bool _showLeftArrow = false;
  bool _showRightArrow = true;
  int? _selectedIndex = 0; // Changed to nullable for better handling
  int? _editingIndex; // Track the item being reordered or edited

  // Ex: List of category data
  final List<CategoryModel> categories = [
    CategoryModel(
        name: 'Pickles1',
        itemCount: '30 Items',
        imageAsset: 'assets/svg/password_placeholder.svg'),
    CategoryModel(
        name: 'Alcohol2',
        itemCount: '30 Items',
        imageAsset: 'assets/svg/password_placeholder.svg'),
    CategoryModel(
        name: 'Juice3',
        itemCount: '30 Items',
        imageAsset: 'assets/svg/password_placeholder.svg'),
    CategoryModel(
        name: 'Drinks4',
        itemCount: '30 Items',
        imageAsset: 'assets/svg/password_placeholder.svg'),
    CategoryModel(
        name: 'Bread5',
        itemCount: '30 Items',
        imageAsset: 'assets/svg/password_placeholder.svg'),
    CategoryModel(
        name: 'Coffee6',
        itemCount: '30 Items',
        imageAsset: 'assets/svg/password_placeholder.svg'),
    CategoryModel(
        name: 'Category7',
        itemCount: '30 Items',
        imageAsset: 'assets/svg/password_placeholder.svg'),
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: widget.isHorizontal // Build #1.0.6
          ? _buildHorizontalList()
          : _buildVerticalList(),
    );
  }


  Widget _buildHorizontalList() {
    var size = MediaQuery.of(context).size; // Get screen size
    return Row(
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
          child: SizedBox(
            height: 110,
            child: ReorderableListView( //Build #1.0.4
              scrollController: _scrollController,
              scrollDirection: Axis.horizontal,
              onReorderStart: (index) {
                if (kDebugMode) {
                  print("##### onReorderStart 123");
                }
                setState(() {
                  _editingIndex =
                      index; // Keep track of the item being reordered
                });
              },
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex--;

                setState(() {
                  final item = categories.removeAt(oldIndex);
                  categories.insert(newIndex, item);

                  // Adjust _editingIndex if the item was moved
                  if (_editingIndex == oldIndex) {
                    _editingIndex = newIndex;
                  }

                  // Only update _selectedIndex if it's not null.
                  if (_selectedIndex != null) {
                    if (_selectedIndex == oldIndex) {
                      _selectedIndex = newIndex;
                    } else if (oldIndex < _selectedIndex! &&
                        newIndex >= _selectedIndex!) {
                      _selectedIndex = _selectedIndex! - 1;
                    } else if (oldIndex > _selectedIndex! &&
                        newIndex <= _selectedIndex!) {
                      _selectedIndex = _selectedIndex! + 1;
                    }
                  }
                });
              },
              proxyDecorator: (Widget child, int index,
                  Animation<double> animation) {
                return Material(
                  elevation: 0, // Remove shadow
                  color: Colors.transparent, // Make background transparent
                  child: child,
                );
              },
              children: List.generate(categories.length, (index) {
                final category = categories[index];
                bool isSelected = _selectedIndex ==
                    index; // Check if item is selected
                bool showEditButton = _editingIndex == index;

                return GestureDetector(
                  key: ValueKey(category.name),
                  // onLongPressStart: (details) {
                  //   if (kDebugMode) {
                  //     print("##### onLongPressStart 123");
                  //   }
                  //   setState(() {
                  //     _editingIndex = index; // Show edit button
                  //   });
                  // },
                  onTap: () {
                    setState(() {
                      if (_selectedIndex == index) {
                        _selectedIndex = null;
                      } else {
                        _selectedIndex = index;
                        _editingIndex =
                        null; // Hide edit button when selecting a different item
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.red : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _editingIndex == index
                              ? Colors.blueAccent
                              : Colors.black12,
                          width: _editingIndex == index
                              ? 2
                              : 1, // Slight border change on long press
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Edit Button with Animation
                          Positioned(
                            top: 0,
                            right: -6,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: showEditButton ? 1.0 : 0.0,
                              child: GestureDetector(
                                onTap: () =>
                                    _showCategoryDialog(index: index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit, size: 14,
                                      color: Colors.blueAccent),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                  category.imageAsset, height: 40,
                                  width: 40),
                              const SizedBox(height: 8),
                              Text(
                                category.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors
                                      .black,
                                ),
                              ),
                              Text(
                                category.itemCount,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors
                                      .grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
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
        _buildScrollButton(Icons.add, () {
          _showCategoryDialog();
        }),
      ],
    );
  }

  Widget _buildVerticalList() {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width * 0.35,
          child: ReorderableListView(
              scrollDirection: Axis.vertical,
              onReorderStart: (index) {
                if (kDebugMode) {
                  print("##### onReorderStart 123");
                }
                setState(() {
                  _editingIndex =
                      index; // Keep track of the item being reordered
                });
              },
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex--;

                setState(() {
                  final item = categories.removeAt(oldIndex);
                  categories.insert(newIndex, item);

                  // Adjust _editingIndex if the item was moved
                  if (_editingIndex == oldIndex) {
                    _editingIndex = newIndex;
                  }

                  // Only update _selectedIndex if it's not null.
                  if (_selectedIndex != null) {
                    if (_selectedIndex == oldIndex) {
                      _selectedIndex = newIndex;
                    } else if (oldIndex < _selectedIndex! &&
                        newIndex >= _selectedIndex!) {
                      _selectedIndex = _selectedIndex! - 1;
                    } else if (oldIndex > _selectedIndex! &&
                        newIndex <= _selectedIndex!) {
                      _selectedIndex = _selectedIndex! + 1;
                    }
                  }
                });
              },
              proxyDecorator: (Widget child, int index,
                  Animation<double> animation) {
                return Material(
                  elevation: 0, // Remove shadow
                  color: Colors.transparent, // Make background transparent
                  child: child,
                );
              },
              children: List.generate(categories.length, (index){
                final category = categories[index];
                bool isSelected = _selectedIndex ==
                    index; // Check if item is selected
                bool showEditButton = _editingIndex == index;
                return GestureDetector(
                  key: ValueKey(category.name),
                  onTap: () {
                    setState(() {
                      if (_selectedIndex == index) {
                        _selectedIndex = null;
                      } else {
                        _selectedIndex = index;
                        _editingIndex =
                        null; // Hide edit button when selecting a different item
                      }
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.red : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _editingIndex == index
                              ? Colors.blueAccent
                              : Colors.black12,
                          width: _editingIndex == index
                              ? 2
                              : 1, // Slight border change on long press
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: widget.isHorizontal ? 0 : 0,
                            right: widget.isHorizontal ? -6 : 0,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: showEditButton ? 1.0 : 0.0,
                              child: GestureDetector(
                                onTap: () =>
                                    _showCategoryDialog(index: index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit, size: 14,
                                      color: Colors.blueAccent),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              SvgPicture.asset(
                                category.imageAsset,
                                height: 30,
                                width: 30,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    category.itemCount,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ) ,
                    ),
                  ),
                );
              })
          ),
        ),
        SizedBox(height: 8,),
        Container(
          width: MediaQuery.of(context).size.width * 0.35,
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.add, color: Colors.redAccent),
            onPressed: (){
              _showCategoryDialog();
            },
          ),
        )
      ],
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

  void _showCategoryDialog({int? index}) { //Build #1.0.4
    bool isEditing = index != null;
    TextEditingController nameController =
    TextEditingController(text: isEditing ? categories[index].name : '');
    String imagePath = isEditing ? categories[index].imageAsset : '';
    bool showError = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Category' : 'Add Category'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Stack(
                          children: [
                            imagePath.isNotEmpty
                                ? (imagePath.startsWith('assets/')
                                ? SvgPicture.asset(imagePath,
                                height: 80, width: 80)
                                : Image.file(File(imagePath),
                                height: 80, width: 80))
                                : Container(
                              height: 80,
                              width: 80,
                              color: Colors.grey.shade200,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () async {
                                  final pickedFile = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  if (pickedFile != null) {
                                    setStateDialog(() {
                                      imagePath = pickedFile.path;
                                    });
                                  }
                                },
                                child: const Icon(Icons.edit,
                                    size: 18, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isEditing && showError && imagePath.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Image is required',
                            style:
                            TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          errorText: (!isEditing &&
                              showError &&
                              nameController.text.isEmpty)
                              ? 'Name is required'
                              : null,
                          errorStyle: const TextStyle(
                              color: Colors.red, fontSize: 12),
                          suffixIcon: isEditing
                              ? const Icon(Icons.edit,
                              size: 18, color: Colors.red)
                              : null,
                        ),
                      ),
                      if (isEditing)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Item Count: ${categories[index].itemCount}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    if (!isEditing &&
                        (nameController.text.isEmpty || imagePath.isEmpty)) {
                      setStateDialog(() {
                        showError = true;
                      });
                      return;
                    }
                    setState(() {
                      if (isEditing) {
                        categories[index].name = nameController.text;
                        categories[index].imageAsset = imagePath;
                      } else {
                        categories.add(CategoryModel(
                            name: nameController.text,
                            itemCount: '0',
                            imageAsset: imagePath.isNotEmpty
                                ? imagePath
                                : 'assets/default.svg'));
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
                if (isEditing)
                  TextButton(
                    onPressed: () => _showDeleteConfirmationDialog(index!),
                    child: const Text('Delete',
                        style: TextStyle(color: Colors.red)),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  //Build #1.0.4 🔹 New Function: Show Confirmation Before Deleting
  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Tab'),
          content:
          const Text('Do you want to delete this tab permanently?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  categories.removeAt(index);
                  if (_selectedIndex == index) _selectedIndex = null;
                });
                Navigator.pop(context); // Close confirmation dialog
                Navigator.pop(context); // Close edit dialog
              },
              child:
              const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
