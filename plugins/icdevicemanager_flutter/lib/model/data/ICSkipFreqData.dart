
import 'package:json_annotation/json_annotation.dart';

part 'ICSkipFreqData.g.dart';

@JsonSerializable()
class ICSkipFreqData{
  /**
   * 持续时间
   */
   int duration = 0;

  /**
   * 次数
   */
   int skip_count = 0;

   ICSkipFreqData();

   factory ICSkipFreqData.fromJson(Map<String, dynamic> json) => _$ICSkipFreqDataFromJson(json);

   Map<String, dynamic> toJson() => _$ICSkipFreqDataToJson(this);
}