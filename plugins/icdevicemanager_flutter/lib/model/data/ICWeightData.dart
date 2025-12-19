

import 'package:icdevicemanager_flutter/model/converter/ICWeightCenterDataConverter.dart';
import 'package:icdevicemanager_flutter/model/data/ICWeightExtData.dart';
import 'package:json_annotation/json_annotation.dart';


import '../other/ICConstant.dart';

part 'ICWeightData.g.dart';

@JsonSerializable()
class ICWeightData {
  /**
      用户ID,默认:0
   */
  int? userId = 0;

  /**
      是否稳定数据,如果数据不稳定，则只有weight有效，不稳定的数据只做展示用，请勿保存
   */
  bool isStabilized = false;

  /**
      体重(g)
   */
  int weight_g = 0;

  /**
      体重(kg)
   */
  double weight_kg = 0.0;

  /**
      体重(磅)
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
      温度
   */
  double temperature = 0.0;

  /**
      支持心率测量
   */
  bool isSupportHR = false;

  /**
      心率值
   */
  int hr = 0;

  /**
      时间戳
   */
  int time = 0;

  /**
      身体质量指数BMI(精度:0.1)
   */
  double bmi = 0.0;

  /**
      体脂率(百分比, 精度:0.1)
   */
  double bodyFatPercent = 0.0;

  /**
      皮下脂肪率(百分比, 精度:0.1)
   */
  double subcutaneousFatPercent = 0.0;

  /**
      内脏脂肪指数(精度:0.1)
   */
  double visceralFat = 0.0;

  /**
      肌肉率(百分比, 精度:0.1)
   */
  double musclePercent = 0.0;

  /**
      基础代谢率(单位:kcal)
   */
  int bmr = 0;

  /**
      骨重量(单位:kg,精度:0.1)
   */
  double boneMass = 0.0;

  /**
      水含量(百分比,精度:0.1)
   */
  double moisturePercent = 0.0;

  /**
      身体年龄
   */
  double physicalAge = 0.0;

  /**
      蛋白率(百分比,精度:0.1)
   */
  double proteinPercent = 0.0;

  /**
      骨骼肌率(百分比,精度:0.1)
   */
  double smPercent = 0.0;

  /**
      电极数，4电极或者8电极
   */
  int electrode = 4;

  /**
      身体评分
   */
  double bodyScore = 0.0;

  /**
      身体类型
   */
  int bodyType = 0;

  /**
      目标体重
   */
  double targetWeight = 0.0;

  /**
      脂肪量控制
   */
  double bfmControl = 0.0;

  /**
      去脂体重控制
   */
  double ffmControl = 0.0;

  /**
      体重控制
   */
  double weightControl = 0.0;

  /**
      标准体重
   */
  double weightStandard = 0.0;

  /**
      标准脂肪量
   */
  double bfmStandard = 0.0;

  /**
      标准BMI
   */
  double bmiStandard = 0.0;

  /**
      标准骨骼肌量
   */
  double smmStandard = 0.0;

  /**
      标准去脂体重
   */
  double ffmStandard = 0.0;

  double bfpStandard = 0.0; // 标准脂肪率
  int bmrStandard = 0; // 标准BMR

  double bmiMax = 0.0;
  double bmiMin = 0.0;
  double bfmMax = 0.0;
  double bfmMin = 0.0;
  double bfpMax = 0.0;
  double bfpMin = 0.0;
  double weightMax = 0.0;
  double weightMin = 0.0;
  double smmMax = 0.0;
  double smmMin = 0.0;
  double boneMax = 0.0;
  double boneMin = 0.0;
  int bmrMax = 0;
  int bmrMin = 0;
  double waterMassMax = 0.0;
  double waterMassMin = 0.0;
  double proteinMassMax = 0.0;
  double proteinMassMin = 0.0;
  double muscleMassMax = 0.0;
  double muscleMassMin = 0.0;

  /**
      骨骼肌质量指数
   */
  double smi = 0.0;

  /**
      肥胖程度
   */
  int obesityDegree = 0;

  int state = 0;

