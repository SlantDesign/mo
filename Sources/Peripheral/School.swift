//
//  School.swift
//  MO-iOS
//
//  Created by Andrew on 2017-10-27.
//  Copyright © 2017 Slant. All rights reserved.
//

import Foundation
import UIKit
import C4

class School: NSObject{
    let name: String
    let start: Int
    let end: Int
    let maxHeight: Double
    let label: Rectangle
    let text: TextShape
    let color: UIColor
    
    init(_ name: String, _ start: Int, _ end: Int, _ color: UIColor, _ maxHeight: Double){
        self.name = name
        self.start = start
        self.end = end
        self.text = TextShape(text: name, font: Font(name: "AppleSDGothicNeo-Bold", size: 14)!)!
        self.color = color
        text.fillColor = black
        self.label = Rectangle(frame: Rect(0.0, 0.0, 300.0, 100.0))
        label.lineWidth = 0
        self.label.fillColor = Color(color)
        text.center = Point(150, 50)
        self.maxHeight = maxHeight
        label.add(text)
        
        super.init()
    }
    
    func getLabel( _ compression: Int = 10) -> Rectangle{
        self.label.frame.height = maxHeight/Double(compression)
        self.label.center = Point(0, 0)
        return label
    }
}
