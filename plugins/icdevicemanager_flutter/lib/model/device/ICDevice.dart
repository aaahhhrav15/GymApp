

import 'package:json_annotation/json_annotation.dart';

part 'ICDevice.g.dart';
@JsonSerializable()
class ICDevice {
   String? macAddr;

   ICDevice(this.macAddr);

   factory ICDevice.fromJson(Map<String, dynamic> json) => _$ICDeviceFromJson(json);

   Map<String, dynamic> toJson() => _$ICDeviceToJson(this);
}