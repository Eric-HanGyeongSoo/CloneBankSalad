//
//  CarrierCellView.swift
//  CloneBankSalad
//
//  Created by CodeCamper on 2022/08/25.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit

// MARK: - View
class CarrierCell: UIView, View {
  // MARK: View Components
  lazy var label: UILabel = {
    let label = UILabel()
    label.font = UIFont.pretendard(size: 16, weight: .bold)
    label.textColor = .black
    return label
  }()
  
  
  // MARK: Associated Types
  typealias Reactor = CarrierCellReactor
  
  
  // MARK: Properties
  var disposeBag = DisposeBag()
  var didSetupConstraints = false

  
  // MARK: Life Cycle
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setNeedsUpdateConstraints()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.setNeedsUpdateConstraints()
  }
  
  override func updateConstraints() {
    if !didSetupConstraints {
      self.setupConstraints()
      didSetupConstraints = true
    }
    super.updateConstraints()
  }
  
  
  // MARK: Layout Views
  func setupConstraints() {
    addSubview(label)
    label.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(UIEdgeInsets(top: 22, left: 21, bottom: 22, right: 21))
    }
  }
  
  
  // MARK: Binding
  func bind(reactor: Reactor) {
    // State
    reactor.state.map { $0.carrier }
      .map { $0.name }
      .asDriver(onErrorDriveWith: .empty())
      .drive(label.rx.text)
      .disposed(by: disposeBag)
  }
}


// MARK: - Reactor
class CarrierCellReactor: Reactor {
  // MARK: Associated Types
  typealias Action = NoAction
  typealias Mutation = NoMutation
  
  struct State {
    let carrier: MobileCarrier
  }
  
  
  // MARK: Properties
  let initialState: State
  
  
  // MARK: Initializing
  init(_ carrier: MobileCarrier) {
    initialState = State(carrier: carrier)
  }
}
