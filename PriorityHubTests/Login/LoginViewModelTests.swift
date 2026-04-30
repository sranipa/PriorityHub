//
//  LoginViewModelTests.swift
//  PriorityHubTests
//
//  Created by Sapana Bhorania on 4/30/26.
//

import Foundation
import XCTest
import FirebaseAuth
@testable import PriorityHub

@MainActor
final class LoginViewModelTests : XCTestCase {
    
    var viewModel : LoginViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = LoginViewModel()
    }
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    func testIntialStates() {
        XCTAssertTrue(viewModel.email.isEmpty)
        XCTAssertTrue(viewModel.password.isEmpty)
        XCTAssertFalse(viewModel.isFormValid)
    }
    func testIsFormValid_WithCorrectInput_ShouldReturnTrue() {
        // Arrange
        viewModel.email = "ranipasapana@gmail.com"
        viewModel.password = "123456"
        
        // Act & Assert
        XCTAssertTrue(viewModel.isFormValid, "Form should be valid with proper email & Password")
    }
    func testIsFormValid_WithInvliadInput_ShouldReturnFalse() {
        // Arrange
        viewModel.email = "Sapana"
        viewModel.password = "123456"
        
        // Act & Assert
        XCTAssertFalse(viewModel.isFormValid, "Form should be invalid with incorrect email & password")
    }
    func testInvalidInput_ShortPasswordLength_InvalidEmail_EmptyEmailAndPassword() {
        
        // For Invalid Password
        // Arrange
        viewModel.password = "12"
        // Act
        let msgPassword = viewModel.passwordErrorMessage
        // Assert
        XCTAssertNotNil(msgPassword)
        XCTAssertEqual(msgPassword,viewModel.passwordErrorMessage)
        
        
        // For Invalid Email
        viewModel.email = "ranipasapana"
        
        let msgEmail = viewModel.emailErrorMessage
        
        XCTAssertNotNil(msgEmail)
        XCTAssertEqual(msgEmail, viewModel.emailErrorMessage)
        
        // For empty email & Password
        viewModel.email = ""
        viewModel.password = ""
        
        XCTAssertFalse(viewModel.isFormValid,"Email & Password should not be empty")
    }
    func testAuthError_WithInvalidEmail_ShouldReturnTrueStringMsg() {
        
        // Arrange
        let mockError = NSError(domain: "Firebase", code: AuthErrorCode.invalidEmail.rawValue)
        
        // Act
        let resultMessage = viewModel.authError(error: mockError)
        
        // Assert
        
        XCTAssertEqual(resultMessage, "The email address is invalid")
    }
}
