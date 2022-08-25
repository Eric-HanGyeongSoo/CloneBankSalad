//
//  Common.swift
//  CloneBankSalad
//
//  Created by CodeCamper on 2022/08/23.
//

import Foundation

enum MobileCarrier: Int, CaseIterable, Comparable {
  case SKT = 0
  case KT = 1
  case LG = 2
  case cheapSKT = 3
  case cheapKT = 4
  case cheapLG = 5
  
  static func < (lhs: MobileCarrier, rhs: MobileCarrier) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
  
  var name: String {
    switch self {
    case .SKT:
      return "SKT"
    case .KT:
      return "KT"
    case .LG:
      return "LGU+"
    case .cheapSKT:
      return "알뜰폰(SKT)"
    case .cheapKT:
      return "알뜰폰(KT)"
    case .cheapLG:
      return "알뜰폰(LGU+)"
    }
  }
}
