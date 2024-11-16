//
//  UIColor.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/11/11.
//

import UIKit

extension UIColor {
    func toData() -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
    
    static func fromData(_ data: Data) -> UIColor? {
        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor
    }
}
