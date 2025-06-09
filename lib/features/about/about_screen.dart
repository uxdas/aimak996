import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'feedback_screen.dart';
import 'dart:async';

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
                  opacity: _logoController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.2), end: Offset.zero)
                        .animate(_logoController),
                    child: Image.asset(
                      'assets/images/logo.png',
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
                          'company_name'.tr() + '  🤝',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'company_slogan'.tr(),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _descController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.15), end: Offset.zero)
                        .animate(_descController),
                    child: Text(
                      'company_description'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.white60 : Colors.black54,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _missionController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.12), end: Offset.zero)
                        .animate(_missionController),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🌱', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'mission_description'.tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
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
                        Expanded(
                          child: _AnimatedButton(
                            color: theme.primaryColor,
                            text: 'drawer_number'.tr(),
                            onTap: () async {
                              final uri = Uri.parse('tel:0999109190');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _AnimatedButton(
                            color: const Color(0xFF25D366),
                            text: 'WhatsApp',
                            onTap: () async {
                              final uri =
                                  Uri.parse('https://wa.me/996999109190');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FadeTransition(
                  opacity: _buttonsController,
                  child: Text(
                    '10 000+ пользователей',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDarkMode ? Colors.white38 : Colors.black38,
                      fontWeight: FontWeight.w500,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🌟', style: TextStyle(fontSize: 22)),
                              const SizedBox(width: 10),
                              Text(
                                'О нас (аймАк996)',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Аймак 996 — это компания, создающая современные мобильные приложения для каждого региона Кыргызстана. Для каждого района мы разрабатываем отдельное приложение, чтобы жители могли удобно общаться, размещать объявления и быть в курсе событий своего региона.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('📱', style: TextStyle(fontSize: 22)),
                              const SizedBox(width: 10),
                              Text(
                                'О приложении',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Это приложение предназначено только для Ноокатского района. В будущем мы запустим аналогичные приложения для других регионов, каждое с уникальным названием под свой район.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('💬', style: TextStyle(fontSize: 22)),
                              const SizedBox(width: 10),
                              Text(
                                'Для отзывов',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Оставьте свой отзыв о приложении, чтобы помочь нам стать лучше.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('👨‍💻',
                                  style: TextStyle(fontSize: 22)),
                              const SizedBox(width: 10),
                              Text(
                                'Разработчик',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Наша команда разработчиков работает над созданием качественных приложений.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🚀', style: TextStyle(fontSize: 22)),
                              const SizedBox(width: 10),
                              Text(
                                'Следующие шаги',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Мы планируем запустить новые приложения для других районов Кыргызстана, а также улучшить текущее приложение, добавив новые функции и улучшив пользовательский опыт.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('📱', style: TextStyle(fontSize: 22)),
                              const SizedBox(width: 10),
                              Text(
                                'Муляжи приложений',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: 40,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    index == 0
                                        ? 'Кара-Суу'
                                        : index == 1
                                            ? 'Ош'
                                            : index == 2
                                                ? 'Баткен'
                                                : 'App ${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
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
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.08,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
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
                    color: widget.color.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
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
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.08,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
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
                    color: widget.color.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
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
