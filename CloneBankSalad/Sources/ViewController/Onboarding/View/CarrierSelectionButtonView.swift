//
//  SelectionButtonView.swift
//  CloneBankSalad
//
//  Created by CodeCamper on 2022/08/23.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit

// MARK: - View
class CarrierSelectionButtonView: UIView, View {
  // MARK: View Components
  lazy var label: UILabel = {
    let label = UILabel()
    let attributedString = NSMutableAttributedString(string: "통신사")
    attributedString.setFont(UIFont.notoSans.regular.font(size: 13))
    attributedString.setColor(UIColor.assetColor(.co_010207))
    attributedString.setLetterSpacing(-0.65)
    label.attributedText = attributedString
    return label
  }()
  
  lazy var image: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage.assetImage(.onboarding_arrow_down)
    return imageView
  }()
  
  
  // MARK: Associated Types
  typealias Reactor = CarrierSelectionButtonReactor
  
  
  // MARK: Properties
  var disposeBag = DisposeBag()
  var didSetupConstraints = false

  
  // MARK: Life Cycle
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
    self.setNeedsUpdateConstraints()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupViews()
    self.setNeedsUpdateConstraints()
  }
  
  override func updateConstraints() {
    if !didSetupConstraints {
      self.setupConstraints()
      didSetupConstraints = true
    }
    super.updateConstraints()
  }
  
  // MARK: Setup Views
  func setupViews() {
    self.layer.backgroundColor = UIColor.assetColor(.co_e4e7ee).cgColor
    self.layer.cornerRadius = 6
  }
  
  
  // MARK: Layout Views
  func setupConstraints() {
    self.addSubview(label)
    self.addSubview(image)
    label.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(8)
      make.top.equalToSuperview().offset(2)
      make.bottom.equalToSuperview().offset(-2)
    }
    image.snp.makeConstraints { make in
      make.leading.equalTo(label.snp.trailing).offset(3)
      make.trailing.equalToSuperview().offset(-10)
      make.centerY.equalTo(label)
      make.width.equalTo(6)
    }
  }
  
  
  // MARK: Binding
  func bind(reactor: Reactor) {
    // Action
    
    // State
    reactor.pulse(\.$selectedCarrier)
      .distinctUntilChanged()
      .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .map { $0?.rawValue ?? "통신사" }
      .map { text -> NSMutableAttributedString in
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.setFont(UIFont.notoSans.regular.font(size: 13))
        attributedString.setColor(UIColor.assetColor(.co_010207))
        attributedString.setLetterSpacing(-0.65)
        return attributedString
      }
      .asDriver(onErrorDriveWith: .empty())
      .drive(label.rx.attributedText)
      .disposed(by: disposeBag)
    
    // View
  }
}

// MARK: SelectionButtonView + Rx
extension Reactive where Base == CarrierSelectionButtonView {
  var selectedCarrier: Observable<MobileCarrier?> {
    guard let reactor = base.reactor else { return .empty() }
    return reactor.pulse(\.$selectedCarrier)
  }
}


// MARK: - Reactor
class CarrierSelectionButtonReactor: Reactor {
  // MARK: Associated Types
  typealias Action = Mutation
  
  enum Mutation {
    case updateCarrier(MobileCarrier)
  }
  
  struct State {
    @Pulse var selectedCarrier: MobileCarrier?
  }
  
  
  // MARK: Properties
  let initialState: State
  
  
  // MARK: Initializing
  init() {
    initialState = State()
  }
  
  
  // MARK: Reduce
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .updateCarrier(let carrier):
      newState.selectedCarrier = carrier
    }
    return newState
  }
}
