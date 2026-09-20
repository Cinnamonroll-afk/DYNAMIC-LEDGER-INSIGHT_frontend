import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final Color? color;
  final BoxBorder? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Using solid slate-grey for Dark Mode to match premium solid UI (Anti-AI-Slop)
    final solidColor = isDarkMode 
        ? const Color(0xFF272732) // Solid dark slate/purple-grey
        : Colors.white; 
    
    final br = borderRadius ?? BorderRadius.circular(16);

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? solidColor,
        borderRadius: br,
        border: border,
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: child,
    );
  }
}
