import '../../domain/entities/dynamic_widget_entity.dart';
import 'widget_option_model.dart';

class DynamicWidgetModel extends DynamicWidgetEntity {
  const DynamicWidgetModel({
    required super.widgetType,
    required super.data,
    super.options,
  });

  factory DynamicWidgetModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final optionsJson = data['options'] as List? ?? [];

    return DynamicWidgetModel(
      widgetType: json['widget_type']?.toString() ?? '',
      data: data,
      options: optionsJson
          .map(
            (item) => WidgetOptionModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}