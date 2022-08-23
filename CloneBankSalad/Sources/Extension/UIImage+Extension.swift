//
//  UIImage+Extension.swift
//  CloneBankSalad
//
//  Created by 한경수 on 2022/08/21.
//

import Foundation
import UIKit

extension UIImage {
  enum AssetImage: String {
    case onboarding_clear
    case onboarding_secure_star
    case onboarding_hyphen
    case onboarding_arrow_down
  }
  
  static func assetImage(_ image: AssetImage) -> UIImage {
    return UIImage(named: image.rawValue)!
  }
}
