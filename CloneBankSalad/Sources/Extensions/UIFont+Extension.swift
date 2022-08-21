//
//  UIFont+Extension.swift
//  CloneBankSalad
//
//  Created by 한경수 on 2022/08/21.
//

import Foundation
import UIKit

extension UIFont {
  enum notoSans: String {
    case thin = "NotoSansKR-Thin"
    case regular = "NotoSansKR-Regular"
    case medium = "NotoSansKR-Medium"
    case light = "NotoSansKR-Light"
    case bold = "NotoSansKR-Bold"
    case black = "NotoSansKR-Black"
    
    public func font(size: CGFloat) -> UIFont {
      return UIFont(name: self.rawValue, size: size)!
    }
  }
}
