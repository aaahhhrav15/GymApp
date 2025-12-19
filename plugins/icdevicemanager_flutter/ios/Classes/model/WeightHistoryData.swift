//
//  WeightHistoryData.swift
//  flutter_swift
//
//  Created by 凉茶 on 2022/10/10.
//

class WeightHistoryData :Codable{
    
    init(data:ICWeightHistoryData){
        userId=data.userId
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
        hr=data.hr
        time=data.time
        electrode=data.electrode
        imp=data.imp
        imp2=data.imp2
        imp3=data.imp3
        imp4=data.imp4
        imp5=data.imp5
        data_calc_type=data.data_calc_type
        bfa_type =  BFAType.init(type: data.bfa_type.rawValue)
        impendenceType=data.impendenceType
        impendenceProperty=data.impendenceProperty
        impendences =  []
        data.impendences.forEach { (element)  in
            impendences?.append(Float(truncating: element))
        }
      
     
    };
    
    /**
     用户ID,默认:0
     */
    var userId:UInt;
    
    /**
     体重(g)
     */
    var weight_g :UInt;
    
    /**
     体重(kg)
     */
    var weight_kg :Float;
    
    /**
     体重(lb)
     */
    var weight_lb:Float;
    
    /**
     体重(st:lb)，注:这个字段跟weight_st_lb一起使用
     */
    var weight_st :UInt;
    
    /**
     体重(st:lb)，注:这个字段跟weight_st一起使用
     */
    var weight_st_lb :Float;
    
    /**
     kg体重小数点位数,如:weight_kg=70.12,则precision=2，weight_kg=71.5,则precision_kg=1
     */
    var precision_kg:UInt  = 1;
    
    /**
     lb体重小数点位数,如:weight_lb=70.12,则precision=2，weight_lb=71.5,则precision_lb=1
     */
    var precision_lb:UInt  = 1;
    
    /**
     st:lb体重小数点位数
     */
    var precision_st_lb:UInt = 1;
    
    /**
     kg分度值
     */
    var kg_scale_division :UInt;
    
    /**
     lb分度值
     */
    var lb_scale_division :UInt;
    
    /**
     测量时间戳(秒)
     */
    var time :UInt;
    
    /**
     心率值
     */
    var hr :UInt;
    
    /**
     电极数，4电极或者8电极
     */
    var electrode:UInt  = 4;
    
    /**
     全身阻抗(单位:欧姆ohm), `electrode=4`时，只使用这个阻抗,如阻抗等于0，则代表测量不到阻抗
     */
    var imp :Float;
    
    /**
     左手阻抗(8电极)(单位:欧姆ohm),如阻抗等于0，则代表测量不到阻抗
     */
    var imp2 :Float;
    
    /**
     右手阻抗(8电极)(单位:欧姆ohm),如阻抗等于0，则代表测量不到阻抗
     */
    var imp3 :Float;
    
    /**
     左腳阻抗(8电极)(单位:欧姆ohm),如阻抗等于0，则代表测量不到阻抗
     */
    var imp4 :Float;
    
    /**
     右腳阻抗(8电极)(单位:欧姆ohm),如阻抗等于0，则代表测量不到阻抗
     */
    var imp5 :Float;
    
    /**
     平衡数据
     */
    
    var  centerData:WeightCenterData?;
    
    /**
     数据计算方式(0:sdk，1:设备计算)
     */
    var data_calc_type :UInt;
    
    /**
     本次体脂数据计算的算法类型
     */
    var bfa_type = BFAType.ICBFATypeUnknown;
    
    var impendenceType :UInt;
    
    var impendenceProperty :UInt;
    
    var impendences:[Float]?;
    
    
}
