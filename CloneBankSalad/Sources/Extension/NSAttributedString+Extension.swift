//
//  NSAttributedString+Extension.swift
//  CloneBankSalad
//
//  Created by 한경수 on 2022/08/21.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
  var wholeRange: NSRange {
    return NSMakeRange(0, self.length)
  }
  
  func setFont(_ font: UIFont, range: NSRange? = nil) {
    let range = range.isNil ? wholeRange : range!
    self.addAttribute(.font, value: font, range: range)
  }
  
  func setColor(_ color: UIColor, range: NSRange? = nil) {
    let range = range.isNil ? wholeRange : range!
    self.addAttribute(.foregroundColor, value: color, range: range)
  }
  
  func setLetterSpacing(_ spacing: CGFloat, range: NSRange? = nil) {
    let range = range.isNil ? wholeRange : range!
    self.addAttribute(.kern, value: spacing, range: range)
  }
}
