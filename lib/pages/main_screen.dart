// import 'package:flutter/material.dart';
// import 'package:notes_sharing/pages/saved_notes.dart';
// import 'branch_subject_selection_page.dart';
// import 'notes_list_page.dart';
// import 'profile_page.dart';
// import 'saved_notes.dart';
// import 'home_page.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int _currentIndex = 0;

//   String? _notesDegreeId;
//   String? _notesBranchId;
//   String? _notesSubjectId;

//   final List<Widget> _pages = const [
//     HomePage(),
//     BranchSubjectSelectionPage(),
//     SavedNotesPage(),
//     ProfilePage(),
//   ];

//   final List<String> _titles = const [
//     "Home",
//     "Select Branch",
//     "Saved Notes",
//     "Profile",
//   ];

//   final List<IconData> _icons = const [
//     Icons.home,
//     Icons.school,
//     Icons.bookmark,
//     Icons.person,
//   ];

//   final List<IconData> _outlinedIcons = const [
//     Icons.home_outlined,
//     Icons.school_outlined,
//     Icons.bookmark_outline,
//     Icons.person_outlined,
//   ];

//   // Green color palette
//   final Color _primaryGreen = const Color(0xFF10B981);
//   final Color _darkGreen = const Color(0xFF059669);
//   final Color _lightGreen = const Color(0xFF34D399);

//   @override
//   Widget build(BuildContext context) {
//     final bool isDesktop = MediaQuery.of(context).size.width >= 768;
//     final Color backgroundColor = const Color(0xFF0F172A);
//     final Color surfaceColor = const Color(0xFF1A2332);

//     if (isDesktop) {
//       return _buildDesktopLayout(backgroundColor, surfaceColor);
//     } else {
//       return _buildMobileLayout(backgroundColor);
//     }
//   }

