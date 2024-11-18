//
//  UIColor.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/11/11.
//

import UIKit
import SwiftUICore

extension UIColor {
    func toData() -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
    
    static func fromData(_ data: Data) -> UIColor? {
        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor
    }
    
    convenience init(_ color: Color) {
        let components = color.cgColor?.components ?? [0, 0, 0, 1]
        self.init(red: components[0], green: components[1], blue: components[2], alpha: components[3])
    }
    
    var isLight: Bool {
        guard let components = cgColor.components, components.count >= 3 else {
            return false
        }
        let brightness = (components[0] * 299 + components[1] * 587 + components[2] * 114) / 1000
        return brightness > 0.5
    }
}
