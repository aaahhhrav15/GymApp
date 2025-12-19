//
//  DeviceInfo.swift
//  flutter_swift
//
//  Created by 凉茶 on 2022/10/10.
//

class DeviceInfo:Codable{
    
    init(data:ICDeviceInfo){
        mac = data.mac;
        model = data.model;
        sn = data.sn;
        firmwareVer = data.firmwareVer;
        softwareVer = data.softwareVer;
        hardwareVer = data.hardwareVer;
        manufactureName = data.manufactureName;
//        kg_scale_division=data.kg_scale_division
//        lb_scale_division=data.lb_scale_division
//        isSupportHr=data.isSupportHr
//        isSupportGravity=data.isSupportGravity
//        isSupportBalance=data.isSupportBalance
//        isSupportOTA=data.isSupportOTA
//        isSupportOffline=data.isSupportOffline
//        bfDataCalcType=data.bfDataCalcType
//        isSupportUserInfo=data.isSupportUserInfo
//        maxUserCount=data.maxUserCount
//        batteryType=data.batteryType
//        bfaType = BFAType.init(type: data.bfaType.rawValue)
//        bfaType2 = BFAType.init(type: data.bfaType2.rawValue)
//        isSupportUnitKg=data.isSupportUnitKg
//        isSupportUnitLb=data.isSupportUnitLb
//        isSupportUnitStLb=data.isSupportUnitStLb
//        isSupportUnitJin=data.isSupportUnitJin
//        isSupportChangePole = false
//        pole=data.pole
//        impendenceType=data.impendenceType
//        impendenceCount=data.impendenceCount
//        impendencePrecision=data.impendencePrecision
//        impendencePropert=0
//        enableMeasureImpendence=data.enableMeasureImpendence
//        enableMeasureHr=data.enableMeasureHr
//        enableMeasureBalance=data.enableMeasureBalance
//        enableMeasureGravity=data.enableMeasureGravity
     
        
    }
    
    
    var mac = "";

    var model = "";

    var sn = "";

    var firmwareVer = "";

    var softwareVer = "";

    var hardwareVer = "";

    var manufactureName = "";

    var extInfo:String?;
    
//
//
//    var kg_scale_division:UInt;
//    var lb_scale_division:UInt;
//    var isSupportHr = false;
//    var isSupportGravity = false;
//    var isSupportBalance = false;
//    var isSupportOTA = false;
//    var isSupportOffline = false;
//    var bfDataCalcType:UInt;
//    var isSupportUserInfo = false;
//    var maxUserCount:UInt;
//    var batteryType:UInt;
//    var bfaType:BFAType? ;
//    var bfaType2:BFAType? ;
//    var isSupportUnitKg = false;
//    var isSupportUnitLb = false;
//    var isSupportUnitStLb = false;
//    var isSupportUnitJin = false;
//    var isSupportChangePole = false;
//    var pole:UInt;
//    var impendenceType:UInt;
//    var impendenceCount:UInt;
//    var impendencePrecision:UInt;
//    var impendencePropert:UInt;
//    var enableMeasureImpendence = false;
//    var enableMeasureHr = false;
//    var enableMeasureBalance = false;
//    var enableMeasureGravity  = false;
//
}
