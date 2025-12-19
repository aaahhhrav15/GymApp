
import 'package:icdevicemanager_flutter/model/other/ICConstant.dart';
import 'package:json_annotation/json_annotation.dart';


part 'ICRulerData.g.dart';

@JsonSerializable()
class ICRulerData{
  /**
      是否稳定数据
      @notice 如果数据不稳定，则只有distance有效，不稳定的数据只做展示用，请勿保存
   */
   bool isStabilized=false;

  /**
      测量长度(0.1mm)
   */
   int distance=0;

  /**
      距离inch
   */
   double distance_in=0.0;

  /**
      距离ft
   */
   int distance_ft=0;
  /**
      距离ft'in
   */
   double distance_ft_in=0.0;

  /**
      距离cm
   */
   double distance_cm=0.0;

  /**
      inch距离小数点位数,如:distance_in=70.12,则precision_in=2，distance_in=71.5,则precision_in=1
   */
   int precision_in=1;

  /**
      cm距离小数点位数,如:distance_cm=70.12,则precision_cm=2，distance_cm=71.5,则precision_cm=1
   */
   int precision_cm=1;

  /**
   *
      本次测量的单位
   */
  ICRulerUnit unit=ICRulerUnit.ICRulerUnitCM;

  /**
      本次测量的单位
   */
  ICRulerMeasureMode mode=ICRulerMeasureMode.ICRulerMeasureModeLength;


  /**
      时间戳
   */
   int time=0;

  /**
      身体部位类型
   */
  ICRulerBodyPartsType partsType=ICRulerBodyPartsType.ICRulerPartsTypeCalf;

   ICRulerData();

   factory ICRulerData.fromJson(Map<String, dynamic> json) => _$ICRulerDataFromJson(json);

   Map<String, dynamic> toJson() => _$ICRulerDataToJson(this);

   @override
  String toString() {
    return 'ICRulerData{isStabilized: $isStabilized, distance: $distance, distance_in: $distance_in, distance_ft: $distance_ft, distance_ft_in: $distance_ft_in, distance_cm: $distance_cm, precision_in: $precision_in, precision_cm: $precision_cm, unit: $unit, mode: $mode, time: $time, partsType: $partsType}';
  }
}