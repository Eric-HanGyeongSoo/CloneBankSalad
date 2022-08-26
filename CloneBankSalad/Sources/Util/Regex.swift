//
//  Regex.swift
//  CloneBankSalad
//
//  Created by CodeCamper on 2022/08/25.
//

import Foundation


enum Regex {
  case phonePrefix
  case phone
  case genderNumber
  
  
  var pattern: String {
    switch self {
    case .phonePrefix:
      return #"^01([016789])\d*"#
    case .phone:
      return #"^01([016789])\d{3,4}\d{4}"#
    case .genderNumber:
      return #"^[123456]"#
    }
  }
  
  func validate(_ string: String) -> Bool {
    return string.range(of: pattern, options: .regularExpression) != nil
  }
}
