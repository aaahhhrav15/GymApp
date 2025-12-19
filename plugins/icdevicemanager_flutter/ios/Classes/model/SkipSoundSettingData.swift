//
//  SkipSoundSettingData.swift
//  flutter_swift
//
//  Created by 凉茶 on 2022/10/10.
//

class SkipSoundSettingData:Codable{
    
    
    init(data:ICSkipSoundSettingData){
        soundOn=data.soundOn
        soundType = SkipSoundType.init(type: data.soundType) 
        soundVolume=data.soundVolume
        fullScoreOn=data.fullScoreOn
        fullScoreBPM=data.fullScoreBPM
        modeParam=data.modeParam
        isAutoStop=data.isAutoStop
        soundMode=SkipSoundMode.init(type: data.soundMode)
    }
    
    
    /*
         是否开启语音开关
        */
     var soundOn = false;

     /*
         语音类型
         */
    var  soundType = SkipSoundType.ICSkipSoundTypeFemale;

     /*
        声音大小
        */
    var soundVolume:UInt = 0;

     /*
        满分开关
        */
    var fullScoreOn = false;

     /*
        满分速率
        */
    var fullScoreBPM :UInt = 0;

     /*
        语音间隔模式
        */
    var  soundMode = SkipSoundMode.ICSkipSoundModeCount;

     /*
       模式参数
        */
    var modeParam:UInt = 0;

     /*
       是否自动停止播放，true:APP下发开始后，跳绳不会播放语音 ，false:跳绳和APP都会播放语音
        */
    var isAutoStop = false;

    
}
