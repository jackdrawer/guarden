import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../i18n/strings.g.dart';
import '../../theme/app_colors.dart';
import '../../widgets/neumorphic/neumorphic_container.dart';
import '../../widgets/neumorphic/neumorphic_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/clipboard_service.dart';

Future<String?> showPasswordGenerator(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const PasswordGeneratorDialog(),
  );
}

class PasswordGeneratorDialog extends ConsumerStatefulWidget {
  const PasswordGeneratorDialog({super.key});

  @override
  ConsumerState<PasswordGeneratorDialog> createState() =>
      _PasswordGeneratorDialogState();
}

class _PasswordGeneratorDialogState
    extends ConsumerState<PasswordGeneratorDialog> {
  double _length = 16;
  bool _useUppercase = true;
  bool _useLowercase = true;
  bool _useNumbers = true;
  bool _useSymbols = true;

  String _generatedPassword = '';
  int _scrambleKey = 0;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    const uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
    const numberChars = '0123456789';
    const symbolChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String allowedChars = '';
    if (_useUppercase) allowedChars += uppercaseChars;
    if (_useLowercase) allowedChars += lowercaseChars;
    if (_useNumbers) allowedChars += numberChars;
    if (_useSymbols) allowedChars += symbolChars;

    if (allowedChars.isEmpty) {
      allowedChars = lowercaseChars;
    }

    final random = Random.secure();
    setState(() {
      _generatedPassword = List.generate(
        _length.toInt(),
        (index) => allowedChars[random.nextInt(allowedChars.length)],
      ).join();
      _scrambleKey++;
    });
  }

  Color _getStrengthColor() {
    int strength = 0;
    if (_length >= 12) strength++;
    if (_length >= 16) strength++;
    if (_useUppercase) strength++;
    if (_useNumbers) strength++;
    if (_useSymbols) strength++;

    if (strength <= 2) return AppColors.of(context).error;
    if (strength <= 4) return Colors.amber;
    return Colors.green;
  }

  String _getStrengthText() {
    int strength = 0;
    if (_length >= 12) strength++;
    if (_length >= 16) strength++;
    if (_useUppercase) strength++;
    if (_useNumbers) strength++;
    if (_useSymbols) strength++;

    if (strength <= 2) return t.password_generator.weak;
    if (strength <= 4) return t.password_generator.strong;
    return t.password_generator.excellent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.of(context).background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 6,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.of(
                  context,
                ).textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Title & Strength
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.password_generator.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStrengthColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStrengthColor().withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  _getStrengthText(),
                  style: TextStyle(
                    color: _getStrengthColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Password Display Card
          NeumorphicContainer(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                _ScrambleText(
                  text: _generatedPassword,
                  triggerKey: _scrambleKey,
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'monospace',
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.of(context).primaryAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Divider(
                  color: AppColors.of(
                    context,
                  ).textSecondary.withValues(alpha: 0.2),
                  height: 1,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _generate();
                      },
                      icon: Icon(
                        Icons.refresh,
                        color: AppColors.of(context).textSecondary,
                      ),
                      label: Text(
                        t.password_generator.refresh,
                        style: TextStyle(
                          color: AppColors.of(context).textSecondary,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: AppColors.of(
                        context,
                      ).textSecondary.withValues(alpha: 0.2),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ref
                            .read(clipboardServiceProvider)
                            .copy(_generatedPassword);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(t.password_generator.copied)),
                        );
                      },
                      icon: Icon(
                        Icons.copy_rounded,
                        color: AppColors.of(context).primaryAccent,
                      ),
                      label: Text(
                        t.password_generator.copy_action,
                        style: TextStyle(
                          color: AppColors.of(context).primaryAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Length Slider section
          Text(
            t.password_generator.length(count: _length.toInt()),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 8,
              activeTrackColor: AppColors.of(context).primaryAccent,
              inactiveTrackColor: AppColors.of(
                context,
              ).shadowDark.withValues(alpha: 0.2),
              thumbColor: AppColors.of(context).primaryAccent,
              overlayColor: AppColors.of(
                context,
              ).primaryAccent.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(
              value: _length,
              min: 8,
              max: 64,
              divisions: 56,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() => _length = val);
                _generate();
              },
            ),
          ),
          const SizedBox(height: 24),

          // Setting Toggles
          _buildNeumorphicToggle(
            t.password_generator.uppercase,
            _useUppercase,
            (val) {
              setState(() => _useUppercase = val);
              _generate();
            },
          ),
          _buildNeumorphicToggle(
            t.password_generator.lowercase,
            _useLowercase,
            (val) {
              setState(() => _useLowercase = val);
              _generate();
            },
          ),
          _buildNeumorphicToggle(t.password_generator.numbers, _useNumbers, (
            val,
          ) {
            setState(() => _useNumbers = val);
            _generate();
          }),
          _buildNeumorphicToggle(t.password_generator.symbols, _useSymbols, (
            val,
          ) {
            setState(() => _useSymbols = val);
            _generate();
          }),

          const SizedBox(height: 32),

          // Footer Action
          NeumorphicButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context, _generatedPassword);
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  t.password_generator.use_this_password,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.of(context).primaryAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeumorphicToggle(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: NeumorphicContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.of(context).textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Switch(
              value: value,
              activeColor: AppColors.of(context).primaryAccent,
              onChanged: (val) {
                HapticFeedback.lightImpact();
                onChanged(val);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrambleText extends StatefulWidget {
  final String text;
  final int triggerKey;
  final TextStyle style;
  final TextAlign textAlign;

  const _ScrambleText({
    required this.text,
    required this.triggerKey,
    required this.style,
    this.textAlign = TextAlign.center,
  });

  @override
  State<_ScrambleText> createState() => _ScrambleTextState();
}

class _ScrambleTextState extends State<_ScrambleText>
    with SingleTickerProviderStateMixin {
  static const String _pool =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()_+-=[]{}|;:,.<>?';

  late final AnimationController _controller;
  final Random _random = Random.secure();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addListener(() => setState(() {}));
    _restart();
  }

  @override
  void didUpdateWidget(covariant _ScrambleText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.triggerKey != widget.triggerKey) {
      _restart();
    }
  }

  void _restart() {
    final ms = (700 + widget.text.length * 22).clamp(700, 1600);
    _controller.duration = Duration(milliseconds: ms);
    _controller.forward(from: 0);
  }

  String _buildFrame() {
    final t = Curves.easeOutCubic.transform(_controller.value);
    if (t >= 0.999) return widget.text;

    final revealCount = (widget.text.length * t).floor();
    final chars = widget.text.split('');
    for (var i = revealCount; i < chars.length; i++) {
      if (chars[i] == ' ') continue;
      chars[i] = _pool[_random.nextInt(_pool.length)];
    }
    return chars.join();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _buildFrame(),
      style: widget.style,
      textAlign: widget.textAlign,
    );
  }
}
