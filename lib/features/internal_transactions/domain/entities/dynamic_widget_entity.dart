import 'widget_option_entity.dart';

class DynamicWidgetEntity {
  final String widgetType;

  final Map<String, dynamic> data;

  final List<WidgetOptionEntity> options;

  const DynamicWidgetEntity({
    required this.widgetType,
    required this.data,
    this.options = const [],
  });
}