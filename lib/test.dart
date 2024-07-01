// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class HandwritingScreen extends StatefulWidget {
  const HandwritingScreen({super.key});

  @override
  _HandwritingScreenState createState() => _HandwritingScreenState();
}

class _HandwritingScreenState extends State<HandwritingScreen> {
  final List<List<Offset>> _lines = []; // List of lines
  final List<Offset> _currentLine = []; // Current line being drawn
  bool _isErasing = false; // Indicates whether eraser mode is active

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Handwriting Screen'),
        actions: [
          IconButton(
            icon: Icon(_isErasing ? Icons.brush : Icons.clear),
            onPressed: () {
              setState(() {
                _isErasing = !_isErasing; // Toggle eraser mode
              });
            },
          ),
        ],
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            if (_isErasing) {
              _handleEraser(details.localPosition); // Handle eraser mode
            } else {
              _handleDrawing(details.localPosition); // Handle drawing mode
            }
          });
        },
        onPanEnd: (_) {
          setState(() {
            _lines.add(
                List.from(_currentLine)); // Add completed line to lines list
            _currentLine.clear(); // Clear current line
          });
        },
        child: CustomPaint(
          painter: HandwritingPainter(_lines, _currentLine),
          size: Size.infinite,
        ),
      ),
    );
  }

  void _handleDrawing(Offset position) {
    _currentLine.add(position); // Add point to current line being drawn
  }

  void _handleEraser(Offset position) {
    // Check if any point is within the eraser area
    for (int i = 0; i < _lines.length; i++) {
      if (_lines[i].any((point) => (point - position).distanceSquared <= 100)) {
        // Adjust eraser size as needed
        _lines
            .removeAt(i); // Remove line if any point intersects with the eraser
        break; // Stop after removing one line to ensure only one line is erased
      }
    }
  }
}

class HandwritingPainter extends CustomPainter {
  final List<List<Offset>> lines;
  final List<Offset> currentLine;

  HandwritingPainter(this.lines, this.currentLine);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    // Draw completed lines
    for (final line in lines) {
      for (int i = 0; i < line.length - 1; i++) {
        canvas.drawLine(line[i], line[i + 1], paint);
      }
    }

    // Draw current line being drawn
    for (int i = 0; i < currentLine.length - 1; i++) {
      canvas.drawLine(currentLine[i], currentLine[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
