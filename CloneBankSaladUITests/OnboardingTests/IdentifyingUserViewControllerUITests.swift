//
//  CloneBankSaladUITests.swift
//  CloneBankSaladUITests
//
//  Created by 한경수 on 2022/08/19.
//

import XCTest

class IdentifyingUserViewControllerUITests: XCTestCase {
  
  override func setUpWithError() throws {
    continueAfterFailure = false
  }
  
  override func tearDownWithError() throws {
  }
  
  func launchApp() -> XCUIApplication {
    let app = XCUIApplication()
    app.launch()
    app.activate()
    return app
  }
  
  func test이름_비어있을_때_에러문구_노출_확인() throws {
    // given
    let app = launchApp()
    
    // when
    
    // then
    XCTAssert(!app.nameErrorLabel.exists)
  }
  
  func test이름_입려중_유효할_때_에러문구_비노출() throws {
    // given
    let app = launchApp()
    
    // when
    app.nameTextField.typeText("한경수 Eric")
    
    // then
    XCTAssert(!app.nameErrorLabel.exists)
  }
  
  func test이름_입력중_유효하지_않을_때_에러문구_노출() throws {
    // given
    let app = launchApp()
    
    // when
    app.nameTextField.typeText("한경수 Eric 3")
    
    // then
    XCTAssert(app.nameErrorLabel.exists)
  }
  
  func test이름_입력완료_유효할_때_에러문구_미노출() throws {
    // given
    let app = launchApp()
    
    // when
    app.nameTextField.typeText("한경수 Eric")
    app.endEditing()
    
    // then
    XCTAssert(!app.nameErrorLabel.exists)
  }
  
  func test이름_입력완료_유효하지_않을_때_에러문구_노출() throws {
    // given
    let app = launchApp()
    
    // when
    app.nameTextField.typeText("한경수 Eric 3")
    app.endEditing()
    
    // then
    XCTAssert(app.nameErrorLabel.exists)
  }
  
  func test주민등록번호_입력중_일부입력_에러문구_미노출() throws {
    // given
    let app = launchApp()
    
    // when
    app.birthDateTextField.tap()
    app.birthDateTextField.typeText("1212")
    app.genderTextField.tap()
    app.genderTextField.typeText("7")
    
    // then
    XCTAssert(!app.registrationNumberErrorLabel.exists)
  }
  
  func test주민등록번호_입력중_모두_입력_미허용_성별번호_에러문구_노출() throws {
    // given
    let app = launchApp()
    
    // when
    app.birthDateTextField.tap()
    app.birthDateTextField.typeText("121212")
    app.genderTextField.tap()
    app.genderTextField.typeText("7")
    
    // then
    XCTAssert(app.registrationNumberErrorLabel.exists)
  }
  
  func test주민등록번호_비어있고_입력중이_아니라면_에러문구_미노출() throws {
    // given
    let app = launchApp()
    
    // when
    app.endEditing()
    
    // then
    XCTAssert(!app.registrationNumberErrorLabel.exists)
  }
  
  func test주민등록번호_일부입력_입력중이_아니라면_에러문구_노출() throws {
    // given
    let app = launchApp()
    
    // when
    app.birthDateTextField.tap()
    app.birthDateTextField.typeText("1212")
    app.genderTextField.tap()
    app.genderTextField.typeText("1")
    app.endEditing()
    
    // then
    XCTAssert(app.registrationNumberErrorLabel.exists)
  }
  
  func test주민등록번호_모두입력_허용되지_않은_성별번호_에러문구_노출() throws {
    // given
    let app = launchApp()
    
    // when
    app.birthDateTextField.tap()
    app.birthDateTextField.typeText("990826")
    app.genderTextField.tap()
    app.genderTextField.typeText("7")
    app.endEditing()
    
    // then
    XCTAssert(app.registrationNumberErrorLabel.exists)
  }
}

fileprivate extension XCUIApplication {
  var nameTextField: XCUIElement {
    return self.textFields["이름 입력란"]
  }
  
  var nameErrorLabel: XCUIElement {
    return self.staticTexts["한글 또는 영문으로 입력해주세요"]
  }
  
  var birthDateTextField: XCUIElement {
    return self.textFields["주민등록번호 앞번호 입력란"]
  }
  
  var genderTextField: XCUIElement {
    return self.textFields["주민등록번호 뒷번호 첫자리 입력란"]
  }
  
  var registrationNumberErrorLabel: XCUIElement {
    return self.staticTexts["입력한 정보를 확인해주세요"]
  }
  
  func endEditing() {
    if self.buttons["Done"].exists {
      self.buttons["Done"].tap()
    }
  }
}
