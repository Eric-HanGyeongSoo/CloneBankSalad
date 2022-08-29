//
//  NameInputView.swift
//  CloneBankSalad
//
//  Created by 한경수 on 2022/08/21.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit
import Then

class NameTextFieldView: UIView, View {
  // MARK: View Components
  lazy var label = UILabel().then {
    $0.text = "이름"
    $0.font = UIFont.appleSDGothicNeo(size: 12, weight: .medium)
    $0.textColor = UIColor.assetColor(.co_656e77)
  }
  
  lazy var textField = UITextField().then {
    let attributedPlaceholder = NSMutableAttributedString("이름 입력")
    attributedPlaceholder.setFont(UIFont.appleSDGothicNeo(size: 18, weight: .medium))
    attributedPlaceholder.setColor(UIColor.assetColor(.co_848894))
    attributedPlaceholder.setLetterSpacing(-0.09)
    $0.attributedPlaceholder = attributedPlaceholder
    $0.font = UIFont.appleSDGothicNeo(size: 18, weight: .medium)
    $0.textColor = UIColor.assetColor(.co_2b3034)
    $0.accessibilityIdentifier = "이름 입력란"
  }
  
  lazy var clearButton = UIButton().then {
    $0.setImage(UIImage.assetImage(.onboarding_clear), for: .normal)
  }
  
  lazy var wrapperView = UIView().then {
    $0.backgroundColor = UIColor.assetColor(.co_fafafa)
    $0.layer.cornerRadius = 13
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.clear.cgColor
  }
  
  lazy var errorLabel = UILabel().then {
    $0.text = "한글 또는 영문으로 입력해주세요"
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
  
  // MARK: Life Cycle
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
  
  
  // MARK: Setup Views
  func setupViews() {
    
  }
  
  
  // MARK: Build View Hierarchy
  func buildViewHierarchy() {
    self.addSubview(stackView)
    
    stackView.addArrangedSubview(wrapperView)
    stackView.addArrangedSubview(errorLabel)
    
    wrapperView.addSubview(label)
    wrapperView.addSubview(textField)
    wrapperView.addSubview(clearButton)
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
    textField.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(16)
      make.top.equalTo(label.snp.bottom).offset(8)
      make.bottom.equalToSuperview().offset(-12)
      make.height.equalTo(21)
    }
    clearButton.snp.makeConstraints { make in
      make.leading.equalTo(textField.snp.trailing).offset(16)
      make.trailing.equalToSuperview().offset(-16)
      make.centerY.equalTo(textField)
      make.height.width.equalTo(17)
    }
  }
  
  
  // MARK: Binding
  func bind(reactor: NameTextFieldReactor) {
    // Action
    textField.rx.text.orEmpty
      .map { Reactor.Action.setName($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    clearButton.rx.tap
      .map { Reactor.Action.setName("") }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // State
    Observable.combineLatest(
      textField.rx.isFirstResponder.distinctUntilChanged(),
      reactor.state.map { $0.name }.distinctUntilChanged()
    )
    .asDriver(onErrorDriveWith: .empty())
    .drive(onNext: { [weak self] isFocused, name in
      if isFocused {
        if Regex.name.validate(name) {
          self?.showError(false, backgroundColor: .white, borderColor: UIColor.assetColor(.co_353a40).cgColor)
        } else {
          self?.showError(true, backgroundColor: .white)
        }
      } else if name.isEmpty {
        self?.showError(false, backgroundColor: UIColor.assetColor(.co_fafafa), borderColor: UIColor.clear.cgColor)
      } else {
        if Regex.name.validate(name) {
          self?.showError(false, backgroundColor: .white, borderColor: UIColor.assetColor(.co_e9eaee).cgColor)
        } else {
          self?.showError(true, backgroundColor: .white)
        }
      }
    }).disposed(by: disposeBag)
    
    reactor.state.map { $0.name }
      .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .map { name -> NSMutableAttributedString in
        let attributed = NSMutableAttributedString(string: name)
        attributed.setFont(UIFont.appleSDGothicNeo(size: 18, weight: .medium))
        attributed.setColor(UIColor.assetColor(.co_2b3034))
        attributed.setLetterSpacing(-0.09)
        return attributed
      }
      .asDriver(onErrorDriveWith: .empty())
      .drive(textField.rx.attributedText)
      .disposed(by: disposeBag)
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

// MARK: NameTextFieldView + Rx
extension Reactive where Base == NameTextFieldView {
  var name: Observable<String> {
    guard let reactor = base.reactor else { return .empty() }
    return reactor.state.map { $0.name }
  }
}

// MARK: Reactor
class NameTextFieldReactor: Reactor {
  enum Action {
    case setName(_ name: String)
  }
  
  enum Mutation {
    case updateName(_ name: String)
  }
  
  struct State {
    var name = ""
  }
  
  let initialState = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .setName(let name):
      return .just(.updateName(name))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updateName(let name):
      newState.name = name
    }
    
    return newState
  }
}
