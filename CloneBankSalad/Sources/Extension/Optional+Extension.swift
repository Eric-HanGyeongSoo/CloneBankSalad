//
//  Optional+Extension.swift
//  CloneBankSalad
//
//  Created by 한경수 on 2022/08/21.
//

import Foundation

extension Optional {
  var isNil: Bool {
    switch self {
    case .some:
      return false
    case .none:
      return true
    }
  }
}
