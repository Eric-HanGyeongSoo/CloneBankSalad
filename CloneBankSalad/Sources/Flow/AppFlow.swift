//
//  AppFlow.swift
//  CloneBankSalad
//
//  Created by CodeCamper on 2022/08/22.
//

import Foundation
import RxFlow
import UIKit

enum AppStep: Step {
  case splash
  case main
  case onboard
}

class AppFlow: Flow {
  var window: UIWindow
  
  var root: Presentable {
    return self.window
  }
  
  init(window: UIWindow) {
    self.window = window
  }
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    switch step {
    case .splash:
      return .none
    case .main:
      return .none
    case .onboard:
      let vc = IdentifyingViewController()
      let reactor = IdentifyingViewReactor()
      vc.reactor = reactor
      window.rootViewController = vc
      return .one(flowContributor: .contribute(withNextPresentable: vc, withNextStepper: reactor))
    }
  }
}
