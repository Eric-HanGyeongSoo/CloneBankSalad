//
//  RegistrationNumberTextFieldView.swift
//  CloneBankSalad
//
//  Created by CodeCamper on 2022/08/22.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit
import Then


class RegistrationNumberTextFieldView: UIView, View {
  // MARK: View Components
  lazy var label = UILabel().then {
    $0.text = "주민등록번호 7자리"
    $0.font = UIFont.appleSDGothicNeo(size: 12, weight: .medium)
    $0.textColor = UIColor.assetColor(.co_656e77)
  }
  
  lazy var birthDateTextField = UITextField().then {
    let attributedPlaceholder = NSMutableAttributedString(string: "생년월일")
    attributedPlaceholder.setFont(UIFont.appleSDGothicNeo(size: 18, weight: .medium))
    attributedPlaceholder.setColor(UIColor.assetColor(.co_848894))
    attributedPlaceholder.setLetterSpacing(-0.09)
    $0.attributedPlaceholder = attributedPlaceholder
    $0.keyboardType = .numberPad
    $0.accessibilityIdentifier = "주민등록번호 앞번호 입력란"
  }
  
  lazy var genderTextField = UITextField().then {
    let attributedPlaceholder = NSMutableAttributedString(string: "0")
    attributedPlaceholder.setFont(UIFont.pretendard(size: 18, weight: .medium))
    attributedPlaceholder.setColor(UIColor.assetColor(.co_848894))
    $0.attributedPlaceholder = attributedPlaceholder
    $0.keyboardType = .numberPad
    $0.accessibilityIdentifier = "주민등록번호 뒷번호 첫자리 입력란"
  }
  
