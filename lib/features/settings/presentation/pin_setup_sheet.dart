import 'package:flutter/material.dart';
import 'package:memoirly/core/localization/app_localizations.dart';
import 'package:memoirly/core/theme/app_colors.dart';

class PinSetupSheet extends StatefulWidget {
  const PinSetupSheet({super.key});

  @override
  State<PinSetupSheet> createState() => _PinSetupSheetState();
}

class _PinSetupSheetState extends State<PinSetupSheet> {
  String _phase = 'set';
  String _first = '';
  String _current = '';

  void _key(String k) {
    setState(() {
      if (k == 'del') {
        if (_current.isNotEmpty) {
          _current = _current.substring(0, _current.length - 1);
        }
        return;
      }
      if (_current.length >= 4) return;
      _current += k;
      if (_current.length == 4) {
        if (_phase == 'set') {
          _first = _current;
          _current = '';
          _phase = 'confirm';
        } else {
          final l = AppLocalizations.of(context);
          if (_current == _first) {
            Navigator.pop(context, _current);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l.pinsDoNotMatch)),
            );
            _current = '';
            _phase = 'set';
            _first = '';
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.paddingOf(context).bottom + 24,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _phase == 'set' ? l.setPinTitle : l.confirmPinTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _current.length
                      ? AppColors.primary
                      : AppColors.primaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _Keypad(onKey: _key),
        ],
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey});

  final void Function(String) onKey;

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];
    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((k) {
              if (k.isEmpty) return const SizedBox(width: 64, height: 56);
              return SizedBox(
                width: 64,
                height: 56,
                child: k == 'del'
                    ? IconButton(
                        onPressed: () => onKey('del'),
                        icon: const Icon(Icons.backspace_outlined),
                      )
                    : TextButton(
                        onPressed: () => onKey(k),
                        child: Text(
                          k,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
