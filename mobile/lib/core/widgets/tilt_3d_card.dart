import 'package:flutter/material.dart';

class Tilt3DCard extends StatefulWidget {
  final Widget child;
  final Color? color;
  final VoidCallback? onTap;

  const Tilt3DCard({super.key, required this.child, this.color, this.onTap});

  @override
  State<Tilt3DCard> createState() => _Tilt3DCardState();
}

class _Tilt3DCardState extends State<Tilt3DCard> with SingleTickerProviderStateMixin {
  double _x = 0;
  double _y = 0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {},
      onExit: (_) => setState(() {
        _x = 0;
        _y = 0;
      }),
      onHover: (details) {
        final size = context.size;
        if (size != null) {
          final centerX = size.width / 2;
          final centerY = size.height / 2;
          final dx = details.localPosition.dx - centerX;
          final dy = details.localPosition.dy - centerY;
          setState(() {
            _x = -dy / centerY * 0.1; // Max tilt angle
            _y = dx / centerX * 0.1;
          });
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onPanUpdate: (details) {
          // Touch support for tilt
          setState(() {
            _x += details.delta.dy * 0.01;
            _y -= details.delta.dx * 0.01;
          });
        },
        onPanEnd: (_) => setState(() {
          _x = 0;
          _y = 0;
        }),
        child: TweenAnimationBuilder(
          tween: Tween<Offset>(begin: Offset.zero, end: Offset(_x, _y)),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          builder: (context, Offset offset, child) {
             return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective
                ..rotateX(offset.dx)
                ..rotateY(offset.dy),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.color ?? const Color(0xFF1E1E1E),
                   borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      blurRadius: 15,
                      offset: Offset(-offset.dy * 20, offset.dx * 20), // Shadow moves opposite
                    )
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}
