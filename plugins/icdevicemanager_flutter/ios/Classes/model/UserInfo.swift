//
//  UserInfo.swift
//  flutter_swift
//
//  Created by 凉茶 on 2022/10/10.
//
class UserInfo:Codable{
    
    /**
        用户编号,默认:1
     */
    var userIndex :UInt = 1;

    /**
        用户ID,默认:0
     */
     var userId :UInt = 0;

    /**
        用户呢称,默认:"icomon"
     */
     var  nickName="icomon";

    /**
        身高(cm),默认:172cm
     */
    var  height:UInt = 172;

    /**
        当前体重(kg),默认:60.0kg
     */
    var weight:Float = 60;
    /**
        目标体重(kg),默认:50.0kg
     */
    var targetWeight:Float = 50;

    /**
        年龄,默认:24
     */
    var age:UInt = 24;

    /**
        体重方向,默认:0 减重，1:增重
     */
     var weightDirection:UInt  = 0;

    /**
        使用体脂算法版本,默认:ICBFATypeWLA01
     */
    var bfaType = BFAType.ICBFATypeWLA01

    /**
        用户类型,默认:ICPeopleTypeNormal
     */
    var   peopleType = PeopleType.ICPeopleTypeNormal;


    /**
        性别,默认:ICSexTypeMale
     */
    var  sex = SexType.ICSexTypeMale;

    /**
        用户默认的体重单位,默认:ICWeightUnitKg
     */
    var   weightUnit = ScaleUnit.ICWeightUnitKg;

    /**
        用户默认的围尺单位,默认:ICRulerUnitCM
     */
    var   rulerUnit=RulerUnit.ICRulerUnitCM;

    /**
        用户默认的围尺测量模式,默认:ICRulerMeasureModeLength
     */
    var   rulerMode = RulerMeasureMode.ICRulerMeasureModeLength;


    /**
        厨房秤默认单位,默认:ICKitchenScaleUnitG
     */
    var   kitchenUnit = KitchenScaleUnit.ICKitchenScaleUnitG;

    /**
     * 是否启用测量阻抗,默认:true,仅支持的设备有效
     */
    var enableMeasureImpendence = true;
    /**
     * 是否启用测量HR,默认:true,仅支持的设备有效
     */
    var enableMeasureHr = true;
    /**
     * 是否启用测量平衡,默认:true,仅支持的设备有效
     */
    var enableMeasureBalance = true;
    /**
     * 是否启用测量重心,默认:true,仅支持的设备有效
     */
    var  enableMeasureGravity = true;

    /**
     * 最后一次的阻抗
     */
    var lastImp:UInt = 0;

}
