//
//  ICWUploadEvent.swift
//  flutter_swift
//
//  Created by 凉茶 on 2022/10/9.
//




struct ICWUploadEvent{
    static let    InitSDK = "InitSDK";
    
    static let    Connected = "Connected";
    static let    DisConnected = "Connected";
    
    static let    Upgrade = "onReceiveUpgradePercent";
    static let    Battery = "onReceiveBattery";
    static let    ConfigWifi = "onReceiveConfigWifiResult";
    static let    DeviceScan = "onScanResult";
    
    static let    SettingResult = "onSettingCallBack";
    static let    AddDeviceResult = "onAddDeviceCallBack";
    static let    RemoveDeviceResult = "onRemoveDeviceCallBack";
    
    static let    BluetoothChange = "onBleState";
    
    static let    ScaleData = "onReceiveWeightData";
    static let    ScaleCoordData = "onReceiveCoordData";
    static let    ScaleStepData = "onReceiveMeasureStepData";
    static let    ScaleCenterData = "onReceiveWeightCenterData";
    static let    ScaleUnitChange = "onReceiveWeightUnitChanged";
    static let    ScaleHistoryData = "onReceiveWeightHistoryData";

    
    
    
    static let    RulerData = "onReceiveRulerData";
    static let    RulerHistoryData = "onReceiveRulerHistoryData";
    static let    RulerUnitChange = "onReceiveRulerUnitChanged";
    static let    RulerModeChange = "onReceiveRulerMeasureModeChanged";
    
    
    static let    KitchenData = "onReceiveKitchenScaleData";
    
    static let    SkipData = "onReceiveSkipData";
    static let    DeviceInfo = "onReceiveDeviceInfo";
    static let    SkipBattery = "onReceiveSkipBattery";
    static let    SkipHistoryData = "onReceiveHistorySkipData";
    
    static let    ConnectChange = "onDeviceConnectionChanged";
    static let    NodConnectChange = "onNodConnectChange";
    
    static let    KitchenScaleUnitChanged = "onReceiveKitchenScaleUnitChanged";
    
    
    static let    HrData = "HrData";
    
    
}
