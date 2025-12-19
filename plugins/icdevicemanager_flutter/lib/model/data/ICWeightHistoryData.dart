

import 'package:icdevicemanager_flutter/model/converter/ICWeightCenterDataConverter.dart';
import 'package:json_annotation/json_annotation.dart';

import '../other/ICConstant.dart';
import 'ICWeightCenterData.dart';


part 'ICWeightHistoryData.g.dart';

@JsonSerializable()
class ICWeightHistoryData {
  /**
      用户ID,默认:0
   */
  int userId = 0;

  /**
      体重(g)
   */
  int weight_g = 0;

  /**
      体重(kg)
   */
  double weight_kg = 0.0;

  /**
      体重(lb)
   */
  double weight_lb = 0.0;

  /**
      体重(st:lb)，注:这个字段跟weight_st_lb一起使用
   */
  int weight_st = 0;

  /**
      体重(st:lb)，注:这个字段跟weight_st一起使用
   */
  double weight_st_lb = 0.0;

  /**
      kg体重小数点位数,如:weight_kg=70.12,则precision=2，weight_kg=71.5,则precision_kg=1
   */
  int precision_kg = 1;

  /**
      lb体重小数点位数,如:weight_lb=70.12,则precision=2，weight_lb=71.5,则precision_lb=1
   */
  int precision_lb = 1;

  /**
      st:lb体重小数点位数
   */
  int precision_st_lb = 1;

  /**
      kg分度值
   */
  int kg_scale_division = 0;

  /**
      lb分度值
   */
  int lb_scale_division = 0;

  /**
      测量时间戳(秒)
   */
  int time = 0;

  /**
      心率值
   */
  int hr = 0;

  /**
      电极数，4电极或者8电极
   */
  int electrode = 4;

  /**
      全身阻抗(单位:欧姆ohm), `electrode=4`时，只使用这个阻抗,如阻抗等于0，则代表测量不到阻抗
   */
  double imp = 0;

  /**
      左手阻抗(8电极)(单位:欧姆ohm),如阻抗等于0，则代表测量不到阻抗
   */
  double imp2 = 0;

  /**
      右手阻抗(8电极)(单位:欧姆ohm),如阻抗等于0，则代表测量不到阻抗
   */
  double imp3 = 0;

  /**
      左腳阻抗(8电极)(单位:欧姆ohm),如阻抗等于0，则代表测量不到阻抗
   */
  double imp4 = 0;

  /**
      右腳阻抗(8电极)(单位:欧姆ohm),如阻抗等于0，则代表测量不到阻抗
   */
  double imp5 = 0;

  /**
      平衡数据
   */
  @ICWeightCenterDataConverter()
  ICWeightCenterData? centerData;

  /**
      数据计算方式(0:sdk，1:设备计算)
   */
  int data_calc_type = 0;

  /**
      本次体脂数据计算的算法类型
   */
  ICBFAType bfa_type = ICBFAType.ICBFATypeUnknown;

  int impendenceType = 0;

  int impendenceProperty = 0;

  List<double>? impendences;

  ICWeightHistoryData();


  factory ICWeightHistoryData.fromJson(Map<String, dynamic> json) => _$ICWeightHistoryDataFromJson(json);
  Map<String, dynamic> toJson() => _$ICWeightHistoryDataToJson(this);

  @override
  String toString() {
    return 'ICWeightHistoryData{userId: $userId, weight_g: $weight_g, weight_kg: $weight_kg, weight_lb: $weight_lb, weight_st: $weight_st, weight_st_lb: $weight_st_lb, precision_kg: $precision_kg, precision_lb: $precision_lb, precision_st_lb: $precision_st_lb, kg_scale_division: $kg_scale_division, lb_scale_division: $lb_scale_division, time: $time, hr: $hr, electrode: $electrode, imp: $imp, imp2: $imp2, imp3: $imp3, imp4: $imp4, imp5: $imp5, centerData: $centerData, data_calc_type: $data_calc_type, bfa_type: $bfa_type, impendenceType: $impendenceType, impendenceProperty: $impendenceProperty, impendences: $impendences}';
  }
}
