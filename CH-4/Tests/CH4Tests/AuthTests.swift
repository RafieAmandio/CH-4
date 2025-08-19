//
//  AuthTests.swift
//  CH4Tests
//
//  Created by Dwiki on 15/08/25.
//

import XCTest
@testable import CH4

final class AuthTests: XCTestCase {
    
    func testUserModelCreation() {
        let user = User(
            userId: "test-user-id",
            email: "test@example.com",
            accessToken: "test-token",
            fullName: nil,
            signInTimestamp: Date()
        )
        
        XCTAssertEqual(user.userId, "test-user-id")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.accessToken, "test-token")
        XCTAssertNil(user.fullName)
    }
    
    func testUserModelWithFullName() {
        let fullName = PersonNameComponents()
        fullName.givenName = "John"
        fullName.familyName = "Doe"
        
        let user = User(
            userId: "test-user-id",
            email: "john.doe@example.com",
            accessToken: "test-token",
            fullName: fullName,
            signInTimestamp: Date()
        )
        
        XCTAssertEqual(user.fullName?.givenName, "John")
        XCTAssertEqual(user.fullName?.familyName, "Doe")
    }
    
    func testUserModelEquality() {
        let date = Date()
        let user1 = User(
            userId: "test-user-id",
            email: "test@example.com",
            accessToken: "test-token",
            fullName: nil,
            signInTimestamp: date
        )
        
        let user2 = User(
            userId: "test-user-id",
            email: "test@example.com",
            accessToken: "test-token",
            fullName: nil,
            signInTimestamp: date
        )
        
        XCTAssertEqual(user1, user2)
    }
}
