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
    
}
