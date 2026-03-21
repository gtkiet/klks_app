import 'package:flutter/material.dart';

/// ────────────── TEXT STYLES ──────────────
const TextStyle kLabelTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: Color(0xFF374151),
);

const TextStyle kInputTextStyle = TextStyle(
  fontSize: 15,
  color: Color(0xFF111827),
);

const TextStyle kHintTextStyle = TextStyle(
  fontSize: 15,
  color: Color(0xFF9CA3AF),
);

const TextStyle kButtonTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.3,
);

/// ────────────── INPUT DECORATION ──────────────
BoxDecoration kInputDecoration() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(14),
  border: Border.all(color: const Color(0xFFE5E7EB)),
);

EdgeInsets kContentPadding() =>
    const EdgeInsets.symmetric(horizontal: 16, vertical: 15);

/// ────────────── BUTTON STYLE ──────────────
ButtonStyle kElevatedButtonStyle({
  required Color backgroundColor,
  required Color foregroundColor,
}) => ElevatedButton.styleFrom(
  backgroundColor: backgroundColor,
  foregroundColor: foregroundColor,
  elevation: 0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
);
