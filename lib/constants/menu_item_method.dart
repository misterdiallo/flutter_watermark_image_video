import 'package:flutter/widgets.dart';

@immutable
class MenuItemMethod {
  const MenuItemMethod({
    required this.icon,
    required this.name,
    required this.description,
    required this.method,
  });

  final String icon;
  final String name;
  final String description;
  final void Function(BuildContext context) method;
}
