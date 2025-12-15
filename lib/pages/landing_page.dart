import 'package:flutter/material.dart';
import 'package:notes_sharing/auth/signup_page.dart';
import '../auth/login_page.dart';

class NoteVerseLandingPage extends StatefulWidget {
  const NoteVerseLandingPage({super.key});

  @override
  State<NoteVerseLandingPage> createState() => _NoteVerseLandingPageState();
}

class _NoteVerseLandingPageState extends State<NoteVerseLandingPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _isScrolled = _scrollController.offset > 50;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Header
          SliverAppBar(
            backgroundColor: _isScrolled
                ? const Color(0xFFFAFAF8).withOpacity(0.95)
                : Colors.transparent,
            elevation: _isScrolled ? 1 : 0,
            surfaceTintColor: Colors.transparent,
            floating: false,
            pinned: true,
            expandedHeight: 0,
            toolbarHeight: 80,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFFFAFAF8),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'NoteVerse',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            color: Color(0xFF4A4A4A),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A1A),
                          foregroundColor: const Color(0xFFFAFAF8),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Hero Section
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Animated Background Elements
                Positioned(
                  top: 100,
                  left: -50,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E3).withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  right: -80,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4D4CC).withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 100),
                  child: Column(
                    children: [
                      // Main Content
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8E8E3),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Text(
                                    'Share Knowledge and Ace Exams',
                                    style: TextStyle(
                                      color: Color(0xFF3A3A3A),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 36),

                                // Main Heading
                                const Text(
                                  'Share Notes,',
                                  style: TextStyle(
                                    fontSize: 68,
                                    fontWeight: FontWeight.w800,
                                    height: 1.1,
                                    color: Color(0xFF1A1A1A),
                                    letterSpacing: -2,
                                  ),
                                ),
                                const Text(
                                  'Collaborate Better',
                                  style: TextStyle(
                                    fontSize: 68,
                                    fontWeight: FontWeight.w800,
                                    height: 1.1,
                                    color: Color(0xFF1A1A1A),
                                    letterSpacing: -2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'with NoteVerse',
                                  style: TextStyle(
                                    fontSize: 68,
                                    fontWeight: FontWeight.w300,
                                    height: 1.1,
                                    color: Color(0xFF6A6A6A),
                                    letterSpacing: -2,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Description
                                const Text(
                                  'Connect with students across your semester and branch.\nShare notes, ace exams, and build a community of learners.\nAll subjects, all semesters, one platform.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF5A5A5A),
                                    height: 1.7,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 48),

                                // CTA Button
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const SignupPage()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A1A1A),
                                    foregroundColor: const Color(0xFFFAFAF8),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 48,
                                      vertical: 22,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Get Started Free',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(Icons.arrow_forward, size: 18),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 70),

                                // Stats
                                Container(
                                  padding: const EdgeInsets.only(top: 36),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: Color(0xFFE0E0D8),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildStat('10K+', 'Active Students'),
                                      const SizedBox(width: 60),
                                      _buildStat('500+', 'Subjects'),
                                      const SizedBox(width: 60),
                                      _buildStat('50K+', 'Notes Shared'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 80),

                          // Right Content - AI Card
                          Expanded(
                            child: Container(
                              height: 480,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8E8E3),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: const Color(0xFFD4D4CC),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(48),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1A1A1A),
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        child: const Icon(
                                          Icons.auto_awesome,
                                          size: 50,
                                          color: Color(0xFFFAFAF8),
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      const Text(
                                        'AI-Powered Notes',
                                        style: TextStyle(
                                          color: Color(0xFF1A1A1A),
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Generate comprehensive summaries\ninstantly with AI',
                                        style: TextStyle(
                                          color: Color(0xFF5A5A5A),
                                          fontSize: 16,
                                          height: 1.6,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Features Section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 120),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE0E0D8),
                    width: 1.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Section Header
                  Column(
                    children: [
                      const Text(
                        'Everything You Need',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -1.5,
                        ),
                      ),
                      const Text(
                        'to Succeed',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF6A6A6A),
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Powerful features designed for students, by students',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF5A5A5A),
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),

                  // Features Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _features.length,
                    itemBuilder: (context, index) {
                      final feature = _features[index];
                      return _buildFeatureCard(feature);
                    },
                  ),
                ],
              ),
            ),
          ),

          // CTA Section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 120),
              decoration: const BoxDecoration(
                color: Color(0xFFE8E8E3),
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFD4D4CC),
                    width: 1.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Column(
                    children: [
                      const Text(
                        'Ready to Join',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -1.5,
                        ),
                      ),
                      const Text(
                        'NoteVerse?',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF6A6A6A),
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Start sharing and collaborating with thousands of students today',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF5A5A5A),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      foregroundColor: const Color(0xFFFAFAF8),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 56,
                        vertical: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Join Now - Free Forever',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 120),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE0E0D8),
                    width: 1.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Footer Links
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFooterColumn('Product', _productLinks),
                      const SizedBox(width: 80),
                      _buildFooterColumn('Company', _companyLinks),
                      const SizedBox(width: 80),
                      _buildFooterColumn('Legal', _legalLinks),
                      const SizedBox(width: 80),
                      _buildFooterColumn('Social', _socialLinks),
                    ],
                  ),
                  const SizedBox(height: 50),

                  // Bottom Bar
                  Container(
                    padding: const EdgeInsets.only(top: 36),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Color(0xFFE0E0D8),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '© 2025 NoteVerse. All rights reserved.',
                          style: TextStyle(
                            color: Color(0xFF6A6A6A),
                            fontSize: 14,
                            letterSpacing: 0.2,
                          ),
                        ),
                        Text(
                          'Made with passion for students',
                          style: TextStyle(
                            color: Color(0xFF6A6A6A),
                            fontSize: 14,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
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

  Widget _buildStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF5A5A5A),
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(Map<String, String> feature) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE0E0D8),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              feature['icon']!,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 20),
            Text(
              feature['title']!,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              feature['desc']!,
              style: const TextStyle(
                color: Color(0xFF5A5A5A),
                fontSize: 15,
                height: 1.6,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterColumn(String title, List<Map<String, String>> links) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: links.map((link) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      link['label']!,
                      style: const TextStyle(
                        color: Color(0xFF5A5A5A),
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  final List<Map<String, String>> _features = [
    {
      'icon': '🤖',
      'title': 'AI Note Generation',
      'desc': 'Generate comprehensive notes from lectures with AI-powered summaries',
    },
    {
      'icon': '🎓',
      'title': 'All Semesters',
      'desc': 'Access notes from every semester and year',
    },
    {
      'icon': '🏢',
      'title': 'Multiple Branches',
      'desc': 'Connect across different branches and departments',
    },
    {
      'icon': '🔍',
      'title': 'Smart Search',
      'desc': 'Find notes instantly with advanced filters',
    },
    {
      'icon': '👥',
      'title': 'Community',
      'desc': 'Learn together with peers and collaborate',
    },
    {
      'icon': '⚡',
      'title': 'Real-time Sync',
      'desc': 'Updates instantly across all your devices',
    },
  ];

  final List<Map<String, String>> _productLinks = [
    {'label': 'Features'},
    {'label': 'Pricing'},
    {'label': 'Security'},
  ];

  final List<Map<String, String>> _companyLinks = [
    {'label': 'About'},
    {'label': 'Blog'},
    {'label': 'Contact'},
  ];

  final List<Map<String, String>> _legalLinks = [
    {'label': 'Privacy'},
    {'label': 'Terms'},
    {'label': 'Cookies'},
  ];

  final List<Map<String, String>> _socialLinks = [
    {'label': 'Twitter'},
    {'label': 'Discord'},
    {'label': 'GitHub'},
  ];
}