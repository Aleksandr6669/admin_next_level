
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flag/flag.dart';
import 'models/language.dart';
import 'styles.dart';

class LanguageSelector extends StatefulWidget {
  final Language selectedLanguage;
  final void Function(Language?) onLanguageChange;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChange,
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> with TickerProviderStateMixin {
  final GlobalKey _key = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _closeDropdown(isDisposing: true);
    super.dispose();
  }

  void _toggleDropdown() {
    setState(() {
      if (_isOpen) {
        _closeDropdown();
      } else {
        _openDropdown();
      }
    });
  }

  void _openDropdown() {
    final RenderBox renderBox = _key.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final dropdownHeight = (supportedLanguages.length * 55.0);
    const verticalPadding = 8.0;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _toggleDropdown,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy - dropdownHeight - verticalPadding,
              width: size.width,
              height: dropdownHeight,
              child: Material(
                color: Colors.transparent,
                child: SizeTransition(
                  sizeFactor: _animation,
                  axisAlignment: 1.0,
                  child: FadeTransition(
                    opacity: _animation,
                    child: GlassmorphicContainer(
                      width: size.width,
                      height: dropdownHeight,
                      borderRadius: 20,
                      blur: 90,
                      alignment: Alignment.center,
                      border: 0,
                      linearGradient: kGlassmorphicGradient,
                      borderGradient: kGlassmorphicBorderGradient,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemCount: supportedLanguages.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.white.withAlpha(51),
                          height: 1,
                          indent: 20,
                          endIndent: 20,
                        ),
                        itemBuilder: (context, index) {
                          final language = supportedLanguages[index];
                          return GestureDetector(
                            onTap: () {
                              widget.onLanguageChange(language);
                              _toggleDropdown();
                            },
                            child: Container(
                              color: Colors.transparent,
                              height: 50,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flag.fromString(language.flagCode, height: 24, width: 24, fit: BoxFit.fill, borderRadius: 2.0),
                                    const SizedBox(width: 16),
                                    Text(language.name, style: kDropdownTextStyle),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isOpen = true;
    _animationController.forward();
  }

  void _closeDropdown({bool isDisposing = false}) {
    if (_isOpen) {
      _animationController.reverse().whenComplete(() {
        if (mounted) {
          _overlayEntry?.remove();
          _overlayEntry = null;
        }
      });
      _isOpen = false;
      if (!isDisposing) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      onTap: _toggleDropdown,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 50,
        borderRadius: 25,
        blur: 10,
        alignment: Alignment.center,
        border: 0,
        linearGradient: kGlassmorphicGradient,
        borderGradient: kGlassmorphicBorderGradient,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Flag.fromString(widget.selectedLanguage.flagCode, height: 24, width: 24, fit: BoxFit.fill, borderRadius: 2.0),
                  const SizedBox(width: 16),
                  Text(widget.selectedLanguage.name, style: kDropdownTextStyle),
                ],
              ),
              Icon(_isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
