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

class NameTextFieldView: UIView, View {
  // MARK: View Components
  lazy var label: UILabel = {
    let label = UILabel()
    label.text = "이름"
    label.font = UIFont.notoSans.regular.font(size: 13)
    label.textColor = UIColor.assetColor(.co_656e77)
    return label
  }()
  
  lazy var textField: UITextField = {
    let textField = UITextField()
    let attributedPlaceholder = NSMutableAttributedString("이름 입력")
    attributedPlaceholder.setFont(UIFont.notoSans.regular.font(size: 19))
    attributedPlaceholder.setColor(UIColor.assetColor(.co_878f9c))
    attributedPlaceholder.setLetterSpacing(-0.46)
    textField.attributedPlaceholder = attributedPlaceholder
    textField.font = UIFont.notoSans.regular.font(size: 19)
    textField.textColor = UIColor.assetColor(.co_111111)
    return textField
  }()
  
  lazy var clearButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage.assetImage(.onboarding_clear), for: .normal)
    return button
  }()
  
  // MARK: Properties
  var disposeBag = DisposeBag()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupViews()
  }
  
  // MARK: Setup Views
  func setupViews() {
    self.layer.cornerRadius = 13
    self.layer.borderWidth = 0.7
    self.layer.borderColor = UIColor.assetColor(.co_e9eaee).cgColor
    self.backgroundColor = UIColor.assetColor(.co_fafafa)
    
    self.addSubview(label)
    self.addSubview(textField)
    self.addSubview(clearButton)
    label.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(16)
      make.top.equalToSuperview().offset(9)
      make.height.equalTo(19)
    }
    textField.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(16)
      make.trailing.equalTo(clearButton.snp.leading).offset(-16)
      make.top.equalTo(label.snp.bottom).offset(2)
      make.bottom.equalToSuperview().offset(-12)
      make.centerY.equalTo(clearButton.snp.centerY)
      make.height.equalTo(28)
    }
    clearButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().offset(-16)
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
    .drive(onNext: { [weak self] isFocused, text in
      if isFocused {
        self?.layer.borderColor = UIColor.assetColor(.co_353a40).cgColor
        self?.backgroundColor = UIColor.white
      } else if text.isEmpty {
        self?.layer.borderColor = UIColor.clear.cgColor
        self?.backgroundColor = UIColor.assetColor(.co_fafafa)
      } else {
        self?.layer.borderColor = UIColor.assetColor(.co_e9eaee).cgColor
        self?.backgroundColor = UIColor.white
      }
    }).disposed(by: disposeBag)
    
    reactor.state.map { $0.name }
      .asDriver(onErrorDriveWith: .empty())
      .drive(textField.rx.text)
      .disposed(by: disposeBag)
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
