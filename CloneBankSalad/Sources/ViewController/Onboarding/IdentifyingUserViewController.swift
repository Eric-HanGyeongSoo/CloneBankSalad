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
import Then


class IdentifyingViewController: UIViewController, View {
  // MARK: UI Components
  lazy var titleLabel = UILabel().then {
    let attributedString = NSMutableAttributedString(string: "휴대폰 본인인증")
    attributedString.setFont(UIFont.appleSDGothicNeo(size: 25, weight: .bold))
    attributedString.setColor(UIColor.assetColor(.co_111111))
    attributedString.setLetterSpacing(-0.25)
    $0.attributedText = attributedString
  }
  
  lazy var subtitleLabel = UILabel().then {
    let attributedString = NSMutableAttributedString(string: "회원여부 확인 및 가입을 진행합니다.")
    attributedString.setFont(UIFont.appleSDGothicNeo(size: 17, weight: .medium))
    attributedString.setColor(UIColor.assetColor(.co_656d75))
    attributedString.setLetterSpacing(-0.68)
    $0.attributedText = attributedString
  }
  
  lazy var nameTextField = NameTextFieldView(frame: .zero).then {
    $0.reactor = NameTextFieldReactor()
  }
  
  lazy var registrationNumberTextField = RegistrationNumberTextFieldView(frame: .zero).then {
    $0.reactor = RegistrationNumberTextFieldReactor()
  }
  
  lazy var phoneNumberTextField = PhoneNumberTextFieldView(frame: .zero).then {
    $0.reactor = PhoneNumberTextFieldReactor()
  }
  
  lazy var textFieldStackView = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .fill
    $0.spacing = 12
  }
  
  lazy var infoLabel = UILabel().then {
    var attributed = NSMutableAttributedString(string: "소중한 내 정보를 위해 마이데이터 서비스 가입은 충분히 검토해주세요. 꼭 필요한 서비스만 가입하고 잘 이용하지 않는 서비스는 탈퇴 및 삭제해주세요. 현재 가입하신 마이데이터 서비스 앱은 마이데이터 종합포털에서 확인할 수 있습니다.")
    attributed.setFont(UIFont.appleSDGothicNeo(size: 12))
    attributed.setColor(UIColor.assetColor(.co_a5a8af))
    attributed.setLetterSpacing(0.02)
    attributed.setLineHeight(18, font: UIFont.appleSDGothicNeo(size: 12))
    let linkRange = attributed.mutableString.range(of: "마이데이터 종합포털")
    attributed.addAttribute(.attachment, value: Reactor.Action.tapMyDataLink, range: linkRange)
    attributed.addAttribute(.foregroundColor, value: UIColor.assetColor(.co_5a7fc6), range: linkRange)
    $0.attributedText = attributed
    $0.numberOfLines = 0
  }
  
  
  // MARK: Properties
  var disposeBag = DisposeBag()
  var didSetupConstraints = false
  
  
  // MARK: Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    buildViewHierarchy()
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
  
  
  // MARK: Build View Hierarchy
  func buildViewHierarchy() {
    self.view.addSubview(titleLabel)
    self.view.addSubview(subtitleLabel)
    self.view.addSubview(textFieldStackView)
    self.view.addSubview(infoLabel)
    
    textFieldStackView.addArrangedSubview(nameTextField)
    textFieldStackView.addArrangedSubview(registrationNumberTextField)
    textFieldStackView.addArrangedSubview(phoneNumberTextField)
  }
  
  
  // MARK: Layout Views
  func setupConstraints() {
    self.view.addSubview(titleLabel)
    self.view.addSubview(subtitleLabel)
    self.view.addSubview(textFieldStackView)
    
    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
      make.top.equalTo(self.view.safeAreaLayoutGuide).offset(54)
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
    infoLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
      make.bottom.equalToSuperview().offset(-123)
    }
  }
  
  // MARK: Binding
  func bind(reactor: IdentifyingViewReactor) {
    // Action
    self.rx.viewDidAppear
      .take(1)
      .asDriver(onErrorDriveWith: .empty())
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
    
    phoneNumberTextField.rx.carrierButtonTap
      .map { Reactor.Action.tapCarrierButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    phoneNumberTextField.rx.phoneNumber
      .distinctUntilChanged()
      .map { Reactor.Action.setPhoneNumber($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    infoLabel.rx.tapGesture().when(.recognized)
      .observe(on: MainScheduler.instance)
      .compactMap { [weak self] gesture -> Reactor.Action? in
        guard let self = self else { return nil }
        let point = gesture.location(in: self.infoLabel)
        guard let selectedIndex = self.infoLabel.textIndex(at: point) else { return nil }
        return self.infoLabel.attributedText?.attributes(at: selectedIndex, effectiveRange: nil)[.attachment] as? Reactor.Action
      }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // State
    reactor.state.map { $0.mobileCarrier }
      .distinctUntilChanged()
      .compactMap { $0 }
      .asDriver(onErrorDriveWith: .empty())
      .drive(phoneNumberTextField.rx.selectedCarrier)
      .disposed(by: disposeBag)
  }
}


class IdentifyingViewReactor: Reactor, Stepper {
  enum Action {
    case setName(_ name: String)
    case setBirthDate(_ birthDate: String)
    case setGender(_ gender: String)
    case tapCarrierButton
    case setCarrier(_ carrier: MobileCarrier)
    case setPhoneNumber(_ phone: String)
    case tapMyDataLink
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
  let selectedCarrierObserver = PublishSubject<MobileCarrier>()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .setName(let name):
      return .just(.updateName(name))
    case .setBirthDate(let birthDate):
      return .just(.updateBirthDate(birthDate))
    case .setGender(let gender):
      return .just(.updateGender(gender))
    case .tapCarrierButton:
      steps.accept(OnboardingStep.presentCarrierModal(selectedCarrierObserver))
      return .empty()
    case .setCarrier(let carrier):
      return .just(.updateCarrier(carrier))
    case .setPhoneNumber(let phone):
      return .just(.updatePhoneNumber(phone))
    case .tapMyDataLink:
      steps.accept(OnboardingStep.myDataPortal)
      return .empty()
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
  
  
  // MARK: Mutation Transform
  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    let carrierSelected = selectedCarrierObserver.map { Mutation.updateCarrier($0) }
    return .merge(mutation, carrierSelected)
  }
}
