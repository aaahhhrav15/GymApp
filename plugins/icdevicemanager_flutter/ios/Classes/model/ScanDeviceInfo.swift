//
//  ScanDeviceInfo.swift
//  flutter_swift
//
//  Created by 凉茶 on 2022/10/9.
//


class ScanDeviceInfo:Codable{
    
    
    init(deviceInfo:ICScanDeviceInfo){
        name =  deviceInfo.name
        type = DeviceType.init(type:deviceInfo.type)
        subType = DeviceSubType.init(type:deviceInfo.subType)
        communicationType = DeviceCommunicationType.init(type:deviceInfo.communicationType)
        macAddr = deviceInfo.macAddr
        services = deviceInfo.services
        rssi = deviceInfo.rssi
        nodeId = deviceInfo.nodeId
        st_no = deviceInfo.st_no
        deviceFlag = deviceInfo.deviceFlag
        
    }
    /**
     * 广播名
     */
    var name: String?
    
    /**
     * 设备类型
     */
    var type: DeviceType?
    
    /**
     * 设备子类型
     */
    var subType: DeviceSubType?
    
    /**
     * 设备通讯方式
     */
    var communicationType: DeviceCommunicationType?
    
    /**
     * mac地址
     */
    var macAddr: String?

    /**
     * 服务ID列表
     */
    var services: Array<String>?
    
    /**
     * 信号强度(越小越大，0:系统配对设备，-128:信号值有误)
     */
    var rssi: Int?
    
    /**
     * 基站随机码
     */
    var st_no: UInt?
    
    /**
     * 节点ID
     */
    var nodeId: UInt?
    
    /**
     * 设备标记,0表示没有
     */
    var deviceFlag: UInt?
 
    
}

