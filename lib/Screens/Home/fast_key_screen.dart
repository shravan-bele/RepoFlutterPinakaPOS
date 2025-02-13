import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Widgets/widget_category_list.dart';
import '../../Widgets/widget_nested_grid_layout.dart';
import '../../Widgets/widget_order_panel.dart';
import '../../Widgets/widget_sidebar.dart';
import '../../Widgets/widget_topbar.dart';

// Enum for sidebar position
enum SidebarPosition { left, right, bottom }
// Enum for order panel position
enum OrderPanelPosition { left, right }

class FastKeyScreen extends StatefulWidget {
  const FastKeyScreen({super.key});

  @override
  State<FastKeyScreen> createState() => _FastKeyScreenState();
}

class _FastKeyScreenState extends State<FastKeyScreen> {
  final List<String> items = List.generate(18, (index) => 'Bud Light');
  int _selectedSidebarIndex = -1;
  DateTime now = DateTime.now();
  List<int> quantities = [1, 1];
  SidebarPosition sidebarPosition = SidebarPosition.right; // Default to bottom sidebar
  OrderPanelPosition orderPanelPosition = OrderPanelPosition.left; // Default to right

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    String formattedDate = DateFormat("EEE, MMM d' ${now.year}'").format(now);
    String formattedTime = DateFormat('hh:mm a').format(now);

    return Scaffold(
      body: Column(
        children: [
          // Top Bar
          TopBar(
            onModeChanged: () {
              setState(() {
                if (sidebarPosition == SidebarPosition.left) {
                  sidebarPosition = SidebarPosition.right;
                } else if (sidebarPosition == SidebarPosition.right) {
                  sidebarPosition = SidebarPosition.bottom;
                } else {
                  sidebarPosition = SidebarPosition.left;
                }
              });
            },
          ),

          // Main Content
          Expanded(
            child: Row(
              children: [
                // Left Sidebar (Conditional)
                if (sidebarPosition == SidebarPosition.left)
                  LeftSidebar(
                    selectedSidebarIndex: _selectedSidebarIndex,
                    onSidebarItemSelected: (index) {
                      setState(() {
                        _selectedSidebarIndex = index;
                      });
                    },
                    isVertical: true, // Vertical layout for left sidebar
                  ),

                // Order Panel on the Left (Conditional: Only when sidebar is right or bottom with left order panel)
                if (sidebarPosition == SidebarPosition.right ||
                    (sidebarPosition == SidebarPosition.bottom && orderPanelPosition == OrderPanelPosition.left))
                  RightOrderPanel(
                    formattedDate: formattedDate,
                    formattedTime: formattedTime,
                    quantities: quantities,
                  ),

                // Main Content (Horizontal Scroll and Grid View)
                const Expanded(
                  child: Column(
                    children: [
                      // Add the CategoryScroll widget here
                      CategoryList(),

                      // Grid Layout
                      NestedGridWidget()
                    ],
                  ),
                ),

                // Order Panel on the Right (Conditional: Only when sidebar is left or bottom with right order panel)
                if (sidebarPosition != SidebarPosition.right &&
                    !(sidebarPosition == SidebarPosition.bottom && orderPanelPosition == OrderPanelPosition.left))
                  RightOrderPanel(
                    formattedDate: formattedDate,
                    formattedTime: formattedTime,
                    quantities: quantities,
                  ),

                // Right Sidebar (Conditional)
                if (sidebarPosition == SidebarPosition.right)
                  LeftSidebar(
                    selectedSidebarIndex: _selectedSidebarIndex,
                    onSidebarItemSelected: (index) {
                      setState(() {
                        _selectedSidebarIndex = index;
                      });
                    },
                    isVertical: true, // Vertical layout for right sidebar
                  ),
              ],
            ),
          ),

          // Bottom Sidebar (Conditional)
          if (sidebarPosition == SidebarPosition.bottom)
            LeftSidebar(
              selectedSidebarIndex: _selectedSidebarIndex,
              onSidebarItemSelected: (index) {
                setState(() {
                  _selectedSidebarIndex = index;
                });
              },
              isVertical: false, // Horizontal layout for bottom sidebar
            ),
        ],
      ),
    );
  }
}

