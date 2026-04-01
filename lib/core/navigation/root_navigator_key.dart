import 'package:flutter/material.dart';

/// Same key passed to [GoRouter.navigatorKey] so overlays above the router
/// (e.g. PIN lock) can open dialogs and find [ScaffoldMessenger].
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
