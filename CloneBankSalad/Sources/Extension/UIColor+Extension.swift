//
//  UIColor+Extension.swift
//  CloneBankSalad
//
//  Created by 한경수 on 2022/08/21.
//

import Foundation
import UIKit

extension UIColor {
  enum AssetColor: String {
    case co_111111
    case co_656e77
    case co_353a40
    case co_656d75
    case co_fafafa
    case co_e9eaee
    case co_878f9c
    case co_010207
    case co_e4e7ee
    case co_848894
    case co_2b3034
    case co_0f0f0f
    case co_30363e
    case co_ee2440
    case co_a5a8af
    case co_5a7fc6
    case co_1ac66d
  }
  
  static func assetColor(_ color: AssetColor) -> UIColor {
    return UIColor(named: color.rawValue)!
  }
}
