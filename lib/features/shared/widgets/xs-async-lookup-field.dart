import 'dart:async';

import 'package:flutter/material.dart';

/// Autocompletado reutilizable con búsqueda diferida para catálogos extensos.
class XsAsyncLookupField<T> extends StatefulWidget {
  const XsAsyncLookupField({
    super.key,
    required this.search,
    required this.itemLabel,
    required this.onSelected,
    this.selected,
    this.onCleared,
    this.labelText = 'Buscar',
    this.hintText,
    this.minCharacters = 2,
  });

  final Future<List<T>> Function(String query) search;
  final String Function(T item) itemLabel;
  final ValueChanged<T> onSelected;
  final T? selected;
  final VoidCallback? onCleared;
  final String labelText;
  final String? hintText;
  final int minCharacters;

  @override
  State<XsAsyncLookupField<T>> createState() => _XsAsyncLookupFieldState<T>();
}

class _XsAsyncLookupFieldState<T> extends State<XsAsyncLookupField<T>> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<T> _results = const [];
  bool _loading = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < widget.minCharacters) {
      setState(() => _results = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _loading = true);
      try {
        final results = await widget.search(value);
        if (mounted && _controller.text == value) setState(() => _results = results);
      } catch (_) {
        if (mounted) setState(() => _results = const []);
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selected != null) {
      return InputChip(
        label: Text(widget.itemLabel(widget.selected!)),
        avatar: const Icon(Icons.inventory_2_outlined, size: 18),
        onDeleted: widget.onCleared,
      );
    }
    return Column(
      children: [
        TextField(
          controller: _controller,
          onChanged: _onChanged,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.inventory_2_outlined),
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
        ),
        if (_results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: _results.map((item) => ListTile(
                dense: true,
                title: Text(widget.itemLabel(item)),
                onTap: () {
                  widget.onSelected(item);
                  _controller.clear();
                  setState(() => _results = const []);
                },
              )).toList(),
            ),
          ),
      ],
    );
  }
}