  /**
      全身阻抗(8电极)或全身阻抗(4电极)(单位:欧姆ohm),如阻抗等于0，则代表测量不到阻抗
   */
  double imp = 0.0;

  /**
      左手阻抗(8电极)(单位:欧姆ohm),如阻抗等于0，则代表测量不到阻抗
   */
  double imp2 = 0.0;

  /**
      右手阻抗(8电极)(单位:欧姆ohm),如阻抗等于0，则代表测量不到阻抗
   */
  double imp3 = 0.0;

  /**
      左腳阻抗(8电极)(单位:欧姆ohm),如阻抗等于0，则代表测量不到阻抗
   */
  double imp4 = 0.0;

  /**
      右腳阻抗(8电极)(单位:欧姆ohm),如:阻抗等于0，则代表测量不到阻抗
   */
  double imp5 = 0.0;

  /**
      体重扩展数据(8电极的部分数据在这里面)
   */
  @ICWeightCenterDataConverter()
  ICWeightExtData? extData;

  /**
      数据计算方式(0:sdk，1:设备计算，2:app计算)
   */
  int data_calc_type = 0;

  /**
      本次体脂数据计算的算法类型
   */
  ICBFAType? bfa_type = ICBFAType.ICBFATypeUnknown;

  int impendenceType = 0;

  int impendenceProperty = 0;


  List<double>? impendences ;



  ICWeightData();

  factory ICWeightData.fromJson(Map<String, dynamic> json) => _$ICWeightDataFromJson(json);
  Map<String, dynamic> toJson() => _$ICWeightDataToJson(this);

  @override
  String toString() {
    return 'ICWeightData{userId: $userId, isStabilized: $isStabilized, weight_g: $weight_g, weight_kg: $weight_kg, weight_lb: $weight_lb, weight_st: $weight_st, weight_st_lb: $weight_st_lb, precision_kg: $precision_kg, precision_lb: $precision_lb, precision_st_lb: $precision_st_lb, kg_scale_division: $kg_scale_division, lb_scale_division: $lb_scale_division, temperature: $temperature, isSupportHR: $isSupportHR, hr: $hr, time: $time, bmi: $bmi, bodyFatPercent: $bodyFatPercent, subcutaneousFatPercent: $subcutaneousFatPercent, visceralFat: $visceralFat, musclePercent: $musclePercent, bmr: $bmr, boneMass: $boneMass, moisturePercent: $moisturePercent, physicalAge: $physicalAge, proteinPercent: $proteinPercent, smPercent: $smPercent, electrode: $electrode, bodyScore: $bodyScore, bodyType: $bodyType, targetWeight: $targetWeight, bfmControl: $bfmControl, ffmControl: $ffmControl, weightControl: $weightControl, weightStandard: $weightStandard, bfmStandard: $bfmStandard, bmiStandard: $bmiStandard, smmStandard: $smmStandard, ffmStandard: $ffmStandard, bfpStandard: $bfpStandard, bmrStandard: $bmrStandard, bmiMax: $bmiMax, bmiMin: $bmiMin, bfmMax: $bfmMax, bfmMin: $bfmMin, bfpMax: $bfpMax, bfpMin: $bfpMin, weightMax: $weightMax, weightMin: $weightMin, smmMax: $smmMax, smmMin: $smmMin, boneMax: $boneMax, boneMin: $boneMin, bmrMax: $bmrMax, bmrMin: $bmrMin, waterMassMax: $waterMassMax, waterMassMin: $waterMassMin, proteinMassMax: $proteinMassMax, proteinMassMin: $proteinMassMin, muscleMassMax: $muscleMassMax, muscleMassMin: $muscleMassMin, smi: $smi, obesityDegree: $obesityDegree, state: $state, imp: $imp, imp2: $imp2, imp3: $imp3, imp4: $imp4, imp5: $imp5, extData: $extData, data_calc_type: $data_calc_type, bfa_type: $bfa_type, impendenceType: $impendenceType, impendenceProperty: $impendenceProperty, impendences: $impendences}';
  }
}
