//
//  SkipData.swift
//  flutter_swift
//
//  Created by 凉茶 on 2022/10/10.
//

class SkipData :Codable{
    
    init(data:ICSkipData){
        isStabilized=data.isStabilized
        nodeId=data.nodeId
        battery=data.battery
        nodeInfo=data.nodeInfo
        time=data.time
        mode = SkipMode.init(type: data.mode.rawValue)
        setting=data.setting
        elapsed_time=data.elapsed_time
        actual_time=data.actual_time
        skip_count=data.skip_count
        avg_freq=data.avg_freq
        fastest_freq=data.fastest_freq
        freq_count=data.freq_count
        most_jump=data.most_jump
        calories_burned=data.calories_burned
        fat_burn_efficiency=data.fat_burn_efficiency
        var list = [SkipFreqData]()
        data.freqs.forEach { (element) in
            let freq = SkipFreqData.init(data:element)
            list.append(freq)
        }
        freqs = ICJson.beanToJson(bean: list)
        
    };
    
    
    
    
    /**
        是否稳定
     */
     var isStabilized=false;

    /**
        节点ID
     */
    var  nodeId:UInt;
    /**
        节点电量
     */
    var  battery:UInt;
    /**
        节点信息
     */
    var  nodeInfo:UInt;

    /**
     * 测量时间，单位:秒
     */
     var  time:UInt;

    /**
     * 跳绳模式
     */
     var  mode = SkipMode.ICSkipModeFreedom;

    /**
     * 设置的参数
     */
     var  setting:UInt;

    /**
     * 跳绳使用的时间
     */
     var  elapsed_time:UInt;

    /**
     * 跳绳实际使用的时间，不是所有都支持
     */
     var  actual_time:UInt;

    /**
     * 跳的次数
     */
     var  skip_count:UInt;

    /**
     * 平均频次
     */
     var  avg_freq:UInt;

    /**
     * 最快频次
     */
     var  fastest_freq:UInt;


    /**
     * 绊绳总数
     */
    var   freq_count :UInt;

    /**
     * 最多连跳
     */
     var   most_jump:UInt;



    /**
     * 热量消耗
     */
     var  calories_burned:Double;

    /**
     * 燃脂效率
     */
     var  fat_burn_efficiency:Double;


    /**
     * 跳绳频次数据
     */
  
    var freqs : String?;
}
