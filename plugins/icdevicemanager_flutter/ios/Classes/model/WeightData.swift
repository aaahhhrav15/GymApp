//
//  WeightData.swift
//  flutter_swift
//
//  Created by 凉茶 on 2022/10/9.
//

class WeightData :Codable{
    
    init(data:ICWeightData){
        userId=data.userId
        isStabilized=data.isStabilized
        weight_g=data.weight_g
        weight_kg=data.weight_kg
        weight_lb=data.weight_lb
        weight_st=data.weight_st
        weight_st_lb=data.weight_st_lb
        precision_kg=data.precision_kg
        precision_lb=data.precision_lb
        precision_st_lb=data.precision_st_lb
        kg_scale_division=data.kg_scale_division
        lb_scale_division=data.lb_scale_division
        temperature=data.temperature
        isSupportHR=data.isSupportHR
        hr=data.hr
        time=data.time
        bmi=data.bmi
        bodyFatPercent=data.bodyFatPercent
        subcutaneousFatPercent=data.subcutaneousFatPercent
        visceralFat=data.visceralFat
        musclePercent=data.musclePercent
        bmr=data.bmr
        boneMass=data.boneMass
        moisturePercent=data.moisturePercent
        physicalAge=data.physicalAge
        proteinPercent=data.proteinPercent
        smPercent=data.smPercent
        electrode=data.electrode
        bodyScore=data.bodyScore
        bodyType=data.bodyType
        targetWeight=data.targetWeight
        bfmControl=data.bfmControl
        ffmControl=data.ffmControl
        weightControl=data.weightControl
        weightStandard=data.weightStandard
        bfmStandard=data.bfmStandard
        bmiStandard=data.bmiStandard
        smmStandard=data.smmStandard
        ffmStandard=data.ffmStandard
        bfpStandard=data.bfpStandard
        
        bmrStandard=data.bmrStandard
        bmiMax=data.bmiMax
        bmiMin=data.bmiMin
        bfmMax=data.bfmMax
        bfmMin=data.bfmMin
        bfpMax=data.bfpMax
        bfpMin=data.bfpMin
        weightMax=data.weightMax
        weightMin=data.weightMin
        smmMax=data.smmMax
        smmMin=data.smmMin
        boneMax=data.boneMax
        boneMin=data.boneMin
        bmrMax=data.bmrMax
        bmrMin=data.bmrMin
        waterMassMax=data.waterMassMax
        waterMassMin=data.waterMassMin
        proteinMassMax=data.proteinMassMax
        proteinMassMin=data.proteinMassMin
        muscleMassMax=data.muscleMassMax
        smi=data.smi
        obesityDegree=data.obesityDegree
        state=data.state
        imp=data.imp
        imp2=data.imp2
        imp3=data.imp3
        imp4=data.imp4
        imp5=data.imp5
        extData = WeightExtData.init(data: data.extData)
        data_calc_type=data.data_calc_type
        bfa_type =  BFAType.init(type: data.bfa_type.rawValue)
        impendenceType=data.impendenceType
        impendenceProperty=data.impendenceProperty
        impendences =  []
        data.impendences?.forEach({  (element) in
            impendences?.append(Float(truncating: element))
        })
     
    };
    
    /**
        用户ID,默认:0
     */
    var  userId:UInt = 0;

    /**
        是否稳定数据,如果数据不稳定，则只有weight有效，不稳定的数据只做展示用，请勿保存
     */
    var isStabilized = false;

    /**
        体重(g)
     */
    var weight_g:UInt = 0;

    /**
        体重(kg)
     */
    var weight_kg :Float = 0.0 ;

    /**
        体重(磅)
     */
    var weight_lb :Float = 0.0;

    /**
        体重(st:lb)，注:这个字段跟weight_st_lb一起使用
     */
    var weight_st:UInt  ;

    /**
        体重(st:lb)，注:这个字段跟weight_st一起使用
     */
    var weight_st_lb :Float = 0.0;

    /**
        kg体重小数点位数,如:weight_kg=70.12,则precision=2，weight_kg=71.5,则precision_kg=1
     */
    var precision_kg:UInt = 1;

    /**
        lb体重小数点位数,如:weight_lb=70.12,则precision=2，weight_lb=71.5,则precision_lb=1
     */
    var precision_lb :UInt = 1;

    /**
        st:lb体重小数点位数
     */
    var precision_st_lb:UInt = 1;

    /**
        kg分度值
     */
    var kg_scale_division:UInt  = 0;

    /**
        lb分度值
     */
    var lb_scale_division:UInt  = 0;

    /**
        温度
     */
    var temperature:Float = 0.0;

    /**
        支持心率测量
     */
    var isSupportHR = false;

    /**
        心率值
     */
    var hr :UInt = 0;

