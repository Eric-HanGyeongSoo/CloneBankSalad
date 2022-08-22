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
    attributedString.setFont(UIFont.notoSans.bold.font(size: 25))
    attributedString.setColor(UIColor.assetColor(.co_111111))
    attributedString.setLetterSpacing(-0.25)
    label.attributedText = attributedString
    return label
  }()
  
  lazy var subtitleLabel: UILabel = {
    let label = UILabel()
    let attributedString = NSMutableAttributedString(string: "회원여부 확인 및 가입을 진행합니다.")
    attributedString.setFont(UIFont.notoSans.regular.font(size: 17))
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
  
  // MARK: Properties
  var disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    setupViews()
    self.reactor = IdentifyingViewReactor()
  }
  
  // MARK: Setup Views
  func setupViews() {
    self.view.addSubview(titleLabel)
    self.view.addSubview(subtitleLabel)
    self.view.addSubview(nameTextField)
    self.view.addSubview(registrationNumberTextField)
    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
      make.top.equalTo(self.view.safeAreaLayoutGuide).offset(56)
    }
    subtitleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(20)
      make.top.equalTo(titleLabel.snp.bottom).offset(8)
    }
    nameTextField.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
      make.top.equalTo(subtitleLabel.snp.bottom).offset(25)
    }
    registrationNumberTextField.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
      make.top.equalTo(nameTextField.snp.bottom).offset(12)
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
  }
}


class IdentifyingViewReactor: Reactor, Stepper {
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
  let steps = PublishRelay<Step>()
  
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
