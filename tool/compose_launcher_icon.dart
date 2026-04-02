import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart';

const _bgR = 246;
const _bgG = 239;
const _bgB = 226;

/// Tasarım aracının eklediği düz beyaza yakın pikselleri arka plan rengine çeker (iOS / legacy ikon).
void _replaceNearWhiteWithBackground(Image img) {
  const threshold = 248;
  for (final p in img) {
    if (p.r >= threshold && p.g >= threshold && p.b >= threshold) {
      p
        ..r = _bgR
        ..g = _bgG
        ..b = _bgB
        ..a = 255;
    }
  }
}

/// Android adaptive **ön plan**: sadece mürekkep/çizim kalsın, bej/zemin şeffaf olsun.
/// Böylece daire maskesinin tamamı arka plan katmanındaki #F6EFE2’den gelir (opak kare halka kalmaz).
Image _androidForegroundTransparent(Image opaqueOnBg) {
  final out = Image(
    width: opaqueOnBg.width,
    height: opaqueOnBg.height,
    numChannels: 4,
  );

  for (var y = 0; y < opaqueOnBg.height; y++) {
    for (var x = 0; x < opaqueOnBg.width; x++) {
      final p = opaqueOnBg.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();

      final maxc = math.max(r, math.max(g, b));
      final minc = math.min(r, math.min(g, b));
      final chroma = maxc - minc;
      final lum = 0.299 * r + 0.587 * g + 0.114 * b;

      // Düşük kromalı + açık ton = kağıt/bej zemin veya anti-alias zemin.
      final isPaper = chroma <= 46 && lum >= 158;

      if (isPaper) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
      } else {
        out.setPixelRgba(x, y, r, g, b, 255);
      }
    }
  }
  return out;
}

/// Dairesel maskede kesilmesin diye çizimi küçültüp ortalar (108dp güvenli alan ~%66).
Image _scaleDownCentered(Image src, double scale) {
  final w = src.width;
  final h = src.height;
  final nw = math.max(1, (w * scale).round());
  final nh = math.max(1, (h * scale).round());
  final scaled = copyResize(
    src,
    width: nw,
    height: nh,
    interpolation: Interpolation.average,
  );
  final out = Image(width: w, height: h, numChannels: 4);
  out.clear(ColorUint8.rgba(0, 0, 0, 0));
  compositeImage(out, scaled, dstX: (w - nw) ~/ 2, dstY: (h - nh) ~/ 2);
  return out;
}

void _writeSolidAdaptiveBackground(String path) {
  const size = 432;
  final bg = Image(width: size, height: size, numChannels: 4);
  fill(bg, color: ColorRgb8(_bgR, _bgG, _bgB));
  File(path).writeAsBytesSync(encodePng(bg));
}

/// - [logom_launcher.png]: opak, iOS + Android legacy mipmap
/// - [logom_android_fg.png]: şeffaf zemin, yalnızca Android adaptive ön plan
/// - [ic_launcher_adaptive_bg.png]: düz #F6EFE2 adaptive arka plan
///
/// `dart run tool/compose_launcher_icon.dart` → `dart run flutter_launcher_icons`
void main() {
  const inputPath = 'assets/images/logom.png';
  const outputPath = 'assets/images/logom_launcher.png';
  const androidFgPath = 'assets/images/logom_android_fg.png';
  const adaptiveBgPath = 'assets/images/ic_launcher_adaptive_bg.png';

  final inFile = File(inputPath);
  if (!inFile.existsSync()) {
    stderr.writeln('Eksik dosya: $inputPath');
    exit(1);
  }

  final src = decodeImage(inFile.readAsBytesSync());
  if (src == null) {
    stderr.writeln('Görüntü çözülemedi: $inputPath');
    exit(1);
  }

  final dst = Image(width: src.width, height: src.height, numChannels: 4);
  fill(dst, color: ColorRgb8(_bgR, _bgG, _bgB));
  compositeImage(dst, src);
  _replaceNearWhiteWithBackground(dst);

  File(outputPath).writeAsBytesSync(encodePng(dst));
  stdout.writeln('Yazıldı: $outputPath (${dst.width}x${dst.height})');

  const androidGraphicScale = 0.72;
  final androidFg = _scaleDownCentered(
    _androidForegroundTransparent(dst),
    androidGraphicScale,
  );
  File(androidFgPath).writeAsBytesSync(encodePng(androidFg));
  stdout.writeln(
    'Yazıldı: $androidFgPath (şeffaf zemin, %${(androidGraphicScale * 100).round()} ölçek)',
  );

  _writeSolidAdaptiveBackground(adaptiveBgPath);
  stdout.writeln('Yazıldı: $adaptiveBgPath (adaptive arka plan)');
}
