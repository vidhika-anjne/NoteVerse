// import 'package:flutter/material.dart';
// import 'notes_list_page.dart';
//
// class BranchSubjectSelectionPage extends StatefulWidget {
//   const BranchSubjectSelectionPage({super.key});
//
//   @override
//   State<BranchSubjectSelectionPage> createState() => _BranchSubjectSelectionPageState();
// }
//
// class _BranchSubjectSelectionPageState extends State<BranchSubjectSelectionPage> {
//   String? selectedBranch;
//   String? selectedSubject;
//
//   final Map<String, List<String>> subjectsByBranch = {
//     'cse': ['BT-101', 'BT-102', 'BT-103'],
//     'it': ['IT-BT101', 'IT-BT102', 'IT-IT501'],
//     'aiml': ['AL-301', 'AL-401', 'AL-501'],
//   };
//
//   @override
//   Widget build(BuildContext context) {
//     final branches = subjectsByBranch.keys.toList();
//     final subjects = selectedBranch != null ? subjectsByBranch[selectedBranch]! : [];
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Select Branch & Subject')),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             // 🔹 Dropdown for branch
//             DropdownButtonFormField<String>(
//               decoration: const InputDecoration(labelText: 'Select Branch'),
//               value: selectedBranch,
//               items: branches
//                   .map((b) => DropdownMenuItem(value: b, child: Text(b.toUpperCase())))
//                   .toList(),
//               onChanged: (val) {
//                 setState(() {
//                   selectedBranch = val;
//                   selectedSubject = null;
//                 });
//               },
//             ),
//             const SizedBox(height: 20),
//             // 🔹 Dropdown for subject
//             DropdownButtonFormField<String>(
//               decoration: const InputDecoration(labelText: 'Select Subject'),
//               value: selectedSubject,
//               items: subjects
//                   .map((s) => DropdownMenuItem<String>(
//                 value: s,
//                 child: Text(s),
//               ))
//                   .toList(),
//               onChanged: (val) {
//                 setState(() {
//                   selectedSubject = val;
//                 });
//               },
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton.icon(
//               onPressed: (selectedBranch != null && selectedSubject != null)
//                   ? () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => NotesListPage(
//                       universityId: 'rgpv',
//                       degreeId: 'btech',
//                       branchId: selectedBranch!,
//                       subjectId: selectedSubject!,
//                     ),
//                   ),
//                 );
//               }
//                   : null,
//               icon: const Icon(Icons.arrow_forward),
//               label: const Text('Continue'),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// ------------------------------------------------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'notes_list_page.dart';
//
// class BranchSubjectSelectionPage extends StatefulWidget {
//   const BranchSubjectSelectionPage({super.key});
//
//   @override
//   State<BranchSubjectSelectionPage> createState() => _BranchSubjectSelectionPageState();
// }
//
// class _BranchSubjectSelectionPageState extends State<BranchSubjectSelectionPage> {
//   final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('universities/rgpv/degrees/btech/branches');
//
//   String? selectedYear;
//   String? selectedSemester;
//   String? selectedBranchId;
//   String? selectedSubjectId;
//
//   List<String> years = ['1', '2', '3', '4'];
//   List<String> semesters = ['1', '2', '3', '4', '5', '6', '7', '8'];
//
//   Map<String, dynamic> branches = {};
//   Map<String, dynamic> subjects = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchBranches();
//   }
//
//   Future<void> _fetchBranches() async {
//     final snapshot = await _dbRef.get();
//     if (snapshot.exists) {
//       setState(() {
//         branches = Map<String, dynamic>.from(snapshot.value as Map);
//       });
//     }
//   }
//
//   Future<void> _fetchSubjects(String branchId) async {
//     final snapshot = await _dbRef.child('$branchId/subjects').get();
//     if (snapshot.exists) {
//       setState(() {
//         subjects = Map<String, dynamic>.from(snapshot.value as Map);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Filter subjects by selected year and semester
//     final filteredSubjects = subjects.entries.where((entry) {
//       final val = Map<String, dynamic>.from(entry.value);
//       final yearMatch = selectedYear == null || val['year'].toString() == selectedYear;
//       final semMatch = selectedSemester == null || val['semester'].toString() == selectedSemester;
//       return yearMatch && semMatch;
//     }).toList();
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Select Year, Branch & Subject')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(labelText: 'Select Year'),
//                 value: selectedYear,
//                 items: years.map((y) => DropdownMenuItem(value: y, child: Text('Year $y'))).toList(),
//                 onChanged: (val) {
//                   setState(() {
//                     selectedYear = val;
//                     selectedSemester = null;
//                     selectedBranchId = null;
//                     selectedSubjectId = null;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//               if (selectedYear != null)
//                 DropdownButtonFormField<String>(
//                   decoration: const InputDecoration(labelText: 'Select Semester'),
//                   value: selectedSemester,
//                   items: semesters.map((s) => DropdownMenuItem(value: s, child: Text('Semester $s'))).toList(),
//                   onChanged: (val) {
//                     setState(() {
//                       selectedSemester = val;
//                       selectedBranchId = null;
//                       selectedSubjectId = null;
//                     });
//                   },
//                 ),
//               const SizedBox(height: 16),
//               if (selectedSemester != null)
//                 DropdownButtonFormField<String>(
//                   decoration: const InputDecoration(labelText: 'Select Branch'),
//                   value: selectedBranchId,
//                   items: branches.entries
//                       .map((e) => DropdownMenuItem(
//                     value: e.key,
//                     child: Text((e.value['name'] ?? e.key).toString()),
//                   ))
//                       .toList(),
//                   onChanged: (val) async {
//                     setState(() {
//                       selectedBranchId = val;
//                       selectedSubjectId = null;
//                       subjects.clear();
//                     });
//                     if (val != null) await _fetchSubjects(val);
//                   },
//                 ),
//               const SizedBox(height: 16),
//               if (selectedBranchId != null && subjects.isNotEmpty)
//                 DropdownButtonFormField<String>(
//                   decoration: const InputDecoration(labelText: 'Select Subject'),
//                   value: selectedSubjectId,
//                   items: filteredSubjects
//                       .map(
//                         (entry) => DropdownMenuItem(
//                       value: entry.key,
//                       child: Text(entry.value['name'] ?? entry.key),
//                     ),
//                   )
//                       .toList(),
//                   onChanged: (val) {
//                     setState(() => selectedSubjectId = val);
//                   },
//                 ),
//               const SizedBox(height: 24),
//               ElevatedButton.icon(
//                 onPressed: (selectedBranchId != null && selectedSubjectId != null)
//                     ? () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => NotesListPage(
//                         // universityId: 'rgpv',
//                         degreeId: 'btech',
//                         branchId: selectedBranchId!,
//                         subjectId: selectedSubjectId!,
//                       ),
//                     ),
//                   );
//                 }
//                     : null,
//                 icon: const Icon(Icons.arrow_forward),
//                 label: const Text('View Notes'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// --------------------------------------------------------------------------------------


import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'notes_list_page.dart';

class BranchSubjectSelectionPage extends StatefulWidget {
  const BranchSubjectSelectionPage({super.key});

  @override
  State<BranchSubjectSelectionPage> createState() =>
      _BranchSubjectSelectionPageState();
}

class _BranchSubjectSelectionPageState
    extends State<BranchSubjectSelectionPage> {
  final DatabaseReference _dbRef =
  FirebaseDatabase.instance.ref('degrees/btech/branches');

  String? selectedYear;
  String? selectedSemester;
  String? selectedBranchId;
  String? selectedSubjectId;

  // dynamic lists
  List<String> yearOptions = ['1', '2', '3', '4'];
  List<String> semesterOptions = [];
  Map<String, dynamic> branches = {};
  Map<String, dynamic> subjects = {};

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  // 🔹 Load all branches once
  Future<void> _loadBranches() async {
    final snapshot = await _dbRef.get();
    if (snapshot.exists) {
      setState(() {
        branches = Map<String, dynamic>.from(snapshot.value as Map);
      });
    }
  }

  // 🔹 Load subjects for the selected branch
  Future<void> _loadSubjects(String branchId) async {
    final snapshot = await _dbRef.child('$branchId/subjects').get();
    if (snapshot.exists) {
      setState(() {
        subjects = Map<String, dynamic>.from(snapshot.value as Map);
      });
    } else {
      setState(() {
        subjects = {};
      });
    }
  }

  // 🔹 Auto-adjust semesters based on year
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

  @override
  Widget build(BuildContext context) {
    // 🔹 Filter subjects based on selected year & semester
    final filteredSubjects = subjects.entries.where((entry) {
      final val = Map<String, dynamic>.from(entry.value);
      final yearMatch = selectedYear == null ||
          val['year'].toString() == selectedYear.toString();
      final semMatch = selectedSemester == null ||
          val['semester'].toString() == selectedSemester.toString();
      return yearMatch && semMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Select Course')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🔸 Year dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Year'),
                value: selectedYear,
                items: yearOptions
                    .map((y) =>
                    DropdownMenuItem(value: y, child: Text('Year $y')))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedYear = val;
                    selectedSemester = null;
                    selectedBranchId = null;
                    selectedSubjectId = null;
                    _updateSemestersForYear(val!);
                  });
                },
              ),
              const SizedBox(height: 16),

              // 🔸 Semester dropdown (only valid ones)
              if (selectedYear != null)
                DropdownButtonFormField<String>(
                  decoration:
                  const InputDecoration(labelText: 'Select Semester'),
                  value: selectedSemester,
                  items: semesterOptions
                      .map((s) => DropdownMenuItem(
                      value: s, child: Text('Semester $s')))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedSemester = val;
                      selectedBranchId = null;
                      selectedSubjectId = null;
                    });
                  },
                ),
              const SizedBox(height: 16),

              // 🔸 Branch dropdown
              if (selectedSemester != null)
                DropdownButtonFormField<String>(
                  decoration:
                  const InputDecoration(labelText: 'Select Branch'),
                  value: selectedBranchId,
                  items: branches.entries
                      .map((e) => DropdownMenuItem(
                    value: e.key,
                    child:
                    Text((e.value['name'] ?? e.key).toString()),
                  ))
                      .toList(),
                  onChanged: (val) async {
                    setState(() {
                      selectedBranchId = val;
                      selectedSubjectId = null;
                      subjects.clear();
                    });
                    if (val != null) await _loadSubjects(val);
                  },
                ),
              const SizedBox(height: 16),

              // 🔸 Subject dropdown (filtered)
              if (selectedBranchId != null && subjects.isNotEmpty)
                DropdownButtonFormField<String>(
                  decoration:
                  const InputDecoration(labelText: 'Select Subject'),
                  value: selectedSubjectId,
                  items: filteredSubjects
                      .map((entry) => DropdownMenuItem(
                    value: entry.key,
                    child:
                    Text(entry.value['name'] ?? entry.key),
                  ))
                      .toList(),
                  onChanged: (val) {
                    setState(() => selectedSubjectId = val);
                  },
                ),
              const SizedBox(height: 24),

              // 🔸 Continue button
              ElevatedButton.icon(
                onPressed: (selectedBranchId != null &&
                    selectedSubjectId != null)
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotesListPage(
                        degreeId: 'btech',
                        branchId: selectedBranchId!,
                        subjectId: selectedSubjectId!,
                        // universityId: '', // optional placeholder
                      ),
                    ),
                  );
                }
                    : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('View Notes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
