//
//  UITextField+Rx.swift
//  CloneBankSalad
//
//  Created by 한경수 on 2022/08/21.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base == UITextField {
  var isFirstResponder: ControlProperty<Bool> {
    return base.rx.controlProperty(editingEvents: .allEditingEvents, getter: { base in
      return base.isFirstResponder
    }, setter: { base, newValue in
      if newValue && base.canBecomeFirstResponder {
        base.becomeFirstResponder()
      } else if !newValue && base.canResignFirstResponder {
        base.resignFirstResponder()
      }
    })
  }
  
  var becomeFirstResponder: Binder<Void> {
    return Binder(self.base) { textField, _ in
      if textField.canBecomeFirstResponder {
        textField.becomeFirstResponder()
      }
    }
  }
  
  var resignFirstResponder: Binder<Void> {
    return Binder(self.base) { textField, _ in
      if textField.canResignFirstResponder {
        textField.resignFirstResponder()
      }
    }
  }
}
