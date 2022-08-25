//
//  PhoneNumberTextFieldView.swift
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
class PhoneNumberTextFieldView: UIView, View {
  // MARK: View Components
  lazy var label: UILabel = {
    let label = UILabel()
    label.text = "휴대폰번호"
    label.font = UIFont.appleSDGothicNeo(size: 12, weight: .medium)
    label.textColor = UIColor.assetColor(.co_656e77)
    return label
  }()
  
  lazy var carrierSelectionButton: CarrierSelectionButtonView = {
    let view = CarrierSelectionButtonView()
    view.reactor = CarrierSelectionButtonReactor()
    return view
  }()
  
  lazy var clearButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage.assetImage(.onboarding_clear), for: .normal)
    return button
  }()
  
  lazy var textField: UITextField = {
    let textField = UITextField()
    let attributedPlaceholder = NSMutableAttributedString(string: "휴대폰번호 입력")
    attributedPlaceholder.setFont(UIFont.appleSDGothicNeo(size: 18, weight: .medium))
    attributedPlaceholder.setColor(UIColor.assetColor(.co_848894))
    attributedPlaceholder.setLetterSpacing(-0.09)
    textField.attributedPlaceholder = attributedPlaceholder
    textField.keyboardType = .numberPad
    return textField
  }()
  
  // MARK: Associated Types
  typealias Reactor = PhoneNumberTextFieldReactor
  
  
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
    self.layer.cornerRadius = 13
    self.layer.borderWidth = 0.7
    self.layer.borderColor = UIColor.clear.cgColor
    self.backgroundColor = UIColor.assetColor(.co_fafafa)
  }
  
  
  // MARK: Layout Views
  func setupConstraints() {
    self.addSubview(label)
    self.addSubview(carrierSelectionButton)
    self.addSubview(textField)
    self.addSubview(clearButton)
    label.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(16)
      make.top.equalToSuperview().offset(12)
      make.height.equalTo(15)
    }
    carrierSelectionButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(16)
      make.top.equalTo(label.snp.bottom).offset(6)
      make.bottom.equalToSuperview().offset(-12)
    }
    textField.snp.makeConstraints { make in
      make.leading.equalTo(carrierSelectionButton.snp.trailing).offset(8)
      make.centerY.equalTo(carrierSelectionButton)
      make.height.equalTo(21)
    }
    clearButton.snp.makeConstraints { make in
      make.leading.equalTo(textField.snp.trailing).offset(12)
      make.trailing.equalToSuperview().offset(-16)
      make.centerY.equalTo(carrierSelectionButton)
      make.width.height.equalTo(17)
    }
  }
  
  
  // MARK: Binding
  func bind(reactor: Reactor) {
    // Action
    let textStream = textField.rx.controlEvent(.editingChanged)
      .compactMap { [weak self] _ in
        self?.textField.text?.replacingOccurrences(of: "-", with: "").prefix(11)
      }
      .map { String($0) }
      .share(replay: 1)
    
    textStream
      .map { Reactor.Action.updatePhoneNumber($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    textStream
      .distinctUntilChanged()
      .filter { $0.count == 11 }
      .map { _ in }
      .asDriver(onErrorDriveWith: .empty())
      .drive(textField.rx.resignFirstResponder)
      .disposed(by: disposeBag)
    
    clearButton.rx.tap
      .map { Reactor.Action.updatePhoneNumber("") }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // State
    Observable.combineLatest(
      textField.rx.isFirstResponder.distinctUntilChanged(),
      reactor.state.map { $0.phoneNumber }.distinctUntilChanged()
    )
    .asDriver(onErrorDriveWith: .empty())
    .drive(onNext: { [weak self] isFocused, phone in
      if isFocused {
        self?.layer.borderColor = UIColor.assetColor(.co_353a40).cgColor
        self?.backgroundColor = UIColor.white
      } else if phone.isEmpty {
        self?.layer.borderColor = UIColor.clear.cgColor
        self?.backgroundColor = UIColor.assetColor(.co_fafafa)
      } else {
        self?.layer.borderColor = UIColor.assetColor(.co_e9eaee).cgColor
        self?.backgroundColor = UIColor.white
      }
    }).disposed(by: disposeBag)
    
    reactor.state.map { $0.phoneNumber }
      .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .compactMap { [weak self] text in
        self?.formatPhoneNumber(text)
      }
      .map { phoneNumber -> NSMutableAttributedString in
        let attributed = NSMutableAttributedString(string: phoneNumber)
        attributed.setFont(UIFont.pretendard(size: 18, weight: .medium))
        attributed.setColor(UIColor.assetColor(.co_30363e))
        attributed.setLetterSpacing(0.27)
        return attributed
      }
      .asDriver(onErrorDriveWith: .empty())
      .drive(textField.rx.attributedText)
      .disposed(by: disposeBag)
    
    
    // Notification
    NotificationCenter.default.rx.notification(.panModalDidDismiss)
      .map { _ in }
      .asDriver(onErrorDriveWith: .empty())
      .drive(textField.rx.becomeFirstResponder)
      .disposed(by: disposeBag)
  }
  
  private func formatPhoneNumber(_ phoneNumber: String) -> String {
    if phoneNumber.count == 11 {
      let phoneNumber = Array(phoneNumber)
      return "\(String(phoneNumber[..<3]))-\(String(phoneNumber[3..<7]))-\(String(phoneNumber[7...]))"
    } else if phoneNumber.count > 6 {
      let phoneNumber = Array(phoneNumber)
      return "\(String(phoneNumber[..<3]))-\(String(phoneNumber[3..<6]))-\(String(phoneNumber[6...]))"
    } else if phoneNumber.count > 3 {
      let phoneNumber = Array(phoneNumber)
      return "\(String(phoneNumber[..<3]))-\(String(phoneNumber[3...]))"
    } else {
      return phoneNumber
    }
  }
}

// MARK: PhoneNumberTextFieldView + Rx
extension Reactive where Base == PhoneNumberTextFieldView {
  var selectedCarrier: Binder<MobileCarrier> {
    return base.carrierSelectionButton.rx.selectedCarrier
  }
  
  var carrierButtonTap: ControlEvent<Void> {
    return base.carrierSelectionButton.rx.tap
  }
  
  var phoneNumber: Observable<String> {
    guard let reactor = base.reactor else { return .empty() }
    return reactor.state.map { $0.phoneNumber }
  }
}


// MARK: - Reactor
class PhoneNumberTextFieldReactor: Reactor {
  // MARK: Associated Types
  typealias Action = Mutation
  
  enum Mutation {
    case updatePhoneNumber(String)
  }
  
  struct State {
    var phoneNumber = ""
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
    case .updatePhoneNumber(let phone):
      newState.phoneNumber = phone
    }
    return newState
  }
}
