//
//  CarrierSelectionModalViewController.swift
//  CloneBankSalad
//
//  Created by CodeCamper on 2022/08/25.
//

import Foundation
import UIKit
import ReactorKit
import RxSwift
import RxRelay
import RxFlow
import PanModal

// MARK: - View Controller
class CarrierSelectionModalViewController: UIViewController, View {
  // MARK: View Components
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    let attributed = NSMutableAttributedString(string: "통신사 선택")
    attributed.setFont(UIFont.appleSDGothicNeo(size: 18, weight: .bold))
    attributed.setColor(.black)
    attributed.setLetterSpacing(-0.18)
    label.attributedText = attributed
    return label
  }()
  
  lazy var closeButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage.assetImage(.onboarding_close), for: .normal)
    return button
  }()
  
  lazy var topWrapperView: UIView = {
    let view = UIView()
    view.addSubview(titleLabel)
    view.addSubview(closeButton)
    return view
  }()
  
  lazy var carrierCells: [CarrierCell] = {
    var cells = [CarrierCell]()
    carrierCases.forEach { carrier in
      let cell = CarrierCell(frame: .zero)
      cell.reactor = CarrierCellReactor(carrier)
      cells.append(cell)
    }
    return cells
  }()
  
  lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 0
    stackView.addArrangedSubview(topWrapperView)
    carrierCells.forEach { cell in
      stackView.addArrangedSubview(cell)
    }
    return stackView
  }()
  
  
  // MARK: Associated Types
  typealias Reactor = CarrierSelectionModalReactor
  
  
  // MARK: Properties
  var disposeBag = DisposeBag()
  var didSetupConstraints = false
  let carrierCases = MobileCarrier.allCases.sorted()
  
  
  // MARK: View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    self.view.setNeedsUpdateConstraints()
  }
  
  override func updateViewConstraints() {
    if !didSetupConstraints {
      self.setupConstraints()
      didSetupConstraints = true
      view.layoutIfNeeded()
      panModalSetNeedsLayoutUpdate()
      panModalTransition(to: .shortForm)
    }
    super.updateViewConstraints()
  }
  
  
  // MARK: Setup Views
  func setupViews() {
    view.backgroundColor = .white
  }
  
  
  // MARK: Layout Views
  func setupConstraints() {
    view.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.leading.trailing.top.equalToSuperview()
    }
    titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(18)
      make.top.equalToSuperview().offset(24)
      make.bottom.equalToSuperview().offset(-24)
    }
    closeButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().offset(-24)
      make.centerY.equalTo(titleLabel)
      make.width.height.equalTo(10)
    }
  }
  
  
  // MARK: Binding
  func bind(reactor: Reactor) {
    // Action
    carrierCells.indices.forEach { index in
      let cell = carrierCells[index]
      let carrier = carrierCases[index]
      cell.rx.tap
        .map { Reactor.Action.updateCarrier(carrier) }
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
    }
    
    closeButton.rx.tap
      .asDriver()
      .drive(onNext: { [weak self] _ in
        self?.dismiss(animated: true)
      }).disposed(by: disposeBag)
    
    // State
    reactor.pulse(\.$mobileCarrier)
      .compactMap { $0 }
      .asDriver(onErrorDriveWith: .empty())
      .drive(onNext: { [weak self] _ in
        self?.dismiss(animated: true)
      }).disposed(by: disposeBag)
  }
}


// MARK: PanModalPresentable
extension CarrierSelectionModalViewController: PanModalPresentable {
  var panScrollable: UIScrollView? {
    return nil
  }
  
  var shortFormHeight: PanModalHeight {
    return .contentHeight(stackView.frame.height)
  }
  
  var cornerRadius: CGFloat {
    return 15
  }
  
  var showDragIndicator: Bool {
    return false
  }
  
  func panModalDidDismiss() {
    NotificationCenter.default.post(name: NSNotification.Name.panModalDidDismiss, object: nil)
  }
}


// MARK: CarrierSelectionModalViewController + Rx
extension Reactive where Base == CarrierSelectionModalViewController {
  var selectedCarrier: Observable<MobileCarrier> {
    guard let reactor = base.reactor else { return .empty() }
    return reactor.pulse(\.$mobileCarrier).compactMap { $0 }
  }
}


// MARK: - Reactor
class CarrierSelectionModalReactor: Reactor, Stepper {
  // MARK: Associated Types
  typealias Action = Mutation
  
  enum Mutation {
    case updateCarrier(MobileCarrier)
  }
  
  struct State {
    @Pulse var mobileCarrier: MobileCarrier?
  }
  
  // MARK: Properties
  let initialState: State
  var steps = PublishRelay<Step>()
  
  
  // MARK: Initializing
  init() {
    initialState = State()
  }
  
  
  // MARK: Reduce
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .updateCarrier(let carrier):
      newState.mobileCarrier = carrier
    }
    
    return newState
  }
}
