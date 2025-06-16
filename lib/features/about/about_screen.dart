import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'feedback_screen.dart';
import 'dart:async';
import 'city_boards_screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _titleController;
  late AnimationController _descController;
  late AnimationController _missionController;
  late AnimationController _buttonsController;
  late AnimationController _socialController;
  late AnimationController _ctaController;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _titleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _descController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _missionController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _buttonsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _socialController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _ctaController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    // staggered animation
    _logoController.forward();
    Timer(const Duration(milliseconds: 250), () => _titleController.forward());
    Timer(const Duration(milliseconds: 500), () => _descController.forward());
    Timer(
        const Duration(milliseconds: 700), () => _missionController.forward());
    Timer(
        const Duration(milliseconds: 900), () => _buttonsController.forward());
    Timer(
        const Duration(milliseconds: 1100), () => _socialController.forward());
    Timer(const Duration(milliseconds: 1300), () => _ctaController.forward());
  }

  @override
  void dispose() {
    _logoController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _missionController.dispose();
    _buttonsController.dispose();
    _socialController.dispose();
    _ctaController.dispose();
    super.dispose();
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    const phone = '996999109190';
    const message =
        'Салам! Мен Аймак 996 колдонмосу жөнүндө пикир билдиргим келет.';
    final whatsappUrl =
        'https://wa.me/$phone?text=${Uri.encodeComponent(message)}';

    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('whatsapp_error'.tr())),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('whatsapp_error'.tr())),
        );
      }
    }
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 400,
          child: FeedbackScreen(),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('about_title'.tr()),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.92),
              theme.colorScheme.background.withOpacity(0.96),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _buttonsController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.1), end: Offset.zero)
                        .animate(_buttonsController),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 32),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.apps, size: 24),
                        label: Text(
                          'other_regions_button'.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CityBoardsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                FadeTransition(
                  opacity: _logoController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.2), end: Offset.zero)
                        .animate(_logoController),
                    child: Image.asset(
                      'assets/images/nookat996logo.png',
                      width: 96,
                      height: 96,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _titleController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.2), end: Offset.zero)
                        .animate(_titleController),
                    child: Column(
                      children: [
                        Text(
                          'company_name'.tr(),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'company_slogan'.tr(),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _buttonsController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.1), end: Offset.zero)
                        .animate(_buttonsController),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _AnimatedButton(
                          text: 'feedback_button'.tr() +
                              ' ' +
                              'whatsapp_button'.tr(),
                          color: const Color(0xFF25D366),
                          onTap: () => _launchWhatsApp(context),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _socialController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.1), end: Offset.zero)
                        .animate(_socialController),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'about_section_title'.tr(),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : theme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'company_description'.tr(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _ctaController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.08), end: Offset.zero)
                        .animate(_ctaController),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'about_app'.tr(),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : theme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'about_app_text'.tr(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return _ActionButton(
      text: text,
      icon: icon,
      color: color,
      onTap: onTap,
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final Color color;
  final String text;
  final VoidCallback onTap;
  const _AnimatedButton(
      {required this.color, required this.text, required this.onTap});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!mounted) return;
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (!mounted) return;
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    if (!mounted) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

class _ActionButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!mounted) return;
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (!mounted) return;
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    if (!mounted) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

class _AboutListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AboutListItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: theme.primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
