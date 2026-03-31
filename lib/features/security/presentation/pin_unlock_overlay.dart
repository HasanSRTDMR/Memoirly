import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:memoirly/core/di/providers.dart';
import 'package:memoirly/core/localization/app_localizations.dart';
import 'package:memoirly/core/theme/app_colors.dart';

class PinUnlockOverlay extends ConsumerStatefulWidget {
  const PinUnlockOverlay({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PinUnlockOverlay> createState() => _PinUnlockOverlayState();
}

class _PinUnlockOverlayState extends ConsumerState<PinUnlockOverlay>
    with WidgetsBindingObserver {
  String _pin = '';
  String? _error;
  final _auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final sec = ref.read(securityRepositoryProvider);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      sec.setSessionUnlocked(false);
      setState(() {
        _pin = '';
        _error = null;
      });
    }
  }

  Future<void> _tryBiometric() async {
    final sec = ref.read(securityRepositoryProvider);
    final enabled = await sec.watchBiometricEnabled().first;
    if (!enabled || !mounted) return;
    try {
      final ok = await _auth.authenticate(
        localizedReason: 'Unlock your journal',
      );
      if (ok && mounted) {
        sec.setSessionUnlocked(true);
        setState(() {});
      }
    } catch (_) {}
  }

  void _digit(String d) {
    final sec = ref.read(securityRepositoryProvider);
    setState(() {
      _error = null;
      if (d == 'del') {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
        return;
      }
      if (_pin.length >= 4) return;
      _pin += d;
      if (_pin.length == 4) {
        sec.verifyPin(_pin).then((ok) {
          if (!mounted) return;
          if (ok) {
            sec.setSessionUnlocked(true);
            setState(() {
              _pin = '';
            });
          } else {
            setState(() {
              _pin = '';
              _error = AppLocalizations.of(context).wrongPin;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sec = ref.watch(securityRepositoryProvider);
    return StreamBuilder<bool>(
      stream: sec.watchLockEnabled(),
      initialData: false,
      builder: (context, lockSnap) {
        final locked = lockSnap.data ?? false;
        final show = locked && !sec.isSessionUnlocked;
        return Stack(
          children: [
            widget.child,
            if (show)
              Positioned.fill(
                child: ColoredBox(
                  color: AppColors.surface.withValues(alpha: 0.98),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Text(
                            AppLocalizations.of(context).appTitle,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontStyle: FontStyle.italic),
                          ),
                          Text(
                            AppLocalizations.of(context).privateSanctuary,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const Spacer(),
                          Text(
                            AppLocalizations.of(context).welcomeBack,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontFamily: 'Newsreader',
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context).enterPin,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              4,
                              (i) => Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i < _pin.length
                                      ? AppColors.primary
                                      : AppColors.primaryContainer,
                                ),
                              ),
                            ),
                          ),
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                _error!,
                                style: const TextStyle(color: AppColors.error),
                              ),
                            ),
                          const SizedBox(height: 28),
                          _PinPad(onDigit: _digit),
                          const SizedBox(height: 24),
                          TextButton.icon(
                            onPressed: _tryBiometric,
                            icon: const Icon(Icons.face_retouching_natural),
                            label: Text(
                              AppLocalizations.of(context).useBiometrics,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  AppLocalizations.of(context).forgotPin,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  AppLocalizations.of(context).emergency,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PinPad extends StatelessWidget {
  const _PinPad({required this.onDigit});

  final void Function(String) onDigit;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['bio', '0', 'del'],
    ];
    return Column(
      children: rows.map((r) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: r.map((k) {
              if (k == 'bio') {
                return SizedBox(
                  width: 72,
                  height: 56,
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context).faceId,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                );
              }
              return SizedBox(
                width: 72,
                height: 56,
                child: k == 'del'
                    ? IconButton(
                        onPressed: () => onDigit('del'),
                        icon: const Icon(Icons.backspace_outlined),
                      )
                    : TextButton(
                        onPressed: () => onDigit(k),
                        child: Text(k, style: const TextStyle(fontSize: 24)),
                      ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
