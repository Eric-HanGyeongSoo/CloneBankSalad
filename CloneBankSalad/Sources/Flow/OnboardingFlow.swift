//
//  OnboardingFlow.swift
//  CloneBankSalad
//
//  Created by CodeCamper on 2022/08/22.
//

import Foundation
import RxFlow
import UIKit
import RxSwift

enum OnboardingStep: Step {
  case start
  case presentCarrierModal(_ observer: PublishSubject<MobileCarrier>)
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
    case .presentCarrierModal(let observer):
      let vc = CarrierSelectionModalViewController()
      let reactor = CarrierSelectionModalReactor()
      vc.reactor = reactor
      rootViewController.topViewController?.presentPanModal(vc)
      
      vc.rx.selectedCarrier
        .bind(to: observer)
        .disposed(by: vc.disposeBag)
      
      return .one(flowContributor: .contribute(withNextPresentable: vc, withNextStepper: reactor))
    }
  }
}
