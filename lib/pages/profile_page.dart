import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';
import 'profile_setup_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedTab = 0;
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final profileProvider = context.read<UserProfileProvider>();
      profileProvider.loadCurrentUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profileProvider = context.watch<UserProfileProvider>();
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive values
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    if (profileProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: const Color(0xFF000000)),
      );
    }

    if (auth.firebaseUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              color: const Color(0xFF666666),
              size: isMobile ? 40 : 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Please sign in to view profile',
              style: TextStyle(
                color: const Color(0xFF000000),
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ],
        ),
      );
    }

    final profileData = profileProvider.currentProfile;

    if (profileData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add,
              color: const Color(0xFF000000),
              size: isMobile ? 40 : 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Profile Setup Required',
              style: TextStyle(
                color: const Color(0xFF000000),
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final user = auth.firebaseUser;
                if (user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileSetupPage(userId: user.uid),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000000),
              ),
              child: const Text('Setup Profile'),
            ),
          ],
        ),
      );
    }

    // Extract profile data
    final String name = profileData["name"] ?? "Unknown";
    final String email =
        profileData["email"] ?? auth.firebaseUser?.email ?? "No Email";
    final String role = profileData["role"] ?? "student";
    final String photoUrl = profileData["photoUrl"] ?? "";
    final String username = profileData["username"] ?? "";
    final String gender = profileData["gender"] ?? "Not specified";
    final String linkedin = profileData["linkedin"] ?? "";
    final String bio = profileData["bio"] ?? "";
    final int createdAtMillis = profileData["createdAt"] is int
        ? profileData["createdAt"] as int
        : int.tryParse('${profileData["createdAt"] ?? ''}') ?? 0;
    final DateTime? createdAt = createdAtMillis > 0
        ? DateTime.fromMillisecondsSinceEpoch(createdAtMillis)
        : null;
    final int savedCount = profileProvider.savedNotes.length;

    // Mock data
    final int notesCount = 43;
    final int followersCount = 892;
    final int followingCount = 234;

    return Container(
      color: const Color(0xFFF5F5F0),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : isTablet ? 40 : 120,
            vertical: isMobile ? 20 : 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with Photo, Name, and Buttons
              if (isMobile)
                _buildMobileHeader(
                  name: name,
                  username: username,
                  role: role,
                  photoUrl: photoUrl,
                  auth: auth,
                )
              else
                _buildDesktopHeader(
                  name: name,
                  username: username,
                  role: role,
                  photoUrl: photoUrl,
                  auth: auth,
                  isTablet: isTablet,
                ),

              SizedBox(height: isMobile ? 32 : 48),

              // Stats Grid
              Container(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: const Color(0xFFD0D0D0), width: 1),
                    bottom: BorderSide(color: const Color(0xFFD0D0D0), width: 1),
                  ),
                ),
                child: isMobile
                    ? _buildMobileStats(
                        notesCount: notesCount,
                        savedCount: savedCount,
                        followersCount: followersCount,
                        followingCount: followingCount,
                      )
                    : _buildDesktopStats(
                        notesCount: notesCount,
                        savedCount: savedCount,
                        followersCount: followersCount,
                        followingCount: followingCount,
                        isTablet: isTablet,
                      ),
              ),

              SizedBox(height: isMobile ? 24 : 40),

              // ABOUT Section
              const Text(
                'ABOUT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF999999),
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: isMobile ? 12 : 16),

              // Bio
              if (bio.isNotEmpty)
                Text(
                  bio,
                  style: TextStyle(
                    color: const Color(0xFF000000),
                    fontSize: isMobile ? 14 : 16,
                    height: 1.6,
                  ),
                ),

              if (bio.isNotEmpty) SizedBox(height: isMobile ? 20 : 24),

              // Details Grid
              isMobile
                  ? _buildMobileDetails(
                      email: email,
                      createdAt: createdAt,
                      linkedin: linkedin,
                      gender: gender,
                    )
                  : _buildDesktopDetails(
                      email: email,
                      createdAt: createdAt,
                      linkedin: linkedin,
                      gender: gender,
                      isTablet: isTablet,
                    ),

              SizedBox(height: isMobile ? 32 : 48),

              // Tabs
              isMobile
                  ? _buildMobileTabs(
                      selectedTab: _selectedTab,
                      onTabChanged: (index) => setState(() => _selectedTab = index),
                    )
                  : _buildDesktopTabs(
                      selectedTab: _selectedTab,
                      onTabChanged: (index) => setState(() => _selectedTab = index),
                      isTablet: isTablet,
                    ),

              SizedBox(height: isMobile ? 16 : 24),

              // Content Area - Empty State
              Container(
                height: isMobile ? 160 : 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E5E0)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getTabIcon(_selectedTab),
                        size: isMobile ? 36 : 48,
                        color: const Color(0xFFCCCCCC),
                      ),
                      SizedBox(height: isMobile ? 8 : 12),
                      Text(
                        _getTabMessage(_selectedTab),
                        style: TextStyle(
                          color: const Color(0xFF999999),
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileHeader({
    required String name,
    required String username,
    required String role,
    required String photoUrl,
    required AuthProvider auth,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Profile Photo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE5E5E0),
              width: 4,
            ),
          ),
          child: photoUrl.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                  ),
                )
              : CircleAvatar(
                  backgroundColor: const Color(0xFFE5E5E0),
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 16),
        
        // Name and Username
        Column(
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF000000),
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            if (username.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '@$username',
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Role Badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E5E0),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            role.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF000000),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Edit Profile and Share Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                final user = auth.firebaseUser;
                if (user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileSetupPage(userId: user.uid),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000000),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD0D0D0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share),
                iconSize: 18,
                color: const Color(0xFF000000),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopHeader({
    required String name,
    required String username,
    required String role,
    required String photoUrl,
    required AuthProvider auth,
    required bool isTablet,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Photo
        Container(
          width: isTablet ? 100 : 140,
          height: isTablet ? 100 : 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE5E5E0),
              width: 4,
            ),
          ),
          child: photoUrl.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                  ),
                )
              : CircleAvatar(
                  backgroundColor: const Color(0xFFE5E5E0),
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: isTablet ? 32 : 48,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF000000),
                    ),
                  ),
                ),
        ),
        SizedBox(width: isTablet ? 24 : 48),
        
        // Name, Username, Role Section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Name
              Text(
                name,
                style: TextStyle(
                  fontSize: isTablet ? 28 : 36,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF000000),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              
              // Username
              if (username.isNotEmpty)
                Text(
                  '@$username',
                  style: TextStyle(
                    color: const Color(0xFF666666),
                    fontSize: isTablet ? 16 : 18,
                    height: 1.3,
                  ),
                ),
              
              SizedBox(height: isTablet ? 12 : 16),
              
              // Role Badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : 16,
                  vertical: isTablet ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    color: const Color(0xFF000000),
                    fontSize: isTablet ? 12 : 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              
              SizedBox(height: isTablet ? 16 : 20),
              
              // Edit Profile and Share Buttons
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      final user = auth.firebaseUser;
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileSetupPage(userId: user.uid),
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.edit, size: isTablet ? 16 : 18),
                    label: Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000000),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 20,
                        vertical: isTablet ? 10 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                  SizedBox(width: isTablet ? 10 : 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD0D0D0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.share),
                      iconSize: isTablet ? 18 : 20,
                      color: const Color(0xFF000000),
                      padding: EdgeInsets.all(isTablet ? 8 : 10),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileStats({
    required int notesCount,
    required int savedCount,
    required int followersCount,
    required int followingCount,
  }) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _StatItem(
          count: notesCount,
          label: 'Notes',
          isMobile: true,
        ),
        _StatItem(
          count: savedCount,
          label: 'Saved',
          isMobile: true,
        ),
        _StatItem(
          count: followersCount,
          label: 'Followers',
          isMobile: true,
        ),
        _StatItem(
          count: followingCount,
          label: 'Following',
          isMobile: true,
        ),
      ],
    );
  }

  Widget _buildDesktopStats({
    required int notesCount,
    required int savedCount,
    required int followersCount,
    required int followingCount,
    required bool isTablet,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _StatItem(
          count: notesCount,
          label: 'Notes',
          isDesktop: true,
        ),
        SizedBox(width: isTablet ? 40 : 80),
        _StatItem(
          count: savedCount,
          label: 'Saved',
          isDesktop: true,
        ),
        SizedBox(width: isTablet ? 40 : 80),
        _StatItem(
          count: followersCount,
          label: 'Followers',
          isDesktop: true,
        ),
        SizedBox(width: isTablet ? 40 : 80),
        _StatItem(
          count: followingCount,
          label: 'Following',
          isDesktop: true,
        ),
      ],
    );
  }

  Widget _buildMobileDetails({
    required String email,
    required DateTime? createdAt,
    required String linkedin,
    required String gender,
  }) {
    return Column(
      children: [
        _DetailItem(
          icon: Icons.email_outlined,
          text: email,
          isMobile: true,
        ),
        const SizedBox(height: 12),
        if (createdAt != null)
          _DetailItem(
            icon: Icons.calendar_today_outlined,
            text: 'Member since ${_formatDate(createdAt)}',
            isMobile: true,
          ),
        if (linkedin.isNotEmpty) ...[
          const SizedBox(height: 12),
          _DetailItem(
            icon: Icons.link_outlined,
            text: linkedin,
            isLink: true,
            isMobile: true,
          ),
        ],
        const SizedBox(height: 12),
        _DetailItem(
          icon: Icons.person_outline,
          text: 'Gender:   $gender',
          isMobile: true,
        ),
      ],
    );
  }

  Widget _buildDesktopDetails({
    required String email,
    required DateTime? createdAt,
    required String linkedin,
    required String gender,
    required bool isTablet,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _DetailItem(
                icon: Icons.email_outlined,
                text: email,
              ),
              SizedBox(height: isTablet ? 12 : 16),
              if (createdAt != null)
                _DetailItem(
                  icon: Icons.calendar_today_outlined,
                  text: 'Member since ${_formatDate(createdAt)}',
                ),
            ],
          ),
        ),
        SizedBox(width: isTablet ? 40 : 80),
        Expanded(
          child: Column(
            children: [
              if (linkedin.isNotEmpty)
                _DetailItem(
                  icon: Icons.link_outlined,
                  text: linkedin,
                  isLink: true,
                ),
              SizedBox(height: isTablet ? 12 : 16),
              _DetailItem(
                icon: Icons.person_outline,
                text: 'Gender:   $gender',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTabs({
    required int selectedTab,
    required Function(int) onTabChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: _TabItem(
            icon: Icons.description_outlined,
            label: 'My Notes',
            isSelected: selectedTab == 0,
            onTap: () => onTabChanged(0),
            isMobile: true,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _TabItem(
            icon: Icons.bookmark_outline,
            label: 'Saved',
            isSelected: selectedTab == 1,
            onTap: () => onTabChanged(1),
            isMobile: true,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _TabItem(
            icon: Icons.favorite_outline,
            label: 'Liked',
            isSelected: selectedTab == 2,
            onTap: () => onTabChanged(2),
            isMobile: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTabs({
    required int selectedTab,
    required Function(int) onTabChanged,
    required bool isTablet,
  }) {
    return Row(
      children: [
        _TabItem(
          icon: Icons.description_outlined,
          label: 'My Notes',
          isSelected: selectedTab == 0,
          onTap: () => onTabChanged(0),
          isTablet: isTablet,
        ),
        SizedBox(width: isTablet ? 8 : 8),
        _TabItem(
          icon: Icons.bookmark_outline,
          label: 'Saved',
          isSelected: selectedTab == 1,
          onTap: () => onTabChanged(1),
          isTablet: isTablet,
        ),
        SizedBox(width: isTablet ? 8 : 8),
        _TabItem(
          icon: Icons.favorite_outline,
          label: 'Liked',
          isSelected: selectedTab == 2,
          onTap: () => onTabChanged(2),
          isTablet: isTablet,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  IconData _getTabIcon(int index) {
    switch (index) {
      case 0: return Icons.description_outlined;
      case 1: return Icons.bookmark_outline;
      case 2: return Icons.favorite_outline;
      default: return Icons.description_outlined;
    }
  }

  String _getTabMessage(int index) {
    switch (index) {
      case 0: return 'Your notes will appear here';
      case 1: return 'Your saved notes will appear here';
      case 2: return 'Your liked notes will appear here';
      default: return 'Content will appear here';
    }
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;
  final bool isMobile;
  final bool isDesktop;

  const _StatItem({
    required this.count,
    required this.label,
    this.isMobile = false,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF000000),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: isDesktop ? 32 : 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF000000),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isLink;
  final bool isMobile;

  const _DetailItem({
    required this.icon,
    required this.text,
    this.isLink = false,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: isMobile ? 16 : 18,
          color: const Color(0xFF666666),
        ),
        SizedBox(width: isMobile ? 10 : 12),
        Expanded(
          child: isLink
              ? GestureDetector(
                  onTap: () {
                    final url = text.startsWith('http') ? text : 'https://$text';
                    launchUrlString(url, mode: LaunchMode.externalApplication);
                  },
                  child: Text(
                    text,
                    style: TextStyle(
                      color: const Color(0xFF000000),
                      fontSize: isMobile ? 13 : 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    color: const Color(0xFF000000),
                    fontSize: isMobile ? 13 : 14,
                  ),
                ),
        ),
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isMobile;
  final bool isTablet;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isMobile = false,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : (isTablet ? 16 : 20),
          vertical: isMobile ? 10 : 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFE5E5E0) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isMobile ? 16 : 18,
              color: const Color(0xFF000000),
            ),
            SizedBox(width: isMobile ? 6 : 8),
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFF000000),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: isMobile ? 13 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}