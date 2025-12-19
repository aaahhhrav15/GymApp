//
//  CoordData.swift
//  flutter_swift
//
//  Created by 凉茶 on 2022/10/13.
//

class CoordData:Codable{
    
    init(data:ICCoordData){
        time=data.time;
        x=data.x;
        y=data.y;
    }
    var time:UInt = 0;
    var x:Int = 0;
    var y:Int = 0;
}
