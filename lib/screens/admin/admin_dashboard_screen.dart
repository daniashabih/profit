import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/profit_logo.dart';
import '../../widgets/common/fit_flow_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedNavIndex = 0;

  final List<_AdminNavItem> _navItems = const [
    _AdminNavItem('Dashboard', Icons.dashboard_rounded),
    _AdminNavItem('Members', Icons.people_alt_rounded),
    _AdminNavItem('Trainers', Icons.sports_gymnastics_rounded),
    _AdminNavItem('Memberships', Icons.card_membership_rounded),
    _AdminNavItem('Payments', Icons.payment_rounded),
    _AdminNavItem('Attendance', Icons.how_to_reg_rounded),
    _AdminNavItem('Workouts', Icons.fitness_center_rounded),
    _AdminNavItem('Exercises', Icons.video_library_rounded),
    _AdminNavItem('Reports', Icons.bar_chart_rounded),
    _AdminNavItem('Settings', Icons.settings_rounded),
  ];

  final List<_RecentMember> _recentMembers = const [
    _RecentMember(
      name: 'Ayesha Khan',
      plan: 'VIP Annual',
      date: '12 Sep 2026',
      status: 'Active',
      statusColor: AppColors.primaryLime,
      avatarChar: 'A',
    ),
    _RecentMember(
      name: 'Usman Ali',
      plan: 'Monthly Pro',
      date: '11 Sep 2026',
      status: 'Active',
      statusColor: AppColors.primaryLime,
      avatarChar: 'U',
    ),
    _RecentMember(
      name: 'Sara Ahmed',
      plan: 'VIP Annual',
      date: '10 Sep 2026',
      status: 'Active',
      statusColor: AppColors.primaryLime,
      avatarChar: 'S',
    ),
    _RecentMember(
      name: 'Bilal Khan',
      plan: 'Monthly Pro',
      date: '09 Sep 2026',
      status: 'Pending',
      statusColor: Colors.amber,
      avatarChar: 'B',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        child: Column(
          children: [
            // Drawer Header with ProFit Logo
            Container(
              padding: const EdgeInsets.only(top: 50, bottom: 24, left: 20, right: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: const Row(
                children: [
                  ProFitLogo(size: 40, showText: false, showContainer: true),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PROFIT Admin',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'PROFIT Management Console',
                        style: TextStyle(fontSize: 11, color: AppColors.primaryLime),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Navigation Items List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                itemCount: _navItems.length,
                itemBuilder: (context, index) {
                  final item = _navItems[index];
                  final isSelected = _selectedNavIndex == index;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    child: ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      tileColor: isSelected
                          ? AppColors.primaryLime.withOpacity(0.15)
                          : Colors.transparent,
                      leading: Icon(
                        item.icon,
                        color: isSelected
                            ? AppColors.primaryLime
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        size: 20,
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? (isDark ? AppColors.primaryLime : const Color(0xFF111827))
                              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        ),
                      ),
                      onTap: () {
                        setState(() => _selectedNavIndex = index);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 4 KPI Cards (Screen 15: Total Members: 248, Active Trainers: 8, Revenue: ₹ 124,500, Attendance: 86%)
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    title: 'Total Members',
                    value: '248',
                    growth: '+12%',
                    icon: Icons.groups_rounded,
                    accentColor: AppColors.primaryLime,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKpiCard(
                    title: 'Active Trainers',
                    value: '8',
                    growth: '+2 new',
                    icon: Icons.sports_gymnastics_rounded,
                    accentColor: AppColors.proteinColor,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    title: 'Revenue',
                    value: '₹ 124,500',
                    growth: '+18.4%',
                    icon: Icons.monetization_on_rounded,
                    accentColor: AppColors.primaryLime,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKpiCard(
                    title: 'Attendance',
                    value: '86%',
                    growth: '+5.2%',
                    icon: Icons.how_to_reg_rounded,
                    accentColor: AppColors.carbsColor,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // MEMBERSHIP GROWTH CHART
            FitFlowCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Membership Growth',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLime.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Jan - Sep 2026',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryLime,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Custom Paint Smooth Curve Line Chart for Membership Growth
                  SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _GrowthChartPainter(
                        isDark: isDark,
                        lineColor: AppColors.primaryLime,
                        points: const [
                          0.25, 0.35, 0.40, 0.55, 0.60, 0.70, 0.80, 0.88, 1.0
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Month Labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Jan', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                      Text('Feb', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                      Text('Mar', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                      Text('Apr', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                      Text('May', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                      Text('Jun', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                      Text('Jul', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                      Text('Aug', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                      Text('Sep', style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // RECENT MEMBERS TABLE / LIST
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'RECENT MEMBERS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'See All (${_recentMembers.length})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentMembers.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  indent: 64,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                itemBuilder: (context, index) {
                  final member = _recentMembers[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primaryLime.withOpacity(0.2),
                          child: Text(
                            member.avatarChar,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryLime,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${member.plan} • Joined ${member.date}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: member.statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            member.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: member.statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String growth,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              Icon(icon, size: 20, color: accentColor),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.arrow_upward_rounded, size: 12, color: accentColor),
              const SizedBox(width: 2),
              Text(
                growth,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'vs last month',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminNavItem {
  final String title;
  final IconData icon;
  const _AdminNavItem(this.title, this.icon);
}

class _RecentMember {
  final String name;
  final String plan;
  final String date;
  final String status;
  final Color statusColor;
  final String avatarChar;

  const _RecentMember({
    required this.name,
    required this.plan,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.avatarChar,
  });
}

class _GrowthChartPainter extends CustomPainter {
  final bool isDark;
  final Color lineColor;
  final List<double> points;

  const _GrowthChartPainter({
    required this.isDark,
    required this.lineColor,
    required this.points,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final width = size.width;
    final height = size.height;
    final dx = width / (points.length - 1);

    // Draw horizontal grid lines
    final gridPaint = Paint()
      ..color = (isDark ? AppColors.darkBorder : AppColors.lightBorder).withOpacity(0.5)
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final y = height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    final path = Path();
    final fillPath = Path();

    final List<Offset> offsets = [];
    for (int i = 0; i < points.length; i++) {
      final x = i * dx;
      final y = height - (points[i] * (height - 20)) - 10;
      offsets.add(Offset(x, y));
    }

    path.moveTo(offsets[0].dx, offsets[0].dy);
    fillPath.moveTo(offsets[0].dx, offsets[0].dy);

    for (int i = 0; i < offsets.length - 1; i++) {
      final p0 = offsets[i];
      final p1 = offsets[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
      fillPath.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    fillPath.lineTo(width, height);
    fillPath.lineTo(0, height);
    fillPath.close();

    // Gradient fill under curve
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lineColor.withOpacity(0.28),
        lineColor.withOpacity(0.0),
      ],
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Stroke line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Dots
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = isDark ? const Color(0xFF0F1216) : Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (final pt in offsets) {
      canvas.drawCircle(pt, 5, dotPaint);
      canvas.drawCircle(pt, 5, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.lineColor != lineColor;
  }
}
