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
  }
  
  static func assetColor(_ color: AssetColor) -> UIColor {
    return UIColor(named: color.rawValue)!
  }
}
