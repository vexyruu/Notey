import 'package:flutter/material.dart';

/// Compact HSV color picker: 2D saturation-value pad + hue bar + hex preview.
class HsvColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onChanged;
  final bool showPreview;

  const HsvColorPicker({
    super.key,
    required this.initialColor,
    required this.onChanged,
    this.showPreview = true,
  });

  @override
  State<HsvColorPicker> createState() => _HsvColorPickerState();
}

class _HsvColorPickerState extends State<HsvColorPicker> {
  late double _hue;
  late double _sat;
  late double _val;

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.initialColor);
    _hue = hsv.hue;
    _sat = hsv.saturation;
    _val = hsv.value.clamp(0.3, 1.0); // keep it visible
  }

  Color get _color => HSVColor.fromAHSV(1.0, _hue, _sat, _val).toColor();

  String get _hex {
    final c = _color;
    final r = (c.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (c.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (c.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }

  void _onSv(double s, double v) {
    setState(() {
      _sat = s;
      _val = v.clamp(0.3, 1.0);
    });
    widget.onChanged(_color);
  }

  void _onHue(double h) {
    setState(() => _hue = h);
    widget.onChanged(_color);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Saturation-Value 2D pad ──
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _SvPicker(
            hue: _hue,
            saturation: _sat,
            value: _val,
            onChanged: _onSv,
          ),
        ),
        const SizedBox(height: 10),
        // ── Hue bar ──
        _HuePicker(hue: _hue, onChanged: _onHue),
        if (widget.showPreview) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _color,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35), width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: _color.withValues(alpha: 0.45),
                        blurRadius: 8,
                        spreadRadius: 1),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _hex,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── S-V 2D picker ──────────────────────────────────────────────────────────

class _SvPicker extends StatelessWidget {
  final double hue;
  final double saturation;
  final double value;
  final void Function(double s, double v) onChanged;

  const _SvPicker({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.onChanged,
  });

  void _handle(Offset pos, double w, double h) {
    final s = (pos.dx / w).clamp(0.0, 1.0);
    final v = 1.0 - (pos.dy / h).clamp(0.0, 1.0);
    onChanged(s, v);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      const h = 148.0;
      final w = c.maxWidth;
      return GestureDetector(
        onTapDown: (d) => _handle(d.localPosition, w, h),
        onPanStart: (d) => _handle(d.localPosition, w, h),
        onPanUpdate: (d) => _handle(d.localPosition, w, h),
        child: CustomPaint(
          painter: _SvPainter(hue, saturation, value),
          size: Size(w, h),
        ),
      );
    });
  }
}

class _SvPainter extends CustomPainter {
  final double hue, sat, val;
  _SvPainter(this.hue, this.sat, this.val);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final hueColor = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();

    // White → full hue (horizontal)
    canvas.drawRect(
      rect,
      Paint()
        ..shader =
            LinearGradient(colors: [Colors.white, hueColor]).createShader(rect),
    );
    // Transparent → black (vertical)
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black],
        ).createShader(rect),
    );

    // Thumb
    final tx = (sat * size.width).clamp(0.0, size.width);
    final ty = ((1 - val) * size.height).clamp(0.0, size.height);
    final thumbColor = HSVColor.fromAHSV(1.0, hue, sat, val).toColor();
    canvas.drawCircle(Offset(tx, ty), 11, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(tx, ty), 8.5, Paint()..color = thumbColor);
  }

  @override
  bool shouldRepaint(_SvPainter o) =>
      o.hue != hue || o.sat != sat || o.val != val;
}

// ── Hue bar ────────────────────────────────────────────────────────────────

class _HuePicker extends StatelessWidget {
  final double hue;
  final ValueChanged<double> onChanged;
  const _HuePicker({required this.hue, required this.onChanged});

  void _handle(Offset pos, double w) =>
      onChanged((pos.dx / w * 360).clamp(0.0, 360.0));

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      const h = 22.0;
      final w = c.maxWidth;
      return GestureDetector(
        onTapDown: (d) => _handle(d.localPosition, w),
        onPanStart: (d) => _handle(d.localPosition, w),
        onPanUpdate: (d) => _handle(d.localPosition, w),
        child: CustomPaint(
          painter: _HuePainter(hue),
          size: Size(w, h),
        ),
      );
    });
  }
}

class _HuePainter extends CustomPainter {
  final double hue;
  _HuePainter(this.hue);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = Radius.circular(size.height / 2);

    // Rainbow gradient
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, r),
      Paint()
        ..shader = LinearGradient(colors: [
          HSVColor.fromAHSV(1, 0, 1, 1).toColor(),
          HSVColor.fromAHSV(1, 60, 1, 1).toColor(),
          HSVColor.fromAHSV(1, 120, 1, 1).toColor(),
          HSVColor.fromAHSV(1, 180, 1, 1).toColor(),
          HSVColor.fromAHSV(1, 240, 1, 1).toColor(),
          HSVColor.fromAHSV(1, 300, 1, 1).toColor(),
          HSVColor.fromAHSV(1, 360, 1, 1).toColor(),
        ]).createShader(rect),
    );

    // Thumb
    final rad = size.height / 2;
    final tx = (hue / 360 * size.width).clamp(rad, size.width - rad);
    final ty = rad;
    canvas.drawCircle(Offset(tx, ty), rad + 2, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(tx, ty), rad,
        Paint()..color = HSVColor.fromAHSV(1, hue, 1, 1).toColor());
  }

  @override
  bool shouldRepaint(_HuePainter o) => o.hue != hue;
}
