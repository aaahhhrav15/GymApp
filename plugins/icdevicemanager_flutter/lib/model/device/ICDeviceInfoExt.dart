
import 'package:json_annotation/json_annotation.dart';

part 'ICDeviceInfoExt.g.dart';
@JsonSerializable()
class ICDeviceInfoExt{

  String? ext;

  ICDeviceInfoExt();

  factory ICDeviceInfoExt.fromJson(Map<String, dynamic> json) => _$ICDeviceInfoExtFromJson(json);

  Map<String, dynamic> toJson() => _$ICDeviceInfoExtToJson(this);
}