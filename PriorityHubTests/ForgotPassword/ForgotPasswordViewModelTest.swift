//
//  ForgotPasswordViewModelTest.swift
//  PriorityHubTests
//
//  Created by Sapana Bhorania on 5/1/26.
//

import Foundation
import XCTest
@testable import PriorityHub

@MainActor
final class ForgotPasswordViewModelTest: XCTestCase {
    
    var viewModel : ForgotPasswordViewModel!
    override func setUp() {
        super.setUp()
        
        let mockLoginViewModel = LoginViewModel()
        let mockAuthService : authServiceForgotPasswordProtocol = MockAuthServices()
        let mockAlertManagerObj = mockAlertManager()
        viewModel = ForgotPasswordViewModel(loginViewModel: mockLoginViewModel,
                                            authService: mockAuthService,
                                            alertManager: mockAlertManagerObj)
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testIntialSetup() {
        XCTAssertTrue(viewModel.email.isEmpty)
        XCTAssertFalse(viewModel.isValidEmail)
        XCTAssertTrue(viewModel.emailErrorMessage == nil)
    }
    func test_IsValidEmail_WithValidEmail_ShouldBeReturnTrue() {
        // Arrange
        viewModel.email = "abc.xyz@gmail.com"
        
        // Act & Assert
        XCTAssertTrue(viewModel.isValidEmail, "should be true with valid email")
        XCTAssertTrue(viewModel.emailErrorMessage == nil, "error message should be nil")
    }
    func test_IsValidEmail_WithInvalidInput_ShouldBeReturFalse() {
        // Arrange
        viewModel.email = "abc.xyz.com" // Missing @
        
        // Act & Assert
        XCTAssertNotNil(viewModel.emailErrorMessage, "Should be error message, because email is invalid")
        XCTAssertFalse(viewModel.isValidEmail, "should be false with invalid email")
    }
    func test_IsResetLinkSent_ValidInput() async {
        // Arrange
        viewModel.email = "abc.xyz@gmail.com"
        
        // Act
        await viewModel.resetPassword()
         
        XCTAssertTrue(viewModel.isValidEmail, "Should be true with valid email")
        XCTAssertTrue(viewModel.resetLinkSent,"Should be true after sending password link")
    }
    func test_IsResetLinkSent_InvalidInput() async {
        // Arrange
        viewModel.email = "abc.xyzgmail.com" // Missing @
        
        // Act
        await viewModel.resetPassword()
        
        XCTAssertFalse(viewModel.isValidEmail, "Should ne false with invalid email")
        XCTAssertFalse(viewModel.resetLinkSent, "Should be false, Invalid email will not send reset link")
    }
}
