import 'package:flutter/material.dart';

class LeftSidebar extends StatelessWidget {
  final int selectedSidebarIndex;
  final Function(int) onSidebarItemSelected;
  final bool isVertical;

  const LeftSidebar({
    required this.selectedSidebarIndex,
    required this.onSidebarItemSelected,
    this.isVertical = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isVertical ? MediaQuery.of(context).size.width * 0.12 : null,
      height: isVertical ? null : 100,
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: isVertical ? _buildVerticalLayout() : _buildHorizontalLayout(),
        ),
      ),
    );
  }

  Widget _buildVerticalLayout() {
    return LayoutBuilder( //Build #1.0.2 : updated the code for this fix - RenderFlex overflowed by 42 pixels on the bottom
      builder: (context, constraints) {
        bool isSmallScreen = constraints.maxHeight < 600; // Adjust height as needed

        Widget sidebarContent = Column(
          children: [
            SingleChildScrollView(child:  Flexible(

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const Divider(color: Colors.black54),
                  SidebarButton(
                    icon: Icons.flash_on,
                    label: 'Fast Keys',
                    isSelected: selectedSidebarIndex == 0,
                    onTap: () => onSidebarItemSelected(0),
                    isVertical: isVertical,
                  ),
                  SidebarButton(
                    icon: Icons.category,
                    label: 'Categories',
                    isSelected: selectedSidebarIndex == 1,
                    onTap: () => onSidebarItemSelected(1),
                    isVertical: isVertical,
                  ),
                  SidebarButton(
                    icon: Icons.add,
                    label: 'Add',
                    isSelected: selectedSidebarIndex == 2,
                    onTap: () => onSidebarItemSelected(2),
                    isVertical: isVertical,
                  ),
                  SidebarButton(
                    icon: Icons.shopping_basket,
                    label: 'Orders',
                    isSelected: selectedSidebarIndex == 3,
                    onTap: () => onSidebarItemSelected(3),
                    isVertical: isVertical,
                  ),
                  // SidebarButton(
                  //   icon: Icons.apps,
                  //   label: 'Apps',
                  //   isSelected: selectedSidebarIndex == 4,
                  //   onTap: () => onSidebarItemSelected(4),
                  //   isVertical: isVertical,
                  // ),
                ],
              ),
            ),),

            const Spacer(), // Keeps items aligned
            Container(
              height: 200,
              // margin: EdgeInsets.only(bottom: 5),
              child: Column(
              children: [
                const Divider(color: Colors.black54),
                SidebarButton(
                  icon: Icons.settings,
                  label: 'Settings',
                  isSelected: selectedSidebarIndex == 5,
                  onTap: () => onSidebarItemSelected(5),
                  isVertical: isVertical,
                ),
                SidebarButton(
                  icon: Icons.logout,
                  label: 'Logout',
                  isSelected: selectedSidebarIndex == 6,
                  onTap: () => onSidebarItemSelected(6),
                  isVertical: isVertical,
                ),
                const SizedBox(height: 10),
              ],
            ),),

          ],
        );

        return sidebarContent;
        // return isSmallScreen
        //     ? Expanded(child: SingleChildScrollView(child: sidebarContent) ,)
        //     : sidebarContent;
      },
    );
  }



  Widget _buildHorizontalLayout() {
    return LayoutBuilder( //Build #1.0.2 : updated the code for this fix - RenderFlex overflowed by 42 pixels
      builder: (context, constraints) {
        bool isSmallScreen = constraints.maxWidth < 600; // Adjust width as needed

        Widget rowContent = Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SidebarButton(
              icon: Icons.flash_on,
              label: 'Fast Keys',
              isSelected: selectedSidebarIndex == 0,
              onTap: () => onSidebarItemSelected(0),
              isVertical: isVertical,
            ),
            SidebarButton(
              icon: Icons.category,
              label: 'Categories',
              isSelected: selectedSidebarIndex == 1,
              onTap: () => onSidebarItemSelected(1),
              isVertical: isVertical,
            ),
            SidebarButton(
              icon: Icons.add,
              label: 'Add',
              isSelected: selectedSidebarIndex == 2,
              onTap: () => onSidebarItemSelected(2),
              isVertical: isVertical,
            ),
            SidebarButton(
              icon: Icons.shopping_basket,
              label: 'Orders',
              isSelected: selectedSidebarIndex == 3,
              onTap: () => onSidebarItemSelected(3),
              isVertical: isVertical,
            ),
            SidebarButton(
              icon: Icons.apps,
              label: 'Apps',
              isSelected: selectedSidebarIndex == 4,
              onTap: () => onSidebarItemSelected(4),
              isVertical: isVertical,
            ),
            SidebarButton(
              icon: Icons.settings,
              label: 'Settings',
              isSelected: selectedSidebarIndex == 5,
              onTap: () => onSidebarItemSelected(5),
              isVertical: isVertical,
            ),
            SidebarButton(
              icon: Icons.logout,
              label: 'Logout',
              isSelected: selectedSidebarIndex == 6,
              onTap: () => onSidebarItemSelected(6),
              isVertical: isVertical,
            ),
          ],
        );

        return isSmallScreen
            ? SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Enables horizontal scrolling
              child: rowContent,
        )
            : rowContent;
      },
    );
  }
}

class SidebarButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isVertical;

  const SidebarButton({
    this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isVertical = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: isVertical ? _buildVerticalLayout() : _buildHorizontalLayout(),
      ),
    );
  }

  Widget _buildVerticalLayout() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: isSelected ? Colors.red : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.red : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: isSelected ? Colors.red : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.red : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}