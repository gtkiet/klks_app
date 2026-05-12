// lib/features/cu_tru/quan_he/widgets/can_ho_selector.dart
// Cách gọi: import 'package:klks_app/features/cu_tru/quan_he/widgets/can_ho_selector.dart';

import 'package:flutter/material.dart';

import '../models/quan_he_cu_tru_model.dart';

/// Hiển thị banner (1 căn hộ) hoặc dropdown (nhiều căn hộ).
/// Dùng:
///   CanHoSelector(
///     dsCanHo: _dsCanHo,
///     selected: _selectedCanHo,
///     onChanged: _onCanHoChanged,
///   )
class CanHoSelector extends StatelessWidget {
  final List<QuanHeCuTruModel> dsCanHo;
  final QuanHeCuTruModel? selected;
  final ValueChanged<QuanHeCuTruModel> onChanged;

  const CanHoSelector({
    super.key,
    required this.dsCanHo,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (dsCanHo.length == 1) {
      return _SingleCanHoBanner(canHo: dsCanHo.first);
    }
    return _CanHoDropdown(
      dsCanHo: dsCanHo,
      selected: selected,
      onChanged: onChanged,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SingleCanHoBanner extends StatelessWidget {
  final QuanHeCuTruModel canHo;
  const _SingleCanHoBanner({required this.canHo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.apartment, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  canHo.tenCanHo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${canHo.tenToaNha} · ${canHo.tenTang}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CanHoDropdown extends StatelessWidget {
  final List<QuanHeCuTruModel> dsCanHo;
  final QuanHeCuTruModel? selected;
  final ValueChanged<QuanHeCuTruModel> onChanged;

  const _CanHoDropdown({
    required this.dsCanHo,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Căn hộ',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<QuanHeCuTruModel>(
            initialValue: selected,
            isExpanded: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.apartment, size: 18),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue.shade600, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: dsCanHo.map((canHo) {
              return DropdownMenuItem<QuanHeCuTruModel>(
                value: canHo,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      canHo.tenCanHo,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${canHo.tenToaNha} · ${canHo.tenTang}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            selectedItemBuilder: (context) => dsCanHo.map((canHo) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${canHo.tenCanHo}  ·  ${canHo.tenToaNha}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (canHo) {
              if (canHo != null) onChanged(canHo);
            },
          ),
        ],
      ),
    );
  }
}
