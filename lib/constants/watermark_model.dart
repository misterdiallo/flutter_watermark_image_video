import 'package:flutter/widgets.dart';

@immutable
class WatermarkModel {
  WatermarkModel({
    required this.id,
    required this.name,
    required this.content,
    required this.type,
    required this.created_date,
    required this.updated_date,
    required this.widget,
    required this.onpressed,
  });
  int id;
  final String name, content, type;
  final DateTime created_date, updated_date;
  final Widget widget;
  final dynamic onpressed;
}
