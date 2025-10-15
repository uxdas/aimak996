import 'package:flutter/material.dart';

class PinnedMessageBox extends StatefulWidget {
  final String text;
  final VoidCallback onClose;
  const PinnedMessageBox(
      {super.key, required this.text, required this.onClose});

  @override
  State<PinnedMessageBox> createState() => _PinnedMessageBoxState();
}

class _PinnedMessageBoxState extends State<PinnedMessageBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0,
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleClose() async {
    if (_isClosing) return;
    _isClosing = true;
    await _controller.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        decoration: BoxDecoration(
          color: const Color(0xFFE3ECFA), // светло-синий фон
          border: Border.all(
              color: const Color(0xFF1E3A8A), width: 1.5), // основной синий
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                widget.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF1E3A8A)),
              onPressed: _handleClose,
              splashRadius: 20,
              tooltip: 'Скрыть',
            ),
          ],
        ),
      ),
    );
  }
}
