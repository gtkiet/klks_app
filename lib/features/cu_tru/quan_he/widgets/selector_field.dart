// lib/features/cu_tru/widgets/selector_field.dart

import 'package:flutter/material.dart';

import '../../../../core/errors/errors.dart';
import '../models/selector_item_model.dart';

class AppSelectorField extends StatefulWidget {
  final String label;
  final String? hint;

  /// Truyền trực tiếp nếu data đã có sẵn.
  final List<SelectorItemModel>? items;

  /// Truyền Future nếu widget cần tự load từ API.
  final Future<List<SelectorItemModel>>? itemsFuture;

  /// Danh sách item đang được chọn (controlled từ bên ngoài).
  final List<SelectorItemModel> selectedItems;

  /// true = cho phép chọn nhiều.
  final bool isMultiple;

  /// Callback khi có thay đổi — trả toàn bộ list đang chọn.
  final void Function(List<SelectorItemModel> selected)? onChanged;

  /// Callback tiện cho single-select — trả item hoặc null khi bỏ chọn.
  final void Function(SelectorItemModel? item)? onChangedSingle;

  final bool isRequired;
  final bool enabled;

  const AppSelectorField({
    super.key,
    required this.label,
    this.hint,
    this.items,
    this.itemsFuture,
    this.selectedItems = const [],
    this.isMultiple = false,
    this.onChanged,
    this.onChangedSingle,
    this.isRequired = false,
    this.enabled = true,
  }) : assert(
         items != null || itemsFuture != null,
         'Phải truyền items hoặc itemsFuture',
       );

  /// Constructor tiện khi dùng Future.
  const AppSelectorField.future({
    super.key,
    required this.label,
    this.hint,
    required Future<List<SelectorItemModel>> future,
    this.selectedItems = const [],
    this.isMultiple = false,
    this.onChanged,
    this.onChangedSingle,
    this.isRequired = false,
    this.enabled = true,
  }) : items = null,
       itemsFuture = future;

  @override
  State<AppSelectorField> createState() => _AppSelectorFieldState();
}

class _AppSelectorFieldState extends State<AppSelectorField> {
  List<SelectorItemModel> _allItems = [];
  List<SelectorItemModel> _selected = [];
  bool _loading = false;
  AppException? _error;

  @override
  void initState() {
    super.initState();
    _selected = List.of(widget.selectedItems);
    if (widget.items != null) {
      _allItems = widget.items!;
    } else {
      _loadFromFuture();
    }
  }

  @override
  void didUpdateWidget(AppSelectorField old) {
    super.didUpdateWidget(old);
    if (widget.items != null && widget.items != old.items) {
      setState(() => _allItems = widget.items!);
    }
    if (widget.selectedItems != old.selectedItems) {
      setState(() => _selected = List.of(widget.selectedItems));
    }
  }

  Future<void> _loadFromFuture() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await widget.itemsFuture!;
      if (mounted) {
        setState(() {
          _allItems = result;
          _loading = false;
        });
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = AppException(e.toString());
          _loading = false;
        });
      }
    }
  }

  String get _displayText {
    if (_selected.isEmpty) return '';
    if (widget.isMultiple) return _selected.map((e) => e.name).join(', ');
    return _selected.first.name;
  }

  Future<void> _openPicker() async {
    if (!widget.enabled || _error != null) return;

    final result = await showModalBottomSheet<List<SelectorItemModel>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SelectorSheet(
        label: widget.label,
        allItems: _allItems,
        selected: _selected,
        isMultiple: widget.isMultiple,
      ),
    );

    if (result == null || !mounted) return;

    setState(() => _selected = result);
    widget.onChanged?.call(_selected);
    if (!widget.isMultiple) {
      widget.onChangedSingle?.call(_selected.isEmpty ? null : _selected.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ─────────────────────────────────────────────────────────
        RichText(
          text: TextSpan(
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(text: widget.label),
              if (widget.isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // ── Field tap ─────────────────────────────────────────────────────
        InkWell(
          onTap: _loading ? null : _openPicker,
          borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: _loading
                  ? 'Đang tải...'
                  : (widget.hint ?? 'Chọn ${widget.label.toLowerCase()}'),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              // Viền đỏ khi có lỗi, nhưng ẩn errorText ở đây —
              // sẽ render đầy đủ qua AppErrorWidget bên dưới.
              errorText: _error != null ? '' : null,
              errorStyle: const TextStyle(height: 0, fontSize: 0),
              suffixIcon: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _error != null
                  ? IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Thử lại',
                      onPressed: _loadFromFuture,
                    )
                  : const Icon(Icons.arrow_drop_down),
              enabled: widget.enabled && !_loading,
            ),
            isEmpty: _selected.isEmpty,
            child: _selected.isEmpty
                ? const SizedBox.shrink()
                : Text(
                    _displayText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ),

        // ── Lỗi chi tiết — dùng AppErrorWidget ───────────────────────────
        if (_error != null) ...[
          const SizedBox(height: 4),
          AppErrorWidget(error: _error!),
        ],

        // ── Chip list (multi-select) ───────────────────────────────────────
        if (widget.isMultiple && _selected.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: _selected
                .map(
                  (item) => Chip(
                    label: Text(
                      item.name,
                      style: const TextStyle(fontSize: 12),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: widget.enabled
                        ? () {
                            setState(() => _selected.remove(item));
                            widget.onChanged?.call(_selected);
                          }
                        : null,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

// ── Bottom sheet ──────────────────────────────────────────────────────────────

class _SelectorSheet extends StatefulWidget {
  final String label;
  final List<SelectorItemModel> allItems;
  final List<SelectorItemModel> selected;
  final bool isMultiple;

  const _SelectorSheet({
    required this.label,
    required this.allItems,
    required this.selected,
    required this.isMultiple,
  });

  @override
  State<_SelectorSheet> createState() => _SelectorSheetState();
}

class _SelectorSheetState extends State<_SelectorSheet> {
  late List<SelectorItemModel> _selected;
  late List<SelectorItemModel> _filtered;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = List.of(widget.selected);
    _filtered = List.of(widget.allItems);
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = widget.allItems
          .where((e) => e.name.toLowerCase().contains(q))
          .toList();
    });
  }

  void _toggle(SelectorItemModel item) {
    if (widget.isMultiple) {
      setState(() {
        if (_selected.contains(item)) {
          _selected.remove(item);
        } else {
          _selected.add(item);
        }
      });
    } else {
      Navigator.pop(context, [item]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);

    return Container(
      height: mq.size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Chọn ${widget.label}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.isMultiple)
                  FilledButton(
                    onPressed: () => Navigator.pop(context, _selected),
                    child: Text('Xác nhận (${_selected.length})'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      'Không có kết quả',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final item = _filtered[i];
                      final isSelected = _selected.contains(item);
                      return ListTile(
                        title: Text(item.name),
                        trailing: isSelected
                            ? Icon(
                                widget.isMultiple
                                    ? Icons.check_box
                                    : Icons.check_circle,
                                color: theme.colorScheme.primary,
                              )
                            : widget.isMultiple
                            ? const Icon(Icons.check_box_outline_blank)
                            : null,
                        onTap: () => _toggle(item),
                        selected: isSelected,
                        selectedTileColor: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.3),
                      );
                    },
                  ),
          ),
          if (widget.isMultiple && _selected.isNotEmpty)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextButton(
                  onPressed: () => setState(() => _selected.clear()),
                  child: const Text('Bỏ chọn tất cả'),
                ),
              ),
            ),
          SizedBox(height: mq.padding.bottom),
        ],
      ),
    );
  }
}
