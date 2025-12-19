//
//  WeightCenterData.swift
//  flutter_swift
//
//  Created by 凉茶 on 2022/10/10.
//

class WeightCenterData:Codable{
    
    
    init(data:ICWeightCenterData){
        isStabilized=data.isStabilized
        time=data.time
        precision_kg=data.precision_kg
        precision_lb=data.precision_lb
        precision_st_lb=data.precision_st_lb
        kg_scale_division=data.kg_scale_division
        lb_scale_division=data.lb_scale_division
        leftPercent=data.leftPercent
        rightPercent=data.rightPercent
        left_weight_g=data.left_weight_g
        right_weight_g=data.right_weight_g
        left_weight_kg=data.left_weight_kg
        right_weight_kg=data.right_weight_kg
        left_weight_lb=data.left_weight_lb
        right_weight_lb=data.right_weight_lb
        left_weight_st=data.left_weight_st
        right_weight_st=data.right_weight_st
        left_weight_st_lb=data.left_weight_st_lb
        right_weight_st_lb=data.right_weight_st_lb
     
    };
    
    /**
        数据是否稳定, 不稳定的数据只做展示用，请勿保存
     */
     var isStabilized=false;

    /**
        测量时间戳(秒)
     */
     var time:UInt;

    /**
        kg体重小数点位数,如:weight=70.12,则precision=2，weight=71.5,则precision_kg=1
     */
     var precision_kg:UInt = 1;

    /**
        lb体重小数点位数,如:weight=70.12,则precision=2，weight=71.5,则precision_lb=1
     */
     var precision_lb:UInt = 1;

    /**
        st:lb体重小数点位数
     */
    var precision_st_lb:UInt = 1;

    /**
        kg分度值
     */
     var kg_scale_division:UInt;

    /**
        lb分度值
     */
     var lb_scale_division:UInt;

    /**
        左边体重占比(%)
     */
     var leftPercent:Float;

    /**
        右边体重占比(%)
     */
     var rightPercent:Float;

    /**
        左边体重(g)
     */
     var left_weight_g:UInt;

    /**
        右边体重(g)
     */
     var right_weight_g:UInt;
    /**
        左边体重(kg)
     */
     var left_weight_kg:Float;

    /**
        右边体重(kg)
     */
     var right_weight_kg:Float;

    /**
        左边体重(lb)
     */
     var left_weight_lb:Float;

    /**
        右边体重(lb)
     */
     var right_weight_lb:Float;

    /**
        左边体重(st:lb)
     */
     var left_weight_st:UInt;

    /**
        右边体重(st:lb)
     */
     var right_weight_st:UInt;

    /**
        左边体重(st:lb)
     */
     var left_weight_st_lb:Float;

    /**
        右边体重(st:lb)
     */
     var right_weight_st_lb:Float;

}
