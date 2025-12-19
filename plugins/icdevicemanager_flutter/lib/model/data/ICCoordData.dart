
import 'package:json_annotation/json_annotation.dart';

part 'ICCoordData.g.dart';

@JsonSerializable()
class ICCoordData {
  int time = 0;
  int x = 0;
  int y = 0;

  ICCoordData();



  factory ICCoordData.fromJson(Map<String, dynamic> json) => _$ICCoordDataFromJson(json);

  Map<String, dynamic> toJson() => _$ICCoordDataToJson(this);
}
