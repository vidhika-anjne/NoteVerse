import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notes_provider.dart';
import 'notes_list_page.dart';

class BranchSubjectSelectionPage extends StatefulWidget {
  final void Function(String degreeId, String branchId, String subjectId)? onViewNotes;

  const BranchSubjectSelectionPage({super.key, this.onViewNotes});

  @override
  State<BranchSubjectSelectionPage> createState() =>
      _BranchSubjectSelectionPageState();
}

class _BranchSubjectSelectionPageState
    extends State<BranchSubjectSelectionPage> with TickerProviderStateMixin {
  String? selectedYear;
  String? selectedSemester;
  String? selectedBranchId;
  String? selectedSubjectId;

  List<String> yearOptions = ['1', '2', '3', '4'];
  List<String> semesterOptions = [];
  Map<String, dynamic> branches = {};
  Map<String, dynamic> subjects = {};

  late AnimationController _semesterController;
  late AnimationController _branchController;
  late AnimationController _subjectController;
  late AnimationController _buttonController;

  @override
  void initState() {
    super.initState();
    _semesterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _branchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _subjectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _loadBranches();
  }

  @override
  void dispose() {
    _semesterController.dispose();
    _branchController.dispose();
    _subjectController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _loadBranches() async {
    final notesProvider = context.read<NotesProvider>();
    final loadedBranches = await notesProvider.fetchBranches();
    if (!mounted) return;
    setState(() {
      branches = loadedBranches;
    });
  }

  Future<void> _loadSubjects(String branchId) async {
    final notesProvider = context.read<NotesProvider>();
    final loadedSubjects = await notesProvider.fetchSubjects(branchId: branchId);
    if (!mounted) return;
    setState(() {
      subjects = loadedSubjects;
    });
    _subjectController.forward(from: 0);
  }

  void _updateSemestersForYear(String year) {
    switch (year) {
      case '1':
        semesterOptions = ['1', '2'];
        break;
      case '2':
        semesterOptions = ['3', '4'];
        break;
      case '3':
        semesterOptions = ['5', '6'];
        break;
      case '4':
        semesterOptions = ['7', '8'];
        break;
      default:
        semesterOptions = [];
    }
  }

  void _resetSelections() {
    setState(() {
      selectedYear = null;
      selectedSemester = null;
      selectedBranchId = null;
      selectedSubjectId = null;
      semesterOptions = [];
      subjects = {};
    });
    _semesterController.reverse();
    _branchController.reverse();
    _subjectController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    final filteredSubjects = subjects.entries.where((entry) {
      final val = Map<String, dynamic>.from(entry.value);
      final yearMatch = selectedYear == null ||
          val['year'].toString() == selectedYear.toString();
      final semMatch = selectedSemester == null ||
          val['semester'].toString() == selectedSemester.toString();
      return yearMatch && semMatch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 120,
          vertical: isMobile ? 16 : 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Browse Notes',
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF000000),
                  ),
                ),
                const Spacer(),
                if (selectedYear != null)
                  TextButton.icon(
                    onPressed: _resetSelections,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reset'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF666666),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Select your course details to find notes',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: const Color(0xFF666666),
              ),
            ),
            SizedBox(height: isMobile ? 32 : 48),

            // Progress Stepper
            _buildProgressStepper(isMobile),
            SizedBox(height: isMobile ? 32 : 48),

            // Year Selection
            _buildSectionHeader(
              title: 'Select Year',
              subtitle: 'Choose your academic year',
              icon: Icons.school_outlined,
              isMobile: isMobile,
              step: '1',
            ),
            const SizedBox(height: 20),
            _buildYearGrid(isMobile),
            SizedBox(height: isMobile ? 32 : 48),

            // Semester Selection
            if (selectedYear != null) ...[
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _semesterController,
                  curve: Curves.easeOut,
                )),
                child: FadeTransition(
                  opacity: _semesterController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        title: 'Select Semester',
                        subtitle: 'Choose your current semester',
                        icon: Icons.date_range_outlined,
                        isMobile: isMobile,
                        step: '2',
                      ),
                      const SizedBox(height: 20),
                      _buildSemesterGrid(isMobile, isTablet),
                      SizedBox(height: isMobile ? 32 : 48),
                    ],
                  ),
                ),
              ),
            ],

            // Branch Selection
            if (selectedSemester != null) ...[
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _branchController,
                  curve: Curves.easeOut,
                )),
                child: FadeTransition(
                  opacity: _branchController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        title: 'Select Branch',
                        subtitle: 'Choose your department',
                        icon: Icons.account_tree_outlined,
                        isMobile: isMobile,
                        step: '3',
                      ),
                      const SizedBox(height: 20),
                      _buildBranchGrid(isMobile, isTablet),
                      SizedBox(height: isMobile ? 32 : 48),
                    ],
                  ),
                ),
              ),
            ],

            // Subject Selection
            if (selectedBranchId != null && subjects.isNotEmpty) ...[
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _subjectController,
                  curve: Curves.easeOut,
                )),
                child: FadeTransition(
                  opacity: _subjectController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        title: 'Select Subject',
                        subtitle: 'Choose your subject to view notes',
                        icon: Icons.menu_book_outlined,
                        isMobile: isMobile,
                        step: '4',
                      ),
                      const SizedBox(height: 20),
                      _buildSubjectGrid(filteredSubjects, isMobile, isTablet),
                      SizedBox(height: isMobile ? 32 : 48),
                    ],
                  ),
                ),
              ),
            ],

            // Continue Button
            if (selectedBranchId != null && selectedSubjectId != null) ...[
              _buildContinueButton(isMobile),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStepper(bool isMobile) {
    var completedSteps = 0;
    if (selectedYear != null) completedSteps++;
    if (selectedSemester != null) completedSteps++;
    if (selectedBranchId != null) completedSteps++;
    if (selectedSubjectId != null) completedSteps++;

    final steps = [
      {'title': 'Year', 'completed': selectedYear != null},
      {'title': 'Semester', 'completed': selectedSemester != null},
      {'title': 'Branch', 'completed': selectedBranchId != null},
      {'title': 'Subject', 'completed': selectedSubjectId != null},
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Line connector
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < completedSteps;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2,
              color: isCompleted 
                  ? const Color(0xFF000000) 
                  : const Color(0xFFE5E5E0),
            ),
          );
        } else {
          // Step circle
          final stepIndex = index ~/ 2;
          final step = steps[stepIndex];
          final isCompleted = step['completed'] as bool;
          final isActive = stepIndex == completedSteps;

          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isMobile ? 36 : 44,
                height: isMobile ? 36 : 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted 
                      ? const Color(0xFF000000) 
                      : (isActive ? Colors.white : const Color(0xFFF5F5F0)),
                  border: Border.all(
                    color: isCompleted || isActive
                        ? const Color(0xFF000000)
                        : const Color(0xFFE5E5E0),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        )
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            color: isActive 
                                ? const Color(0xFF000000)
                                : const Color(0xFF999999),
                            fontWeight: FontWeight.w600,
                            fontSize: isMobile ? 14 : 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                step['title'] as String,
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  fontWeight: isCompleted || isActive 
                      ? FontWeight.w600 
                      : FontWeight.w400,
                  color: isCompleted || isActive
                      ? const Color(0xFF000000)
                      : const Color(0xFF999999),
                ),
              ),
            ],
          );
        }
      }),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isMobile,
    required String step,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF000000), size: isMobile ? 20 : 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: const Color(0xFF000000),
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: const Color(0xFF666666),
                fontSize: isMobile ? 13 : 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildYearGrid(bool isMobile) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: yearOptions.map((year) {
        final isSelected = selectedYear == year;
        return _AnimatedSelectionCard(
          title: 'Year $year',
          isSelected: isSelected,
          isMobile: isMobile,
          width: isMobile ? 150 : 180,
          onTap: () {
            setState(() {
              selectedYear = year;
              selectedSemester = null;
              selectedBranchId = null;
              selectedSubjectId = null;
              _updateSemestersForYear(year);
            });
            _semesterController.forward(from: 0);
          },
        );
      }).toList(),
    );
  }

  Widget _buildSemesterGrid(bool isMobile, bool isTablet) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: semesterOptions.map((semester) {
        final isSelected = selectedSemester == semester;
        return _AnimatedSelectionCard(
          title: 'Semester $semester',
          subtitle: 'Year $selectedYear',
          isSelected: isSelected,
          isMobile: isMobile,
          width: isMobile ? 150 : 180,
          onTap: () {
            setState(() {
              selectedSemester = semester;
              selectedBranchId = null;
              selectedSubjectId = null;
            });
            _branchController.forward(from: 0);
          },
        );
      }).toList(),
    );
  }

  Widget _buildBranchGrid(bool isMobile, bool isTablet) {
    final crossAxisCount = _getCrossAxisCount(isMobile, isTablet);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: branches.entries.length,
      itemBuilder: (context, index) {
        final branch = branches.entries.elementAt(index);
        final isSelected = selectedBranchId == branch.key;
        return _AnimatedSelectionCard(
          title: branch.value['name'] ?? branch.key,
          subtitle: 'Department',
          isSelected: isSelected,
          isMobile: isMobile,
          onTap: () async {
            setState(() {
              selectedBranchId = branch.key;
              selectedSubjectId = null;
              subjects.clear();
            });
            await _loadSubjects(branch.key);
          },
        );
      },
    );
  }

  Widget _buildSubjectGrid(
    List<MapEntry<String, dynamic>> filteredSubjects,
    bool isMobile,
    bool isTablet,
  ) {
    if (filteredSubjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E5E0)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.search_off_outlined,
              size: isMobile ? 48 : 64,
              color: const Color(0xFF999999),
            ),
            const SizedBox(height: 16),
            Text(
              'No subjects found',
              style: TextStyle(
                color: const Color(0xFF000000),
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No subjects available for Year $selectedYear, Semester $selectedSemester',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF666666),
                fontSize: isMobile ? 13 : 14,
              ),
            ),
          ],
        ),
      );
    }

    final crossAxisCount = _getCrossAxisCount(isMobile, isTablet);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: filteredSubjects.length,
      itemBuilder: (context, index) {
        final subject = filteredSubjects[index];
        final isSelected = selectedSubjectId == subject.key;
        final subjectData = Map<String, dynamic>.from(subject.value);

        return _AnimatedSelectionCard(
          title: subjectData['name'] ?? subject.key,
          subtitle: 'Subject',
          isSelected: isSelected,
          isMobile: isMobile,
          onTap: () {
            setState(() {
              selectedSubjectId = subject.key;
            });
          },
        );
      },
    );
  }

  int _getCrossAxisCount(bool isMobile, bool isTablet) {
    if (isMobile) return 1;
    if (isTablet) return 2;
    return 3;
  }

  Widget _buildContinueButton(bool isMobile) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedBuilder(
        animation: _buttonController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: isMobile ? 54 : 60,
            decoration: BoxDecoration(
              color: const Color(0xFF000000),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000).withOpacity(
                    0.1 + (_buttonController.value * 0.15),
                  ),
                  blurRadius: 20 + (_buttonController.value * 10),
                  offset: Offset(0, 4 + (_buttonController.value * 4)),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (widget.onViewNotes != null) {
                    widget.onViewNotes!(
                      'btech',
                      selectedBranchId!,
                      selectedSubjectId!,
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotesListPage(
                          degreeId: 'btech',
                          branchId: selectedBranchId!,
                          subjectId: selectedSubjectId!,
                        ),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'View Notes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 15 : 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 8 + (_buttonController.value * 4)),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: isMobile ? 18 : 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedSelectionCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final bool isMobile;
  final VoidCallback onTap;
  final double? width;

  const _AnimatedSelectionCard({
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.isMobile,
    required this.onTap,
    this.width,
  });

  @override
  State<_AnimatedSelectionCard> createState() => _AnimatedSelectionCardState();
}

class _AnimatedSelectionCardState extends State<_AnimatedSelectionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: widget.isSelected ? 1.0 : (_isHovered ? 1.02 : 1.0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          decoration: BoxDecoration(
            color: widget.isSelected ? const Color(0xFF000000) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected 
                  ? const Color(0xFF000000)
                  : (_isHovered ? const Color(0xFF000000) : const Color(0xFFE5E5E0)),
              width: widget.isSelected ? 2 : 1.5,
            ),
            boxShadow: [
              if (_isHovered || widget.isSelected)
                BoxShadow(
                  color: const Color(0xFF000000).withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.all(widget.isMobile ? 16 : 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              color: widget.isSelected 
                                  ? Colors.white 
                                  : const Color(0xFF000000),
                              fontSize: widget.isMobile ? 14 : 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle!,
                              style: TextStyle(
                                color: widget.isSelected 
                                    ? Colors.white70 
                                    : const Color(0xFF666666),
                                fontSize: widget.isMobile ? 11 : 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.isSelected)
                      AnimatedScale(
                        scale: 1.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Color(0xFF000000),
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
           ),
          ),
        ),
      ),
    );
  }
}