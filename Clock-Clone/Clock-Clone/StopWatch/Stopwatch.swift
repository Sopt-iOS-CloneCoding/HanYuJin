//
//  Stopwatch.swift
//  Clock-Clone
//
//  Created by 한유진 on 2022/04/25.
//

import Foundation

class Stopwatch : NSObject {
    var counter : Double
    var timer : Timer
    
    override init() {
        counter = 0.0
        timer = Timer()
    }
}
