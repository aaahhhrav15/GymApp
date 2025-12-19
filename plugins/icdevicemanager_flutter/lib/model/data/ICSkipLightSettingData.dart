
import 'package:json_annotation/json_annotation.dart';

part 'ICSkipLightSettingData.g.dart';

@JsonSerializable()
class ICSkipLightSettingData{
   int r=0;
   int g=0;
   int b=0;
   int rpm=0;

   ICSkipLightSettingData();

   factory ICSkipLightSettingData.fromJson(Map<String, dynamic> json) => _$ICSkipLightSettingDataFromJson(json);

   Map<String, dynamic> toJson() => _$ICSkipLightSettingDataToJson(this);
}