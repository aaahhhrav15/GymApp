//
//  SkipFreqData.swift
//  flutter_swift
//
//  Created by 凉茶 on 2022/10/10.
//

class SkipFreqData:Codable{
    
    
    init(data:ICSkipFreqData){
        duration=data.duration
        skip_count=data.skip_count
    };
    
    /**
     * 持续时间
     */
    var  duration :UInt;

    /**
     * 次数
     */
    var  skip_count  :UInt;
}
