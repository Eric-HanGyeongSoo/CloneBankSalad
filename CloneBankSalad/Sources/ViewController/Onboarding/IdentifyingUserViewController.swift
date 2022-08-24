//
//  IdentifyingUserViewController.swift
//  CloneBankSalad
//
//  Created by 한경수 on 2022/08/19.
//

import Foundation
import UIKit
import ReactorKit
import RxSwift
import RxRelay
import RxFlow

class IdentifyingViewController: UIViewController, View {
  // MARK: UI Components
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    let attributedString = NSMutableAttributedString(string: "휴대폰 본인인증")
    attributedString.setFont(UIFont.appleSDGothicNeo(size: 25, weight: .bold))
    attributedString.setColor(UIColor.assetColor(.co_111111))
    attributedString.setLetterSpacing(-0.25)
    label.attributedText = attributedString
    return label
  }()
  
  lazy var subtitleLabel: UILabel = {
    let label = UILabel()
    let attributedString = NSMutableAttributedString(string: "회원여부 확인 및 가입을 진행합니다.")
    attributedString.setFont(UIFont.appleSDGothicNeo(size: 17))
    attributedString.setColor(UIColor.assetColor(.co_656d75))
    attributedString.setLetterSpacing(-0.68)
    label.attributedText = attributedString
    return label
  }()
  
  lazy var nameTextField: NameTextFieldView = {
    let view = NameTextFieldView(frame: .zero)
    view.reactor = NameTextFieldReactor()
    return view
  }()
  
  lazy var registrationNumberTextField: RegistrationNumberTextFieldView = {
    let view = RegistrationNumberTextFieldView(frame: .zero)
    view.reactor = RegistrationNumberTextFieldReactor()
    return view
  }()
  
  lazy var phoneNumberTextField: PhoneNumberTextFieldView = {
    let view = PhoneNumberTextFieldView(frame: .zero)
    view.reactor = PhoneNumberTextFieldReactor()
    return view
  }()
  
  lazy var textFieldStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.spacing = 12
    textFieldStackView.addArrangedSubview(nameTextField)
    textFieldStackView.addArrangedSubview(registrationNumberTextField)
    textFieldStackView.addArrangedSubview(phoneNumberTextField)
    return stackView
  }()
  
  
  // MARK: Properties
  var disposeBag = DisposeBag()
  var didSetupConstraints = false
  
  
  // MARK: Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    self.view.setNeedsUpdateConstraints()
  }
  
  override func updateViewConstraints() {
    if !didSetupConstraints {
      setupConstraints()
      didSetupConstraints = true
    }
    super.updateViewConstraints()
  }
  
  
  // MARK: Setup Views
  func setupViews() {
    self.view.backgroundColor = .white
  }
  
  
  // MARK: Layout Views
  func setupConstraints() {
    self.view.addSubview(titleLabel)
    self.view.addSubview(subtitleLabel)
    self.view.addSubview(textFieldStackView)
    
    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
      make.top.equalTo(self.view.safeAreaLayoutGuide).offset(67)
    }
    subtitleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(20)
      make.top.equalTo(titleLabel.snp.bottom).offset(14)
    }
    textFieldStackView.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
      make.top.equalTo(subtitleLabel.snp.bottom).offset(30)
    }
  }
  
  // MARK: Binding
  func bind(reactor: IdentifyingViewReactor) {
    // Action
    self.rx.viewDidAppear
      .asDriver()
      .drive(onNext: { [weak self] _ in
        self?.nameTextField.textField.becomeFirstResponder()
      }).disposed(by: disposeBag)
    
    nameTextField.rx.name
      .distinctUntilChanged()
      .map { Reactor.Action.setName($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    registrationNumberTextField.rx.birthDate
      .distinctUntilChanged()
      .map { Reactor.Action.setBirthDate($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    registrationNumberTextField.rx.gender
      .distinctUntilChanged()
      .map { Reactor.Action.setGender($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    phoneNumberTextField.rx.selectedCarrier
      .compactMap { $0 }
      .map { Reactor.Action.setCarrier($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    phoneNumberTextField.rx.phoneNumber
      .distinctUntilChanged()
      .map { Reactor.Action.setPhoneNumber($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
}


class IdentifyingViewReactor: Reactor, Stepper {
  enum Action {
    case setName(_ name: String)
    case setBirthDate(_ birthDate: String)
    case setGender(_ gender: String)
    case setCarrier(_ carrier: MobileCarrier)
    case setPhoneNumber(_ phone: String)
  }
  
  enum Mutation {
    case updateName(_ name: String)
    case updateBirthDate(_ birthDate: String)
    case updateGender(_ gender: String)
    case updateCarrier(_ carrier: MobileCarrier)
    case updatePhoneNumber(_ phone: String)
  }
  
  struct State {
    var name = ""
    var birthDate = ""
    var gender = ""
    var phoneNumber = ""
    var mobileCarrier: MobileCarrier?
  }
  
  let initialState = State()
  let steps = PublishRelay<Step>()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .setName(let name):
      return .just(.updateName(name))
    case .setBirthDate(let birthDate):
      return .just(.updateBirthDate(birthDate))
    case .setGender(let gender):
      return .just(.updateGender(gender))
    case .setCarrier(let carrier):
      return .just(.updateCarrier(carrier))
    case .setPhoneNumber(let phone):
      return .just(.updatePhoneNumber(phone))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updateName(let name):
      newState.name = name
    case .updateBirthDate(let birthDate):
      newState.birthDate = birthDate
    case .updateGender(let gender):
      newState.gender = gender
    case .updateCarrier(let carrier):
      newState.mobileCarrier = carrier
    case .updatePhoneNumber(let phone):
      newState.phoneNumber = phone
    }
    
    return newState
  }
}
