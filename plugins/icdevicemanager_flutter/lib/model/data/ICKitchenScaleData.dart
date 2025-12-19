

import 'package:icdevicemanager_flutter/model/other/ICConstant.dart';
import 'package:json_annotation/json_annotation.dart';


part 'ICKitchenScaleData.g.dart';

@JsonSerializable()
class ICKitchenScaleData{
  /**
      是否稳定数据, 不稳定的数据只做展示用，请勿保存
   */
   bool isStabilized=false;

  /**
      数据值,单位:mg
   */
   int value_mg=0;

  /**
      数据值,单位:g
   */
   double value_g=0.0;

  /**
      数据值,单位:ml
   */
    double value_ml=0.0;
  /**
      数据值,单位:ml milk
   */
   double value_ml_milk=0.0;

  /**
      数据值,单位:oz
   */
   double value_oz=0.0;

  /**
      数据值,单位:lb:oz中的lb
   */
   int value_lb=0;

  /**
      数据值,单位:lb:oz中的oz
   */
   double value_lb_oz=0.0;

  /**
      数据值,单位:fl.oz,美制
   */
   double value_fl_oz=0.0;

  /**
      数据值,单位:fl.oz，英制
   */
   double value_fl_oz_uk=0.0;

  /**
      数据值,单位:fl.oz,美制
   */
   double value_fl_oz_milk=0.0;

  /**
      数据值,单位:fl.oz，英制
   */
   double value_fl_oz_milk_uk=0.0;

  /**
      测量时间戳(秒)
   */
   int time=0;

  /**
      小数点位数,如:value_lb=70.12,则precision=2，value_lb=71.5,则precision=1
   */
   int precision=1;
  /**
      小数点位数,如:value_lb=70.12,则precision=2，value_lb=71.5,则precision=1
   */
   int precision_g = 0;
  /**
      小数点位数,如:value_lb=70.12,则precision=2，value_lb=71.5,则precision=1
   */
   int precision_ml = 0;
  /**
      小数点位数,如:value_lb=70.12,则precision=2，value_lb=71.5,则precision=1
   */
   int precision_lboz = 0;
  /**
      小数点位数,如:value_lb=70.12,则precision=2，value_lb=71.5,则precision=1
   */
   int precision_oz = 0;
  /**
      小数点位数,如:value_lb=70.12,则precision=2，value_lb=71.5,则precision=1
   */
   int precision_ml_milk = 0;
  /**
      小数点位数,如:value_lb=70.12,则precision=2，value_lb=71.5,则precision=1
   */
   int precision_floz_us = 0;
  /**
      小数点位数,如:value_lb=70.12,则precision=2，value_lb=71.5,则precision=1
   */
   int precision_floz_uk = 0;
  /**
      小数点位数,如:value_lb=70.12,则precision=2，value_lb=71.5,则precision=1
   */
   int precision_floz_milk_us = 0;

  /**
      小数点位数,如:value_lb=70.12,则precision=2，value_lb=71.5,则precision=1
   */
   int precision_floz_milk_uk = 0;
  /**
      设备数据单位类型,0:公制，1:美制，2:英制
   */
   int unitType=0;

  /**
      数字是否负数
   */
   bool?  isNegative=false;

  /**
      是否去皮模式
   */
   bool? isTare=false;

  /**
      ///本次数据单位
   */
   ICKitchenScaleUnit unit=ICKitchenScaleUnit.ICKitchenScaleUnitG;


   ICKitchenScaleData();

  factory ICKitchenScaleData.fromJson(Map<String, dynamic> json) => _$ICKitchenScaleDataFromJson(json);

   Map<String, dynamic> toJson() => _$ICKitchenScaleDataToJson(this);

   @override
  String toString() {
    return 'ICKitchenScaleData{isStabilized: $isStabilized, value_mg: $value_mg, value_g: $value_g, value_ml: $value_ml, value_ml_milk: $value_ml_milk, value_oz: $value_oz, value_lb: $value_lb, value_lb_oz: $value_lb_oz, value_fl_oz: $value_fl_oz, value_fl_oz_uk: $value_fl_oz_uk, value_fl_oz_milk: $value_fl_oz_milk, value_fl_oz_milk_uk: $value_fl_oz_milk_uk, time: $time, precision: $precision, precision_g: $precision_g, precision_ml: $precision_ml, precision_lboz: $precision_lboz, precision_oz: $precision_oz, precision_ml_milk: $precision_ml_milk, precision_floz_us: $precision_floz_us, precision_floz_uk: $precision_floz_uk, precision_floz_milk_us: $precision_floz_milk_us, precision_floz_milk_uk: $precision_floz_milk_uk, unitType: $unitType, isNegative: $isNegative, isTare: $isTare, unit: $unit}';
  }
}