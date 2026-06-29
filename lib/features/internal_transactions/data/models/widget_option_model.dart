import '../../domain/entities/widget_option_entity.dart';

class WidgetOptionModel extends WidgetOptionEntity {
  const WidgetOptionModel({
    required super.key,
    required super.value,
  });

  factory WidgetOptionModel.fromJson(Map<String, dynamic> json) {
    return WidgetOptionModel(
      key: json['key']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }
}
