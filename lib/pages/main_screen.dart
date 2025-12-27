import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notes_sharing/pages/saved_notes.dart';
import 'branch_subject_selection_page.dart';
import 'notes_list_page.dart';
import 'profile_page.dart';
import 'home_page.dart';
import '../providers/auth_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  String? _notesDegreeId;
  String? _notesBranchId;
  String? _notesSubjectId;

  void _navigateToIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> _getPages() {
    return [
      HomePage(
        onNavigateToBrowse: () => _navigateToIndex(1),
        onNavigateToUpload: () => _navigateToIndex(1),
      ),
      BranchSubjectSelectionPage(),
      SavedNotesPage(),
      ProfilePage(),
    ];
  }

  final List<String> _titles = const [
    "Home",
    "Browse Notes",
    "Saved",
    "Profile",
  ];

  final List<IconData> _icons = const [
    Icons.home_rounded,
    Icons.search_rounded,
    Icons.bookmark_rounded,
    Icons.person_rounded,
  ];

  final Color _bgColor = const Color(0xFFF5F5F0);

  final Color _sidebarColor = const Color(0xFFF5F5F0);
  final Color _accentColor = const Color(0xFF000000);
  final Color _textColor = const Color(0xFF000000);
  final Color _subtextColor = const Color(0xFF666666);
  final Color _borderColor = const Color(0xFFE5E5E0);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return screenWidth > 768 ? _buildWebLayout() : _buildMobileLayout();
  }

  Widget _buildWebLayout() {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Row(
        children: [
          // Left Sidebar
          Container(
            width: 240,
            color: _sidebarColor,
            child: Column(
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _accentColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.book, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'NoteVerse',
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Navigation
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: List.generate(_titles.length, (index) {
                      return _SidebarItem(
                        icon: _icons[index],
                        title: _titles[index],
                        isSelected: _currentIndex == index,
                        onTap: () => _navigateToIndex(index),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: _bgColor,
                    border: Border(
                      bottom: BorderSide(color: _borderColor, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _titles[_currentIndex],
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      // Search Bar
                      Container(
                        width: 300,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F0),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _borderColor),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: _subtextColor, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                style: TextStyle(color: const Color(0xFFF5F5F0), fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Search...',
                                  hintStyle: TextStyle(color: _subtextColor),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: _borderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.notifications_outlined, color: _textColor),
                          onPressed: () {},
                          iconSize: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: _borderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.logout, color: _textColor),
                          onPressed: () => _showLogoutDialog(context),
                          iconSize: 20,
                          tooltip: 'Logout',
                        ),
                      ),
                    ],
                  ),
                ),

                // Page Content
                Expanded(
                  child: _buildCurrentPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _sidebarColor,
        elevation: 0,
        title: Text(
          _titles[_currentIndex],
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: _textColor),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Logout',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: _borderColor,
            height: 1,
          ),
        ),
      ),
      body: _buildCurrentPage(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _sidebarColor,
          border: Border(
            top: BorderSide(color: _borderColor, width: 1),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: List.generate(_titles.length, (index) {
              return Expanded(
                child: InkWell(
                  onTap: () => _navigateToIndex(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _icons[index],
                          color: _currentIndex == index ? _accentColor : _subtextColor,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _titles[index],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: _currentIndex == index 
                                ? FontWeight.w600 
                                : FontWeight.w400,
                            color: _currentIndex == index ? _accentColor : _subtextColor,
                          ),
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
    );
  }

  Widget _buildCurrentPage() {
    if (_currentIndex == 1) {
      if (_notesDegreeId != null &&
          _notesBranchId != null &&
          _notesSubjectId != null) {
        return NotesListPage(
          degreeId: _notesDegreeId!,
          branchId: _notesBranchId!,
          subjectId: _notesSubjectId!,
          onBack: () {
            setState(() {
              _notesDegreeId = null;
              _notesBranchId = null;
              _notesSubjectId = null;
            });
          },
        );
      } else {
        return BranchSubjectSelectionPage(
          onViewNotes: (degreeId, branchId, subjectId) {
            setState(() {
              _notesDegreeId = degreeId;
              _notesBranchId = branchId;
              _notesSubjectId = subjectId;
            });
          },
        );
      }
    }

    return _getPages()[_currentIndex];
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Logout?',
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: _subtextColor,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: _subtextColor,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
              await authProvider.signOut();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected 
              ? Border.all(color: const Color(0xFFE5E5E0)) 
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF000000) : const Color(0xFF666666),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF000000) : const Color(0xFF666666),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}