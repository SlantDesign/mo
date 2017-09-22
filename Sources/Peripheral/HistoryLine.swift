//
//  HistoryLine.swift
//  MO-iOS
//
//  Created by Andrew on 2017-09-19.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import C4

class HistoryLine: View {
    var lines = [Line]()
    var total = 0
    
    init(width: Int){
        super.init()
        for i in 0...99 {
            lines.append(Line(begin: Point(width*(i-50)/100, -100), end: Point(width*(i-50)/100, 100)))
            self.lines[i].strokeColor = black
            self.lines[i].lineWidth = 4
            self.add(lines[i])
        }
    }
    
    public func newPoint(length: Double, isGreen: Bool){
        if(total<100){
            switch isGreen{
                case true:
                    lines[total].strokeColor = green
                    //lines[total].endPoints.1.y = -100+200*length
                case false:
                    lines[total].strokeColor = red
                    //lines[total].endPoints.1.y = 100
            }
        }
        else{
            switch isGreen{
            case true:
                lines[total%100].strokeColor = green
                lines[(total+1)%100].strokeColor = black
                //lines[total%100].endPoints.1.y = -100+200*length
            case false:
                lines[total%100].strokeColor = red
                //lines[total%100].endPoints.1.y = 100
            }
            
        }
        
        total += 1
    }
}

