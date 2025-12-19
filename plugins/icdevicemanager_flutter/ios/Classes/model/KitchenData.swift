//
//  KitchenData.swift
//  flutter_swift
//
//  Created by 凉茶 on 2022/10/10.
//

class KitchenData:Codable{
    
    
    init(data:ICKitchenScaleData){
        isStabilized=data.isStabilized
        value_mg=data.value_mg
        value_g=data.value_g
        value_ml=data.value_ml
        value_ml_milk=data.value_ml_milk
        value_oz=data.value_oz
        value_lb=data.value_lb
        value_lb_oz=data.value_lb_oz
        value_fl_oz=data.value_fl_oz
        value_fl_oz_uk=data.value_fl_oz_uk
        value_fl_oz_milk=data.value_fl_oz_milk
        value_fl_oz_milk_uk=data.value_fl_oz_milk_uk
        time=data.time
        precision=data.precision
        precision_g=data.precision_g
        precision_ml=data.precision_ml
        precision_lboz=data.precision_lboz
        precision_oz=data.precision_oz
        precision_ml_milk=data.precision_ml_milk
        precision_floz_us=data.precision_floz_us
        precision_floz_uk=data.precision_floz_uk
        precision_floz_milk_us=data.precision_floz_milk_us
        precision_floz_milk_uk=data.precision_floz_milk_uk
        unitType=data.unitType
        isNegative=data.isNegative
        isTare = data.isTare
        unit =  KitchenScaleUnit.init(type: data.unit)
    };
        
    
    /**
        是否稳定数据, 不稳定的数据只做展示用，请勿保存
     */
     var isStabilized=false;

    /**
        数据值,单位:mg
     */
    var value_mg :UInt;

    /**
        数据值,单位:g
     */
    var value_g:Float;

    /**
        数据值,单位:ml
     */
    var value_ml:Float;
    /**
        数据值,单位:ml milk
     */
    var value_ml_milk:Float;

    /**
        数据值,单位:oz
     */
    var value_oz:Float;

    /**
        数据值,单位:lb:oz中的lb
     */
    var value_lb:UInt;

    /**
        数据值,单位:lb:oz中的oz
     */
    var value_lb_oz:Float;

    /**
        数据值,单位:fl.oz,美制
     */
    var value_fl_oz:Float;

    /**
        数据值,单位:fl.oz，英制
     */
    var value_fl_oz_uk:Float;

    /**
        数据值,单位:fl.oz,美制
     */
    var value_fl_oz_milk:Float;

    /**
        数据值,单位:fl.oz，英制
     */
    var value_fl_oz_milk_uk:Float;

    /**
        测量时间戳(秒)
     */
    var time:UInt;

    /**
        小数点位数,如:value_lb=70.12,则precision=2，value_lb=71.5,则precision=1
     */
    var precision:UInt = 1;
    /**
        小数点位数,如:value_lb=70.12,则precision=2，value_lb=71.5,则precision=1
     */
    var precision_g:UInt;
    /**
        小数点位数,如:value_lb=70.12,则precision=2，value_lb=71.5,则precision=1
     */
    var precision_ml:UInt;
    /**
        小数点位数,如:value_lb=70.12,则precision=2，value_lb=71.5,则precision=1
     */
    var precision_lboz:UInt;
    /**
        小数点位数,如:value_lb=70.12,则precision=2，value_lb=71.5,则precision=1
     */
    var precision_oz:UInt;
    /**
        小数点位数,如:value_lb=70.12,则precision=2，value_lb=71.5,则precision=1
     */
    var precision_ml_milk:UInt;
    /**
        小数点位数,如:value_lb=70.12,则precision=2，value_lb=71.5,则precision=1
     */
    var precision_floz_us:UInt;
    /**
        小数点位数,如:value_lb=70.12,则precision=2，value_lb=71.5,则precision=1
     */
    var precision_floz_uk:UInt;
    /**
        小数点位数,如:value_lb=70.12,则precision=2，value_lb=71.5,则precision=1
     */
    var precision_floz_milk_us:UInt;

    /**
        小数点位数,如:value_lb=70.12,则precision=2，value_lb=71.5,则precision=1
     */
    var precision_floz_milk_uk:UInt;
    /**
        设备数据单位类型,0:公制，1:美制，2:英制
     */
    var unitType:UInt;

    /**
        数字是否负数
     */
    var  isNegative = false;

    /**
        是否去皮模式
     */
    var isTare = false;

    /**
        ///本次数据单位
     */
    var  unit:KitchenScaleUnit
}