  lazy var genderTextFieldStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .center
    $0.spacing = 10
  }
  
  lazy var textFieldStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 21
    $0.alignment = .center
  }
  
  lazy var wrapperView = UIView().then {
    $0.backgroundColor = UIColor.assetColor(.co_fafafa)
    $0.layer.cornerRadius = 13
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.clear.cgColor
  }
  
  lazy var errorLabel = UILabel().then {
    $0.text = "입력한 정보를 확인해주세요"
    $0.font = UIFont.appleSDGothicNeo(size: 12, weight: .medium)
    $0.textColor = UIColor.assetColor(.co_ee2440)
    $0.isHidden = true
  }
  
  lazy var stackView = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .leading
    $0.spacing = 9
  }
  
  // MARK: Properties
  var disposeBag = DisposeBag()
  var didSetupConstraints = false
  
  // MARK: LifeCycle
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
    buildViewHierarchy()
    self.setNeedsUpdateConstraints()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func updateConstraints() {
    if !didSetupConstraints {
      self.setupConstraints()
      didSetupConstraints = true
    }
    super.updateConstraints()
  }
  
  // MARK: Setup View
  func setupViews() {
    
  }
  
  
  // MARK: Build View Hierarchy
  func buildViewHierarchy() {
    self.addSubview(stackView)
    
    stackView.addArrangedSubview(wrapperView)
    stackView.addArrangedSubview(errorLabel)
    
    wrapperView.addSubview(label)
    wrapperView.addSubview(textFieldStackView)
    
    let hyphenImageView = UIImageView()
    hyphenImageView.image = UIImage.assetImage(.onboarding_hyphen)
    textFieldStackView.addArrangedSubview(birthDateTextField)
    textFieldStackView.addArrangedSubview(hyphenImageView)
    textFieldStackView.addArrangedSubview(genderTextFieldStackView)
    
    genderTextFieldStackView.addArrangedSubview(genderTextField)
    for _ in 0..<6 {
      let imageView = UIImageView()
      imageView.image = UIImage.assetImage(.onboarding_secure_star)
      genderTextFieldStackView.addArrangedSubview(imageView)
    }
  }
  
  
  // MARK: Layout Views
  func setupConstraints() {
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    wrapperView.snp.makeConstraints { make in
      make.width.equalTo(stackView)
    }
    label.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(16)
      make.top.equalToSuperview().offset(12)
      make.height.equalTo(15)
    }
    textFieldStackView.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(16)
      make.top.equalTo(label.snp.bottom).offset(8)
      make.bottom.equalToSuperview().offset(-12)
      make.height.equalTo(21)
    }
    birthDateTextField.snp.makeConstraints { make in
      make.width.equalTo(genderTextFieldStackView)
    }
  }
  
  // MARK: Binding
  func bind(reactor: RegistrationNumberTextFieldReactor) {
    // Action
    let birthDateStream = birthDateTextField.rx.controlEvent(.editingChanged)
      .compactMap { [weak self] _ in
        self?.birthDateTextField.text?.prefix(6)
      }
      .map { String($0) }
      .share(replay: 1)
    
    birthDateStream
      .distinctUntilChanged()
      .map { Reactor.Action.updateBirthDate($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    birthDateStream
      .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .map { birthDate -> NSMutableAttributedString in
        let attributed = NSMutableAttributedString(string: birthDate)
        attributed.setFont(UIFont.pretendard(size: 18, weight: .medium))
        attributed.setColor(UIColor.assetColor(.co_0f0f0f))
        attributed.setLetterSpacing(0.45)
        return attributed
      }
      .asDriver(onErrorDriveWith: .empty())
      .drive(birthDateTextField.rx.attributedText)
      .disposed(by: disposeBag)
    
    birthDateStream
      .distinctUntilChanged()
      .filter { $0.count == 6 }
      .map { _ in }
      .asDriver(onErrorDriveWith: .empty())
      .drive(genderTextField.rx.becomeFirstResponder)
      .disposed(by: disposeBag)
    
    let genderStream = genderTextField.rx.controlEvent(.editingChanged)
      .compactMap { [weak self] _ in
        self?.genderTextField.text?.prefix(1)
      }
      .map { String($0) }
      .share(replay: 1)
    
    genderStream
      .distinctUntilChanged()
      .map { Reactor.Action.updateGender($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    genderStream
      .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .map { gender -> NSMutableAttributedString in
        let attributed = NSMutableAttributedString(string: gender)
        attributed.setFont(UIFont.pretendard(size: 18, weight: .medium))
        attributed.setColor(UIColor.assetColor(.co_0f0f0f))
        attributed.setLetterSpacing(0.45)
        return attributed
      }
      .asDriver(onErrorDriveWith: .empty())
      .drive(genderTextField.rx.attributedText)
      .disposed(by: disposeBag)
    
    genderStream
      .distinctUntilChanged()
      .filter { $0.count == 0 }
      .map { _ in }
      .asDriver(onErrorDriveWith: .empty())
      .drive(birthDateTextField.rx.becomeFirstResponder)
      .disposed(by: disposeBag)
    
    // State
    let isFocusedStream = Observable
      .combineLatest(
        birthDateTextField.rx.isFirstResponder.asObservable(),
        genderTextField.rx.isFirstResponder.asObservable()
      )
      .map { $0 || $1 }
      .share(replay: 1)
    
    Observable.combineLatest(
      isFocusedStream.distinctUntilChanged(),
      reactor.state.map { $0.birthDate }.distinctUntilChanged(),
      reactor.state.map { $0.gender }.distinctUntilChanged()
    )
    .asDriver(onErrorDriveWith: .empty())
    .drive(onNext: { [weak self] isFocused, birthDate, gender in
      if isFocused {
        if birthDate.count == 6 && gender.count == 1 && !Regex.genderNumber.validate(gender) {
          self?.showError(true, backgroundColor: .white)
        } else {
          self?.showError(false, backgroundColor: .white, borderColor: UIColor.assetColor(.co_353a40).cgColor)
        }
      } else if birthDate.isEmpty && gender.isEmpty {
        self?.showError(false, backgroundColor: UIColor.assetColor(.co_fafafa), borderColor: UIColor.clear.cgColor)
      } else {
        if birthDate.count == 6 && gender.count == 1 && Regex.genderNumber.validate(gender) {
          self?.showError(false, backgroundColor: .white, borderColor: UIColor.assetColor(.co_e9eaee).cgColor)
        } else {
          self?.showError(true, backgroundColor: .white)
        }
      }
    }).disposed(by: disposeBag)
  }
  
  
  // MARK: View Fetcher
  func showError(_ error: Bool, backgroundColor: UIColor, borderColor: CGColor? = nil) {
    self.wrapperView.backgroundColor = backgroundColor
    if error {
      self.wrapperView.layer.borderColor = UIColor.assetColor(.co_ee2440).cgColor
      self.errorLabel.isHidden = false
    } else {
      self.wrapperView.layer.borderColor = borderColor
      self.errorLabel.isHidden = true
    }
  }
}

// MARK: RegistrationNumberTextFieldView + Rx
extension Reactive where Base == RegistrationNumberTextFieldView {
  var birthDate: Observable<String> {
    guard let reactor = base.reactor else { return .empty() }
    return reactor.state.map { $0.birthDate }
  }
  
  var gender: Observable<String> {
    guard let reactor = base.reactor else { return .empty() }
    return reactor.state.map { $0.gender }
  }
}

// MARK: Reactor
class RegistrationNumberTextFieldReactor: Reactor {
  typealias Action = Mutation
  
  enum Mutation {
    case updateBirthDate(String)
    case updateGender(String)
  }
  
  struct State {
    var birthDate = ""
    var gender = ""
  }
  
  let initialState = State()
  
  func reduce(state: State, mutation: Action) -> State {
    var newState = state
    
    switch mutation {
    case .updateBirthDate(let birthDate):
      newState.birthDate = birthDate
    case .updateGender(let gender):
      newState.gender = gender
    }
    
    return newState
  }
}
