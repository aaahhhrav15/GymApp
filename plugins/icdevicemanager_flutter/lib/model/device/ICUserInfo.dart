

import 'package:icdevicemanager_flutter/model/other/ICConstant.dart';
import 'package:json_annotation/json_annotation.dart';


part 'ICUserInfo.g.dart';
@JsonSerializable()
class ICUserInfo{
  /**
      用户编号,默认:1
   */
   int userIndex=1;

  /**
      用户ID,默认:0
   */
   int userId=0;

  /**
      用户呢称,默认:"icomon"
   */
   String nickName="icomon";

  /**
      身高(cm),默认:172cm
   */
   int  height=172;

  /**
      当前体重(kg),默认:60.0kg
   */
   double weight=60;
  /**
      目标体重(kg),默认:50.0kg
   */
   double targetWeight=50;

  /**
      年龄,默认:24
   */
   int age=24;

  /**
      体重方向,默认:0 减重，1:增重
   */
   int weightDirection=0;

  /**
      使用体脂算法版本,默认:ICBFATypeWLA01
   */
   ICBFAType bfaType=ICBFAType.valueOf(0);

  /**
      用户类型,默认:ICPeopleTypeNormal
   */
  ICPeopleType peopleType=ICPeopleType.ICPeopleTypeNormal;


  /**
      性别,默认:ICSexTypeMale
   */
   ICSexType sex=ICSexType.ICSexTypeMale;

  /**
      用户默认的体重单位,默认:ICWeightUnitKg
   */
   ICWeightUnit weightUnit=ICWeightUnit.ICWeightUnitKg;

  /**
      用户默认的围尺单位,默认:ICRulerUnitCM
   */
   ICRulerUnit rulerUnit=ICRulerUnit.ICRulerUnitCM;

  /**
      用户默认的围尺测量模式,默认:ICRulerMeasureModeLength
   */
   ICRulerMeasureMode rulerMode=ICRulerMeasureMode.ICRulerMeasureModeLength;


  /**
      厨房秤默认单位,默认:ICKitchenScaleUnitG
   */
   ICKitchenScaleUnit kitchenUnit=ICKitchenScaleUnit.ICKitchenScaleUnitG;

  /**
   * 是否启用测量阻抗,默认:true,仅支持的设备有效
   */
   bool enableMeasureImpendence=true;
  /**
   * 是否启用测量HR,默认:true,仅支持的设备有效
   */
   bool enableMeasureHr=true;
  /**
   * 是否启用测量平衡,默认:true,仅支持的设备有效
   */
   bool enableMeasureBalance=true;
  /**
   * 是否启用测量重心,默认:true,仅支持的设备有效
   */
   bool enableMeasureGravity=true;

  /**
   * 最后一次的阻抗
   */
   int lastImp=0;

   ICUserInfo();


   factory ICUserInfo.fromJson(Map<String, dynamic> json) => _$ICUserInfoFromJson(json);

   Map<String, dynamic> toJson() => _$ICUserInfoToJson(this);

   @override
  String toString() {
    return 'ICUserInfo{userIndex: $userIndex, userId: $userId, nickName: $nickName, height: $height, weight: $weight, targetWeight: $targetWeight, age: $age, weightDirection: $weightDirection, bfaType: $bfaType, peopleType: $peopleType, sex: $sex, weightUnit: $weightUnit, rulerUnit: $rulerUnit, rulerMode: $rulerMode, kitchenUnit: $kitchenUnit, enableMeasureImpendence: $enableMeasureImpendence, enableMeasureHr: $enableMeasureHr, enableMeasureBalance: $enableMeasureBalance, enableMeasureGravity: $enableMeasureGravity, lastImp: $lastImp}';
  }
}