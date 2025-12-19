import 'package:json_annotation/json_annotation.dart';

part 'ICWeightCenterData.g.dart';

@JsonSerializable()
class ICWeightCenterData{

  /**
      数据是否稳定, 不稳定的数据只做展示用，请勿保存
   */
   bool isStabilized=false;

  /**
      测量时间戳(秒)
   */
   int time=0;

  /**
      kg体重小数点位数,如:weight=70.12,则precision=2，weight=71.5,则precision_kg=1
   */
   int precision_kg=1;

  /**
      lb体重小数点位数,如:weight=70.12,则precision=2，weight=71.5,则precision_lb=1
   */
   int precision_lb=1;

  /**
      st:lb体重小数点位数
   */
   int precision_st_lb=1;

  /**
      kg分度值
   */
   int kg_scale_division=0;

  /**
      lb分度值
   */
   int lb_scale_division=0;

  /**
      左边体重占比(%)
   */
   double leftPercent=0.0;

  /**
      右边体重占比(%)
   */
   double rightPercent=0.0;

  /**
      左边体重(g)
   */
   int left_weight_g=0;

  /**
      右边体重(g)
   */
   int right_weight_g=0;
  /**
      左边体重(kg)
   */
   double left_weight_kg=0.0;

  /**
      右边体重(kg)
   */
   double right_weight_kg=0.0;

  /**
      左边体重(lb)
   */
   double left_weight_lb=0.0;

  /**
      右边体重(lb)
   */
   double right_weight_lb=0.0;

  /**
      左边体重(st:lb)
   */
   int left_weight_st=0;

  /**
      右边体重(st:lb)
   */
   int right_weight_st=0;

  /**
      左边体重(st:lb)
   */
   double left_weight_st_lb=0.0;

  /**
      右边体重(st:lb)
   */
   double right_weight_st_lb=0.0;

   ICWeightCenterData();

   factory ICWeightCenterData.fromJson(Map<String, dynamic> json) => _$ICWeightCenterDataFromJson(json);

   Map<String, dynamic> toJson() => _$ICWeightCenterDataToJson(this);

   @override
  String toString() {
    return 'ICWeightCenterData{isStabilized: $isStabilized, time: $time, precision_kg: $precision_kg, precision_lb: $precision_lb, precision_st_lb: $precision_st_lb, kg_scale_division: $kg_scale_division, lb_scale_division: $lb_scale_division, leftPercent: $leftPercent, rightPercent: $rightPercent, left_weight_g: $left_weight_g, right_weight_g: $right_weight_g, left_weight_kg: $left_weight_kg, right_weight_kg: $right_weight_kg, left_weight_lb: $left_weight_lb, right_weight_lb: $right_weight_lb, left_weight_st: $left_weight_st, right_weight_st: $right_weight_st, left_weight_st_lb: $left_weight_st_lb, right_weight_st_lb: $right_weight_st_lb}';
  }
}