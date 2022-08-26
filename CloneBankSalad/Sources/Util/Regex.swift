//
//  Regex.swift
//  CloneBankSalad
//
//  Created by CodeCamper on 2022/08/25.
//

import Foundation


enum Regex {
  case name
  case genderNumber
  case phonePrefix
  case phone
  
  
  var pattern: String {
    switch self {
    case .name:
      return #"^[ㄱ-ㅎ|가-힣|a-z|A-Z|\s|]*$"#
    case .genderNumber:
      return #"^[123456]"#
    case .phonePrefix:
      return #"^01([016789])\d*"#
    case .phone:
      return #"^01([016789])\d{3,4}\d{4}"#
    }
  }
  
  func validate(_ string: String) -> Bool {
    return string.range(of: pattern, options: .regularExpression) != nil
  }
}
