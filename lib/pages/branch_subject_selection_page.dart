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
    extends State<BranchSubjectSelectionPage> {
  String? selectedYear;
  String? selectedSemester;
  String? selectedBranchId;
  String? selectedSubjectId;

  List<String> yearOptions = ['1', '2', '3', '4'];
  List<String> semesterOptions = [];
  Map<String, dynamic> branches = {};
  Map<String, dynamic> subjects = {};

  @override
  void initState() {
    super.initState();
    _loadBranches();
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
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Select Your Course',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF1A2332),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (selectedYear != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: _resetSelections,
              tooltip: 'Reset Selection',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Indicator
            _buildProgressIndicator(),
            SizedBox(height: isMobile ? 24 : 32),

            // Year Selection
            _buildSectionHeader(
              title: 'Select Year',
              subtitle: 'Choose your academic year',
              icon: Icons.school,
              isMobile: isMobile,
            ),
            const SizedBox(height: 12),
            _buildYearGrid(isMobile),
            SizedBox(height: isMobile ? 24 : 32),

            // Semester Selection
            if (selectedYear != null) ...[
              _buildSectionHeader(
                title: 'Select Semester',
                subtitle: 'Choose your current semester',
                icon: Icons.date_range,
                isMobile: isMobile,
              ),
              const SizedBox(height: 12),
              _buildSemesterGrid(isMobile, isTablet),
              SizedBox(height: isMobile ? 24 : 32),
            ],

            // Branch Selection
            if (selectedSemester != null) ...[
              _buildSectionHeader(
                title: 'Select Branch',
                subtitle: 'Choose your department',
                icon: Icons.architecture,
                isMobile: isMobile,
              ),
              const SizedBox(height: 12),
              _buildBranchGrid(isMobile, isTablet),
              SizedBox(height: isMobile ? 24 : 32),
            ],

            // Subject Selection
            if (selectedBranchId != null && subjects.isNotEmpty) ...[
              _buildSectionHeader(
                title: 'Select Subject',
                subtitle: 'Choose your subject',
                icon: Icons.menu_book,
                isMobile: isMobile,
              ),
              const SizedBox(height: 12),
              _buildSubjectGrid(filteredSubjects, isMobile, isTablet),
              SizedBox(height: isMobile ? 24 : 32),
            ],

            // Continue Button
            if (selectedBranchId != null && selectedSubjectId != null) ...[
              _buildContinueButton(isMobile),
              const SizedBox(height: 16),
            ],

            // Add some extra space at the bottom
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final totalSteps = 4;
    var completedSteps = 0;
    if (selectedYear != null) completedSteps++;
    if (selectedSemester != null) completedSteps++;
    if (selectedBranchId != null) completedSteps++;
    if (selectedSubjectId != null) completedSteps++;

    return Column(
      children: [
        LinearProgressIndicator(
          value: completedSteps / totalSteps,
          backgroundColor: const Color(0xFF334155),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
          borderRadius: BorderRadius.circular(8),
          minHeight: 6,
        ),
        const SizedBox(height: 6),
        Text(
          'Step $completedSteps of $totalSteps',
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isMobile,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF10B981).withOpacity(0.3),
            ),
          ),
          child: Icon(icon, color: const Color(0xFF10B981), size: isMobile ? 16 : 18),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: const Color(0xFF94A3B8),
                fontSize: isMobile ? 11 : 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildYearGrid(bool isMobile) {
    final double height = isMobile ? 60 : 70;
    final double spacing = isMobile ? 8 : 10;
    final double aspectRatio = isMobile ? 0.8 : 0.7;

    return SizedBox(
      height: height,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: spacing,
          childAspectRatio: aspectRatio,
        ),
        itemCount: yearOptions.length,
        itemBuilder: (context, index) {
          final year = yearOptions[index];
          final isSelected = selectedYear == year;
          return _buildSelectionCard(
            title: 'Year $year',
            isSelected: isSelected,
            isMobile: isMobile,
            onTap: () {
              setState(() {
                selectedYear = year;
                selectedSemester = null;
                selectedBranchId = null;
                selectedSubjectId = null;
                _updateSemestersForYear(year);
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildSemesterGrid(bool isMobile, bool isTablet) {
    final crossAxisCount = _getCrossAxisCount(isMobile, isTablet);
    final double spacing = isMobile ? 8 : 10;
    final double aspectRatio = isMobile ? 2.2 : (isTablet ? 2.5 : 3);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: semesterOptions.length,
      itemBuilder: (context, index) {
        final semester = semesterOptions[index];
        final isSelected = selectedSemester == semester;
        return _buildSelectionCard(
          title: 'Semester $semester',
          subtitle: 'Year $selectedYear',
          isSelected: isSelected,
          isMobile: isMobile,
          onTap: () {
            setState(() {
              selectedSemester = semester;
              selectedBranchId = null;
              selectedSubjectId = null;
            });
          },
        );
      },
    );
  }

  Widget _buildBranchGrid(bool isMobile, bool isTablet) {
    final crossAxisCount = _getCrossAxisCount(isMobile, isTablet);
    final double spacing = isMobile ? 8 : 10;
    final double aspectRatio = isMobile ? 1.2 : (isTablet ? 1.5 : 1.8);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: branches.entries.length,
      itemBuilder: (context, index) {
        final branch = branches.entries.elementAt(index);
        final isSelected = selectedBranchId == branch.key;
        return _buildSelectionCard(
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: isMobile ? 32 : 40,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 12),
            Text(
              'No subjects found',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No subjects available for Year $selectedYear, Semester $selectedSemester',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF94A3B8),
                fontSize: isMobile ? 10 : 12,
              ),
            ),
          ],
        ),
      );
    }

    final crossAxisCount = _getCrossAxisCount(isMobile, isTablet);
    final double spacing = isMobile ? 8 : 10;
    final double aspectRatio = isMobile ? 1.5 : (isTablet ? 1.8 : 2);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: filteredSubjects.length,
      itemBuilder: (context, index) {
        final subject = filteredSubjects[index];
        final isSelected = selectedSubjectId == subject.key;
        final subjectData = Map<String, dynamic>.from(subject.value);

        return _buildSelectionCard(
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
    if (isMobile) return 2;
    if (isTablet) return 3;
    return 4;
  }

  Widget _buildSelectionCard({
    required String title,
    String? subtitle,
    required bool isSelected,
    required bool isMobile,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      color: isSelected ? const Color(0xFF10B981).withOpacity(0.15) : const Color(0xFF1A2332),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? const Color(0xFF10B981) : const Color(0xFF334155),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 10 : 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF10B981) : Colors.white,
                  fontSize: isMobile ? 12 : 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontSize: isMobile ? 9 : 10,
                  ),
                ),
              ],
              if (isSelected) ...[
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
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
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_forward, color: Colors.white, size: isMobile ? 18 : 20),
            SizedBox(width: isMobile ? 6 : 8),
            Text(
              'View Notes',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}