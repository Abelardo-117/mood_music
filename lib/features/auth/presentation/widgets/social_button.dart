import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({super.key, required this.onPressed});
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF202124),
      disabledForegroundColor: Colors.black54,
      minimumSize: const Size.fromHeight(54),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      side: BorderSide(color: const Color(0xFFDADCE0)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    child: Row(children: [
      ExcludeSemantics(child: const SizedBox(width: 24, height: 24, child: CustomPaint(painter: _GoogleMark()))),
      const SizedBox(width: 14),
      Expanded(child: Text('Continuar con Google',
        textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600))),
    ]),
  );
}
// Marca vectorial multicolor, incluida en código para funcionar sin descargas.
class _GoogleMark extends CustomPainter {
  const _GoogleMark();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save(); canvas.scale(size.width / 24, size.height / 24);
    final blue = Path()..moveTo(22.56,12.25)..cubicTo(22.56,11.52,22.5,10.82,22.37,10.15)
      ..lineTo(12,10.15)..lineTo(12,14.12)..lineTo(17.92,14.12)
      ..cubicTo(17.66,15.4,16.9,16.48,15.77,17.2)..lineTo(15.77,19.76)..lineTo(19.09,19.76)
      ..cubicTo(21.03,17.97,22.56,15.33,22.56,12.25)..close();
    final green = Path()..moveTo(12,23)..cubicTo(14.97,23,17.46,22.02,19.09,19.76)
      ..lineTo(15.77,17.2)..cubicTo(14.79,17.86,13.54,18.26,12,18.26)
      ..cubicTo(9.14,18.26,6.71,16.33,5.84,13.73)..lineTo(2.4,13.73)..lineTo(2.4,16.4)
      ..cubicTo(4.21,20.02,7.9,23,12,23)..close();
    final yellow = Path()..moveTo(5.84,13.73)..cubicTo(5.62,13.07,5.49,12.37,5.49,11.65)
      ..cubicTo(5.49,10.93,5.62,10.23,5.84,9.57)..lineTo(5.84,6.9)..lineTo(2.4,6.9)
      ..cubicTo(1.51,8.5,1,10.12,1,11.65)..cubicTo(1,13.35,1.51,14.97,2.4,16.4)
      ..lineTo(5.84,13.73)..close();
    final red = Path()..moveTo(12,5.04)..cubicTo(13.62,5.04,15.07,5.6,16.21,6.69)
      ..lineTo(19.36,3.54)..cubicTo(17.45,1.75,14.97,1,12,1)
      ..cubicTo(7.9,1,4.21,3.28,2.4,6.9)..lineTo(5.84,9.57)
      ..cubicTo(6.71,6.97,9.14,5.04,12,5.04)..close();
    for (final piece in [(blue, const Color(0xFF4285F4)), (green, const Color(0xFF34A853)),
      (yellow, const Color(0xFFFBBC05)), (red, const Color(0xFFEA4335))]) {
      canvas.drawPath(piece.$1, Paint()..color = piece.$2);
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
