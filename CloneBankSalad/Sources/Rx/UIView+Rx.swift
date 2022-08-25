//
//  UIView+Rx.swift
//  CloneBankSalad
//
//  Created by CodeCamper on 2022/08/25.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxGesture

extension Reactive where Base: UIView {
  var tap: ControlEvent<Void> {
    let source = base.rx.tapGesture().when(.recognized).map { _ in }
    return ControlEvent(events: source)
  }
}