//   Widget _buildDesktopLayout(Color backgroundColor, Color surfaceColor) {
//     return Scaffold(
//       body: Row(
//         children: [
//           // Left Navigation Rail
//           Container(
//             width: 280,
//             decoration: BoxDecoration(
//               color: surfaceColor,
//               border: Border(
//                 right: BorderSide(
//                   color: Colors.grey.shade800,
//                   width: 1,
//                 ),
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 8,
//                   offset: const Offset(2, 0),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 // App Header
//                 Container(
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     border: Border(
//                       bottom: BorderSide(
//                         color: Colors.grey.shade800,
//                         width: 1,
//                       ),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [_primaryGreen, _darkGreen],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Icon(
//                           Icons.menu_book_rounded,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const Text(
//                         'NoteVerse',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Navigation Items
//                 Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     itemCount: _titles.length,
//                     itemBuilder: (context, index) {
//                       final bool isSelected = _currentIndex == index;
//                       return Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                         child: Material(
//                           color: isSelected
//                               ? _primaryGreen.withOpacity(0.15)
//                               : Colors.transparent,
//                           borderRadius: BorderRadius.circular(12),
//                           child: InkWell(
//                             onTap: () {
//                               setState(() => _currentIndex = index);
//                             },
//                             borderRadius: BorderRadius.circular(12),
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 14,
//                               ),
//                               decoration: BoxDecoration(
//                                 border: isSelected
//                                     ? Border.all(
//                                   color: _primaryGreen.withOpacity(0.3),
//                                   width: 1,
//                                 )
//                                     : null,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                     isSelected ? _icons[index] : _outlinedIcons[index],
//                                     color: isSelected ? _primaryGreen : Colors.white70,
//                                     size: 22,
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Text(
//                                     _titles[index],
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                                       color: isSelected ? _primaryGreen : Colors.white70,
//                                     ),
//                                   ),
//                                   if (isSelected) ...[
//                                     const Spacer(),
//                                     Container(
//                                       width: 6,
//                                       height: 6,
//                                       decoration: BoxDecoration(
//                                         color: _primaryGreen,
//                                         shape: BoxShape.circle,
//                                       ),
//                                     ),
//                                   ],
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 // User Profile at bottom
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     border: Border(
//                       top: BorderSide(
//                         color: Colors.grey.shade800,
//                         width: 1,
//                       ),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [_lightGreen, _primaryGreen],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.person,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Student',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             Text(
//                               'Premium User',
//                               style: TextStyle(
//                                 color: Colors.white70,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(
//                           Icons.settings_outlined,
//                           color: Colors.white70,
//                           size: 20,
//                         ),
//                         onPressed: () {
//                           setState(() => _currentIndex = 3); // Go to profile
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Main Content Area
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     backgroundColor,
//                     backgroundColor.withOpacity(0.98),
//                   ],
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   // Desktop App Bar
//                   Container(
//                     height: 70,
//                     padding: const EdgeInsets.symmetric(horizontal: 24),
//                     decoration: BoxDecoration(
//                       color: surfaceColor.withOpacity(0.8),
//                       border: Border(
//                         bottom: BorderSide(
//                           color: Colors.grey.shade800,
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Text(
//                           _titles[_currentIndex],
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const Spacer(),
//                         // Search Bar
//                         Container(
//                           width: 300,
//                           height: 40,
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF1E293B),
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(
//                               color: const Color(0xFF334155),
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.search,
//                                 color: Colors.white54,
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: TextField(
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 14,
//                                   ),
//                                   decoration: InputDecoration(
//                                     hintText: 'Search...',
//                                     hintStyle: TextStyle(
//                                       color: Colors.white54,
//                                     ),
//                                     border: InputBorder.none,
//                                     isDense: true,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         // Notification Icon
//                         Container(
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF1E293B),
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: const Color(0xFF334155),
//                             ),
//                           ),
//                           child: IconButton(
//                             icon: Icon(
//                               Icons.notifications_outlined,
//                               color: Colors.white70,
//                               size: 20,
//                             ),
//                             onPressed: () {},
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Page Content
//                   Expanded(
//                     child: Container(
//                       padding: const EdgeInsets.all(24),
//                       child: _buildCurrentPage(),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMobileLayout(Color backgroundColor) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           _titles[_currentIndex],
//           style: const TextStyle(
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: const Color(0xFF1A2332),
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           if (_currentIndex == 0) // Only show search on home page
//             IconButton(
//               icon: const Icon(Icons.search, color: Colors.white70),
//               onPressed: () {},
//             ),
//         ],
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               backgroundColor,
//               backgroundColor.withOpacity(0.98),
//             ],
//           ),
//         ),
//         child: _buildCurrentPage(),
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: const Color(0xFF1A2332),
//           border: Border(
//             top: BorderSide(
//               color: Colors.grey.shade800,
//               width: 1,
//             ),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 10,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           type: BottomNavigationBarType.fixed,
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           selectedItemColor: _primaryGreen,
//           unselectedItemColor: Colors.white70,
//           selectedLabelStyle: const TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 12,
//           ),
//           unselectedLabelStyle: const TextStyle(
//             fontWeight: FontWeight.w500,
//             fontSize: 12,
//           ),
//           onTap: (index) {
//             setState(() => _currentIndex = index);
//           },
//           items: [
//             _buildBottomNavItem(Icons.home_outlined, Icons.home, 'Home'),
//             _buildBottomNavItem(Icons.school_outlined, Icons.school, 'Select'),
//             _buildBottomNavItem(Icons.bookmark_outlined, Icons.bookmark, 'Saved'),
//             _buildBottomNavItem(Icons.person_outlined, Icons.person, 'Profile'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCurrentPage() {
//     if (_currentIndex == 1) {
//       if (_notesDegreeId != null &&
//           _notesBranchId != null &&
//           _notesSubjectId != null) {
//         return NotesListPage(
//           degreeId: _notesDegreeId!,
//           branchId: _notesBranchId!,
//           subjectId: _notesSubjectId!,
//           onBack: () {
//             setState(() {
//               _notesDegreeId = null;
//               _notesBranchId = null;
//               _notesSubjectId = null;
//             });
//           },
//         );
//       } else {
//         return BranchSubjectSelectionPage(
//           onViewNotes: (degreeId, branchId, subjectId) {
//             setState(() {
//               _notesDegreeId = degreeId;
//               _notesBranchId = branchId;
//               _notesSubjectId = subjectId;
//             });
//           },
//         );
//       }
//     }

//     return _pages[_currentIndex];
//   }

//   BottomNavigationBarItem _buildBottomNavItem(IconData outlineIcon, IconData filledIcon, String label) {
//     return BottomNavigationBarItem(
//       icon: Container(
//         padding: const EdgeInsets.all(6),
//         decoration: const BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.transparent,
//         ),
//         child: Icon(outlineIcon, size: 24, color: Colors.white70),
//       ),
//       activeIcon: Container(
//         padding: const EdgeInsets.all(6),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [_primaryGreen, _darkGreen],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(filledIcon, color: Colors.white, size: 20),
//       ),
//       label: label,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:notes_sharing/pages/saved_notes.dart';
import 'branch_subject_selection_page.dart';
import 'notes_list_page.dart';
import 'profile_page.dart';
import 'saved_notes.dart';
import 'home_page.dart';

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

  final List<Widget> _pages = const [
    HomePage(),
    BranchSubjectSelectionPage(),
    SavedNotesPage(),
    ProfilePage(),
  ];

  final List<String> _titles = const [
    "Home",
    "Select Branch",
    "Saved Notes",
    "Profile",
  ];

  final List<IconData> _icons = const [
    Icons.home_rounded,
    Icons.school_rounded,
    Icons.bookmark_rounded,
    Icons.person_rounded,
  ];

  final List<IconData> _outlinedIcons = const [
    Icons.home_outlined,
    Icons.school_outlined,
    Icons.bookmark_outline_rounded,
    Icons.person_outlined,
  ];

  // New neon color palette
  final Color _neonGreen = const Color(0xFF00FF88);
  final Color _neonMagenta = const Color(0xFFFF0080);
  final Color _neonCyan = const Color(0xFF00D4FF);
  final Color _primaryDark = const Color(0xFF1A1A1A);
  final Color _secondaryDark = const Color(0xFF2D2D2D);
  final Color _deepDark = const Color(0xFF0F0F0F);
  final Color _primaryText = const Color(0xFFFFFFFF);
  final Color _secondaryText = const Color(0xFFB3B3B3);
  final Color _subtleText = const Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    if (isDesktop) {
      return _buildDesktopLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Left Navigation Rail - Slim and modern
          Container(
            width: 80,
            decoration: BoxDecoration(
              color: _secondaryDark,
              border: Border(
                right: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // App Logo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_neonGreen, _neonCyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _neonGreen.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),

                // Navigation Items
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_titles.length, (index) {
                      final bool isSelected = _currentIndex == index;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: _DesktopNavItem(
                          icon: isSelected ? _icons[index] : _outlinedIcons[index],
                          isSelected: isSelected,
                          onTap: () => setState(() => _currentIndex = index),
                          color: _getNavColor(index),
                        ),
                      );
                    }),
                  ),
                ),

                // Settings button
                Container(
                  padding: const EdgeInsets.all(16),
                  child: _DesktopNavItem(
                    icon: Icons.settings_rounded,
                    isSelected: false,
                    onTap: () => setState(() => _currentIndex = 3),
                    color: _secondaryText,
                  ),
                ),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _primaryDark,
                    _deepDark,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Desktop App Bar
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: _secondaryDark.withOpacity(0.8),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _titles[_currentIndex],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: _primaryText,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Spacer(),
                        // Search Bar with glow effect
                        Container(
                          width: 300,
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: _deepDark,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _neonCyan.withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _neonCyan.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                color: _neonCyan,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  style: TextStyle(
                                    color: _primaryText,
                                    fontSize: 14,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search notes...',
                                    hintStyle: TextStyle(
                                      color: _subtleText,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Notification Icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _deepDark,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _neonMagenta.withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _neonMagenta.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.notifications_none_rounded,
                              color: _neonMagenta,
                              size: 20,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Page Content
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: _buildCurrentPage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: _primaryDark,
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: _primaryText,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: _secondaryDark,
        elevation: 0,
        iconTheme: IconThemeData(color: _primaryText),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: Icon(Icons.search_rounded, color: _neonCyan),
              onPressed: () {},
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _primaryDark,
              _deepDark,
            ],
          ),
        ),
        child: _buildCurrentPage(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _secondaryDark,
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_titles.length, (index) {
              final bool isSelected = _currentIndex == index;
              return _MobileNavItem(
                icon: isSelected ? _icons[index] : _outlinedIcons[index],
                isSelected: isSelected,
                onTap: () => setState(() => _currentIndex = index),
                color: _getNavColor(index),
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

    return _pages[_currentIndex];
  }

  Color _getNavColor(int index) {
    switch (index) {
      case 0:
        return _neonGreen;
      case 1:
        return _neonCyan;
      case 2:
        return _neonMagenta;
      case 3:
        return _neonGreen;
      default:
        return _neonCyan;
    }
  }
}

class _DesktopNavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _DesktopNavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(
                  color: color.withOpacity(0.4),
                  width: 2,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isSelected ? color : Colors.white.withOpacity(0.6),
          size: 24,
        ),
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _MobileNavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isSelected ? 52 : 44,
        height: isSelected ? 52 : 44,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(isSelected ? 16 : 12),
          border: isSelected
              ? Border.all(
                  color: color.withOpacity(0.4),
                  width: 2,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isSelected ? color : Colors.white.withOpacity(0.6),
          size: isSelected ? 24 : 22,
        ),
      ),
    );
  }
}