//
//  RulerData.swift
//  flutter_swift
//
//  Created by 凉茶 on 2022/10/10.
//

class RulerData :Codable{
    
    
    init(data:ICRulerData){
        isStabilized=data.isStabilized
        distance=data.distance
        distance_in=data.distance_in
        distance_ft=data.distance_ft
        distance_ft_in=data.distance_ft_in
        distance_cm=data.distance_cm
        precision_in=data.precision_in
        precision_cm=data.precision_cm
        unit = RulerUnit.init(type: data.unit)
        mode = RulerMeasureMode.init(type: data.mode)
        time=data.time
        partsType = RulerBodyPartsType.init(type: data.partsType)
    };
    
    
    /**
        是否稳定数据
        @notice 如果数据不稳定，则只有distance有效，不稳定的数据只做展示用，请勿保存
     */
     var isStabilized=false;

    /**
        测量长度(0.1mm)
     */
    var distance:UInt;

    /**
        距离inch
     */
    var distance_in:Float;

    /**
        距离ft
     */
    var distance_ft:UInt;
    /**
        距离ft'in
     */
    var distance_ft_in:Float;

    /**
        距离cm
     */
    var distance_cm:Float;

    /**
        inch距离小数点位数,如:distance_in=70.12,则precision_in=2，distance_in=71.5,则precision_in=1
     */
    var precision_in:UInt = 1;

    /**
        cm距离小数点位数,如:distance_cm=70.12,则precision_cm=2，distance_cm=71.5,则precision_cm=1
     */
    var precision_cm:UInt = 1;

    /**
     *
        本次测量的单位
     */
    var unit = RulerUnit.ICRulerUnitCM;

    /**
        本次测量的单位
     */
    var mode = RulerMeasureMode.ICRulerMeasureModeLength;


    /**
        时间戳
     */
    var time:UInt;

    /**
        身体部位类型
     */
    var  partsType = RulerBodyPartsType.ICRulerPartsTypeCalf;
}