    /**
        时间戳
     */
    var time:UInt = 0;

    /**
        身体质量指数BMI(精度:0.1)
     */
    var bmi:Float = 0.0;

    /**
        体脂率(百分比, 精度:0.1)
     */
    var bodyFatPercent :Float = 0.0;

    /**
        皮下脂肪率(百分比, 精度:0.1)
     */
    var subcutaneousFatPercent : Float = 0.0;

    /**
        内脏脂肪指数(精度:0.1)
     */
    var visceralFat : Float = 0.0;

    /**
        肌肉率(百分比, 精度:0.1)
     */
    var musclePercent : Float = 0.0;

    /**
        基础代谢率(单位:kcal)
     */
    var bmr:UInt = 0;

    /**
        骨重量(单位:kg,精度:0.1)
     */
    var boneMass : Float = 0.0;

    /**
        水含量(百分比,精度:0.1)
     */
    var moisturePercent : Float = 0.0;

    /**
        身体年龄
     */
    var physicalAge : Float = 0.0;

    /**
        蛋白率(百分比,精度:0.1)
     */
    var proteinPercent : Float = 0.0;

    /**
        骨骼肌率(百分比,精度:0.1)
     */
    var smPercent : Float = 0.0;

    /**
        电极数，4电极或者8电极
     */
    var electrode:UInt = 4;

    /**
        身体评分
     */
    var bodyScore : Float = 0.0;

    /**
        身体类型
     */
    var bodyType:UInt  = 0;

    /**
        目标体重
     */
    var targetWeight : Float = 0.0;

    /**
        脂肪量控制
     */
    var bfmControl : Float = 0.0;

    /**
        去脂体重控制
     */
    var ffmControl : Float = 0.0;

    /**
        体重控制
     */
    var weightControl : Float = 0.0;

    /**
        标准体重
     */
    var weightStandard : Float = 0.0;

    /**
        标准脂肪量
     */
    var bfmStandard : Float = 0.0;

    /**
        标准BMI
     */
    var bmiStandard : Float = 0.0;

    /**
        标准骨骼肌量
     */
    var smmStandard : Float = 0.0;

    /**
        标准去脂体重
     */
    var ffmStandard : Float = 0.0;

    var bfpStandard : Float = 0.0; // 标准脂肪率
    var bmrStandard:Int32 = 0; // 标准BMR

    var bmiMax : Float = 0.0;
    var bmiMin : Float = 0.0;
    var bfmMax : Float = 0.0;
    var bfmMin : Float = 0.0;
    var bfpMax : Float = 0.0;
    var bfpMin : Float = 0.0;
    var weightMax : Float = 0.0;
    var weightMin : Float = 0.0;
    var smmMax : Float = 0.0;
    var smmMin : Float = 0.0;
    var boneMax : Float = 0.0;
    var boneMin : Float = 0.0;
    var bmrMax:UInt = 0;
    var bmrMin:UInt = 0;
    var waterMassMax : Float = 0.0;
    var waterMassMin : Float = 0.0;
    var proteinMassMax : Float = 0.0;
    var proteinMassMin : Float = 0.0;
    var muscleMassMax : Float = 0.0;
    var muscleMassMin : Float = 0.0;

    /**
        骨骼肌质量指数
     */
    var smi : Float = 0.0;

    /**
        肥胖程度
     */
    var obesityDegree :UInt = 0;

    var state :UInt = 0;

    /**
        全身阻抗(8电极)或全身阻抗(4电极)(单位:欧姆ohm),如阻抗等于0，则代表测量不到阻抗
     */
    var imp : Float = 0.0;

    /**
        左手阻抗(8电极)(单位:欧姆ohm),如阻抗等于0，则代表测量不到阻抗
     */
    var imp2 : Float = 0.0;

    /**
        右手阻抗(8电极)(单位:欧姆ohm),如阻抗等于0，则代表测量不到阻抗
     */
    var imp3 : Float = 0.0;

    /**
        左腳阻抗(8电极)(单位:欧姆ohm),如阻抗等于0，则代表测量不到阻抗
     */
    var imp4 : Float = 0.0;

    /**
        右腳阻抗(8电极)(单位:欧姆ohm),如:阻抗等于0，则代表测量不到阻抗
     */
    var imp5 : Float = 0.0;

    /**
        体重扩展数据(8电极的部分数据在这里面)
     */
    var extData: WeightExtData? ;

    /**
        数据计算方式(0:sdk，1:设备计算，2:app计算)
     */
    var data_calc_type :UInt = 0;

    /**
        本次体脂数据计算的算法类型
     */
    var  bfa_type :BFAType = BFAType.ICBFATypeWLA02;

    var impendenceType :UInt = 0;

    var impendenceProperty:UInt = 0;


    var impendences:[Float]?;

    
}

