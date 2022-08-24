//
//  UIFont+Extension.swift
//  CloneBankSalad
//
//  Created by 한경수 on 2022/08/21.
//

import Foundation
import UIKit

extension UIFont {
  enum AppleSDGothicNeo: String {
    case ultraLight = "AppleSDGothicNeo-UltraLight"
    case light = "AppleSDGothicNeo-Light"
    case thin = "AppleSDGothicNeo-Thin"
    case medium = "AppleSDGothicNeo-Medium"
    case regular = "AppleSDGothicNeo-Regular"
    case semiBold = "AppleSDGothicNeo-SemiBold"
    case bold = "AppleSDGothicNeo-Bold"
  }
  
  static func appleSDGothicNeo(size: CGFloat, weight: AppleSDGothicNeo? = .regular) -> UIFont {
    let weight = weight ?? .regular
    return UIFont(name: weight.rawValue, size: size)!
  }
}

extension UIFont {
  enum Pretendard: String {
    case extraLight = "Pretendard-ExtraLight"
    case light = "Pretendard-Light"
    case thin = "Pretendard-Thin"
    case medium = "Pretendard-Medium"
    case regular = "Pretendard-Regular"
    case semiBold = "Pretendard-SemiBold"
    case bold = "Pretendard-Bold"
  }
  
  static func pretendard(size: CGFloat, weight: Pretendard? = .regular) -> UIFont {
    let weight = weight ?? .regular
    return UIFont(name: weight.rawValue, size: size)!
  }
}
