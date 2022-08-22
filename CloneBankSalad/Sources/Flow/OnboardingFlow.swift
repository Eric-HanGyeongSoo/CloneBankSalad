//
//  OnboardingFlow.swift
//  CloneBankSalad
//
//  Created by CodeCamper on 2022/08/22.
//

import Foundation
import RxFlow
import UIKit

enum OnboardingStep: Step {
  case start
}

class OnboardingFlow: Flow {
  private lazy var rootViewController: UINavigationController = {
    let navigationController = UINavigationController()
    navigationController.setNavigationBarHidden(true, animated: false)
    navigationController.modalPresentationStyle = .overFullScreen
    return navigationController
  }()
  
  var root: Presentable {
    return self.rootViewController
  }
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? OnboardingStep else { return .none }
    switch step {
    case .start:
      let vc = IdentifyingViewController()
      let reactor = IdentifyingViewReactor()
      vc.reactor = reactor
      rootViewController.setViewControllers([vc], animated: false)
      return .one(flowContributor: .contribute(withNextPresentable: vc, withNextStepper: reactor))
    }
  }
  
  
}
