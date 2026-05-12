//
//  RegistrationViewModelTest.swift
//  PriorityHubTests
//
//  Created by Sapana Bhorania on 5/1/26.
//

import Foundation
import XCTest
@testable import PriorityHub

@MainActor
final class RegistrationViewModelTest: XCTestCase {
    
    var viewModel : RegistrationViewModel!
    var mockAuthService : MockAuthServices!
    
    override func setUp() {
        super.setUp()
        let mockLoginViewModel = LoginViewModel()
        mockLoginViewModel.path = [LoginRoute.registration] // For testing path - successful registration.
        let alertManager : alertManagerProtocol = mockAlertManager()
        mockAuthService = MockAuthServices()
        viewModel = RegistrationViewModel(loginViewModel: mockLoginViewModel,
                                          authService: mockAuthService,
                                          alertManager: alertManager)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAuthService = nil
        super.tearDown()
    }
    
    func testIntialState() {
        XCTAssertTrue(viewModel.firstName.isEmpty)
        XCTAssertTrue(viewModel.lastName.isEmpty)
        XCTAssertTrue(viewModel.email.isEmpty)
        XCTAssertTrue(viewModel.password.isEmpty)
        XCTAssertTrue(viewModel.confirmPassword.isEmpty)
        XCTAssertFalse(viewModel.isFormValid)
    }
    
    func test_IsFormValid_WithValidInput_ShouldReturnTrue() {
        // Arrange
        viewModel.firstName = "Abc"
        viewModel.lastName = "Xyz"
        viewModel.email = "abc.xyz@gmail.com"
        viewModel.password = "123456"
        viewModel.confirmPassword = "123456"
        
        // Act & Assert
        XCTAssertTrue(viewModel.isFormValid, "Form should be valid with all inout parameters")
    }
    
    func test_IsFormValid_WithInvalidInput_ShouldReturnFalse() {
        
        // Arrange
        viewModel.firstName = "" // firstName is empty
        viewModel.lastName = "Xyz"
        viewModel.email = "abc.xyzgmail.com"
        viewModel.password = "123456"
        viewModel.confirmPassword = "123456"
    
        // Act & Assert
        XCTAssertFalse(viewModel.isFormValid, "Form should be Invalid with empty FirstName")
        
        // Arrange
        viewModel.firstName = "Abc"
        viewModel.lastName = "" // lastName is empty
        viewModel.email = "abc.xyzgmail.com"
        viewModel.password = "123456"
        viewModel.confirmPassword = "123456"
    
        // Act & Assert
        XCTAssertFalse(viewModel.isFormValid, "Form should be Invalid with empty LastName")
        
        
        // Arrange
        viewModel.firstName = "Abc"
        viewModel.lastName = "Xyz"
        viewModel.email = "abc.xyzgmail.com" // @ missing in email
        viewModel.password = "123456"
        viewModel.confirmPassword = "123456"
    
        // Act & Assert
        XCTAssertNotNil(viewModel.emailErrorMessage)
        XCTAssertFalse(viewModel.isFormValid, "Form should be Invalid with incorrect email")
        
        // Arrange
        viewModel.firstName = "Abc"
        viewModel.lastName = "Xyz"
        viewModel.email = "abc.xyzgmail.com"
        viewModel.password = "123"
        viewModel.confirmPassword = "123"
        
        // Act & Assert
        XCTAssertNotNil(viewModel.passwordErrorMessage)
        XCTAssertFalse(viewModel.isFormValid, "Form should be Invalid with password should have atleast 6 charactes")
        
        
        // Arrange
        viewModel.firstName = "Abc"
        viewModel.lastName = "Xyz"
        viewModel.email = "abc.xyzgmail.com"
        viewModel.password = "123456"
        viewModel.confirmPassword = "1234567"
        
        // Act & Assert
        XCTAssertNotNil(viewModel.confirmPasswordErrorMessage)
        XCTAssertFalse(viewModel.isFormValid, "Form should be Invalid with confirm password doesn't match with password")
        
    }
    
    func test_UserResgistration_WithValidDetails() async {
        // Arrange
        viewModel.email = "abc.xyz@gmail.com"
        viewModel.password = "123456"
        viewModel.firstName = "Abc"
        viewModel.lastName = "Xyz"
        viewModel.confirmPassword = "123456"
        
        XCTAssertFalse(viewModel.loginViewModel.path.isEmpty, "Should not be empty before user registration")
        
        // Act
        await viewModel.registerUser()
        
        // Assert
        XCTAssertTrue(mockAuthService.isUserRegistered, "Should be true after user registation")
        XCTAssertTrue (viewModel.loginViewModel.path.isEmpty, "Should be empty after user registration")
    }
    func test_userRegistration_WithInvalidDetails() async {
        // Arrange
        viewModel.email = "abc.xyzgmail.com" //Missing @
        viewModel.password = "123456"
        viewModel.firstName = "Abc"
        viewModel.lastName = "Xyz"
        viewModel.confirmPassword = "123456"
        
        // Act
        await viewModel.registerUser()
        
        // Assert
        XCTAssertFalse(viewModel.isFormValid, "Should be false, email is not valid")
        XCTAssertFalse(mockAuthService.isUserRegistered, "Should be false before user registation")
    }
}
