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

class RegistrationNumberTextFieldView: UIView, View {
  // MARK: View Components
  lazy var label: UILabel = {
    let label = UILabel()
    label.text = "주민등록번호 7자리"
    label.font = UIFont.appleSDGothicNeo(size: 12)
    label.textColor = UIColor.assetColor(.co_656e77)
    return label
  }()
  
  lazy var birthDateTextField: UITextField = {
    let textField = UITextField()
    let attributedPlaceholder = NSMutableAttributedString(string: "생년월일")
    attributedPlaceholder.setFont(UIFont.appleSDGothicNeo(size: 18))
    attributedPlaceholder.setColor(UIColor.assetColor(.co_848894))
    attributedPlaceholder.setLetterSpacing(-0.09)
    textField.attributedPlaceholder = attributedPlaceholder
    textField.font = UIFont.appleSDGothicNeo(size: 18)
    textField.textColor = UIColor.assetColor(.co_0f0f0f)
    textField.keyboardType = .numberPad
    return textField
  }()
  
  lazy var genderTextField: UITextField = {
    let textField = UITextField()
    let attributedPlaceholder = NSMutableAttributedString(string: "0")
    attributedPlaceholder.setFont(UIFont.pretendard(size: 18, weight: .medium))
    attributedPlaceholder.setColor(UIColor.assetColor(.co_848894))
    textField.attributedPlaceholder = attributedPlaceholder
    textField.keyboardType = .numberPad
    return textField
  }()
  
  lazy var genderTextFieldStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .equalSpacing
    stackView.addArrangedSubview(genderTextField)
    for _ in 0..<6 {
      let imageView = UIImageView()
      imageView.image = UIImage.assetImage(.onboarding_secure_star)
      stackView.addArrangedSubview(imageView)
    }
    return stackView
  }()
  
  lazy var textFieldStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 21
    stackView.alignment = .center
    let hyphenImageView = UIImageView()
    hyphenImageView.image = UIImage.assetImage(.onboarding_hyphen)
    stackView.addArrangedSubview(birthDateTextField)
    stackView.addArrangedSubview(hyphenImageView)
    stackView.addArrangedSubview(genderTextFieldStackView)
    return stackView
  }()
  
  // MARK: Properties
  var disposeBag = DisposeBag()
  var didSetupConstraints = false
  
  // MARK: LifeCycle
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
  
  // MARK: Setup View
  func setupViews() {
    self.layer.cornerRadius = 13
    self.layer.borderWidth = 0.7
    self.layer.borderColor = UIColor.clear.cgColor
    self.backgroundColor = UIColor.assetColor(.co_fafafa)
  }
  
  // MARK: Layout Views
  func setupConstraints() {
    self.addSubview(label)
    self.addSubview(textFieldStackView)
    label.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(16)
      make.top.equalToSuperview().offset(12)
      make.height.equalTo(15)
    }
    textFieldStackView.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(16)
      make.trailing.equalToSuperview().offset(-16)
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
        self?.layer.borderColor = UIColor.assetColor(.co_353a40).cgColor
        self?.backgroundColor = UIColor.white
      } else if birthDate.isEmpty && gender.isEmpty {
        self?.layer.borderColor = UIColor.clear.cgColor
        self?.backgroundColor = UIColor.assetColor(.co_fafafa)
      } else {
        self?.layer.borderColor = UIColor.assetColor(.co_e9eaee).cgColor
        self?.backgroundColor = UIColor.white
      }
    }).disposed(by: disposeBag)
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
