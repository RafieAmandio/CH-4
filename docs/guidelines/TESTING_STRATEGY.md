# Testing Strategy Guide 🧪

A comprehensive guide to testing iOS applications with Swift, covering unit tests, integration tests, UI tests, and testing best practices.

## 📋 Table of Contents

1. [Testing Philosophy](#testing-philosophy)
2. [Test Pyramid](#test-pyramid)
3. [Unit Testing](#unit-testing)
4. [Integration Testing](#integration-testing)
5. [UI Testing](#ui-testing)
6. [Testing Patterns](#testing-patterns)
7. [Mocking and Stubbing](#mocking-and-stubbing)
8. [Test Organization](#test-organization)
9. [Continuous Integration](#continuous-integration)
10. [Performance Testing](#performance-testing)

## Testing Philosophy

### 🎯 Core Principles

1. **Fast**: Tests should run quickly to encourage frequent execution
2. **Independent**: Tests should not depend on each other
3. **Repeatable**: Tests should produce consistent results
4. **Self-Validating**: Tests should have clear pass/fail outcomes
5. **Timely**: Tests should be written close to when the code is written

### 📊 Testing Goals

- **Confidence**: Ensure code works as expected
- **Documentation**: Tests serve as living documentation
- **Regression Prevention**: Catch bugs before they reach production
- **Design Feedback**: Tests help improve code design
- **Refactoring Safety**: Enable safe code changes

## Test Pyramid

### 🔺 Testing Levels

```
        /\     UI Tests (Few)
       /  \    - End-to-end scenarios
      /    \   - User workflows
     /______\  - Critical paths
    /        \
   / Integration \ Integration Tests (Some)
  /    Tests     \ - Component interactions
 /_______________ \ - API integrations
/                 \
/   Unit Tests     \ Unit Tests (Many)
/     (70%)        \ - Business logic
/__________________\ - Individual components
                     - Edge cases
```

### 📈 Test Distribution

| Test Type | Percentage | Purpose | Speed |
|-----------|------------|---------|-------|
| **Unit Tests** | 70% | Test individual components | Fast (ms) |
| **Integration Tests** | 20% | Test component interactions | Medium (seconds) |
| **UI Tests** | 10% | Test user workflows | Slow (minutes) |

## Unit Testing

### 🧪 Basic Unit Test Structure

```swift
import XCTest
@testable import YourApp

class UserValidatorTests: XCTestCase {
    
    // MARK: - Properties
    private var sut: UserValidator!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        sut = UserValidator()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testValidEmail_WithValidFormat_ReturnsTrue() {
        // Given
        let validEmail = "user@example.com"
        
        // When
        let result = sut.isValidEmail(validEmail)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func testValidEmail_WithInvalidFormat_ReturnsFalse() {
        // Given
        let invalidEmail = "invalid-email"
        
        // When
        let result = sut.isValidEmail(invalidEmail)
        
        // Then
        XCTAssertFalse(result)
    }
    
    func testValidEmail_WithEmptyString_ReturnsFalse() {
        // Given
        let emptyEmail = ""
        
        // When
        let result = sut.isValidEmail(emptyEmail)
        
        // Then
        XCTAssertFalse(result)
    }
}
```

### 🎯 Testing ViewModels

```swift
class UserViewModelTests: XCTestCase {
    
    // MARK: - Properties
    private var sut: UserViewModel!
    private var mockUserService: MockUserService!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        mockUserService = MockUserService()
        sut = UserViewModel(userService: mockUserService)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        sut = nil
        mockUserService = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testLoadUsers_WhenServiceReturnsUsers_UpdatesUsersProperty() {
        // Given
        let expectedUsers = [User.mock(), User.mock()]
        mockUserService.getUsersResult = .success(expectedUsers)
        
        let expectation = XCTestExpectation(description: "Users loaded")
        
        sut.$users
            .dropFirst() // Skip initial empty value
            .sink { users in
                XCTAssertEqual(users.count, expectedUsers.count)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.loadUsers()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockUserService.getUsersCallCount, 1)
    }
    
    func testLoadUsers_WhenServiceFails_UpdatesErrorMessage() {
        // Given
        let expectedError = NetworkError.serverError
        mockUserService.getUsersResult = .failure(expectedError)
        
        let expectation = XCTestExpectation(description: "Error handled")
        
        sut.$errorMessage
            .compactMap { $0 }
            .sink { errorMessage in
                XCTAssertFalse(errorMessage.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.loadUsers()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadUsers_SetsLoadingStateCorrectly() {
        // Given
        mockUserService.getUsersResult = .success([User.mock()])
        
        var loadingStates: [Bool] = []
        let expectation = XCTestExpectation(description: "Loading states captured")
        
        sut.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count == 3 { // initial, true, false
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        sut.loadUsers()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(loadingStates, [false, true, false])
    }
}
```

### 🔄 Testing Async Code

```swift
class AsyncServiceTests: XCTestCase {
    
    private var sut: UserService!
    private var mockAPIService: MockAPIService!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        sut = UserService(apiService: mockAPIService)
    }
    
    // MARK: - Async/Await Tests
    func testGetUser_WithValidId_ReturnsUser() async throws {
        // Given
        let expectedUser = User.mock()
        mockAPIService.getUserResult = .success(expectedUser)
        
        // When
        let result = try await sut.getUser(id: "123")
        
        // Then
        XCTAssertEqual(result.id, expectedUser.id)
        XCTAssertEqual(result.name, expectedUser.name)
    }
    
    func testGetUser_WithInvalidId_ThrowsError() async {
        // Given
        mockAPIService.getUserResult = .failure(NetworkError.userNotFound)
        
        // When & Then
        do {
            _ = try await sut.getUser(id: "invalid")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
    
    // MARK: - Combine Tests
    func testGetUserPublisher_WithValidId_EmitsUser() {
        // Given
        let expectedUser = User.mock()
        mockAPIService.getUserResult = .success(expectedUser)
        
        let expectation = XCTestExpectation(description: "User received")
        var receivedUser: User?
        
        // When
        sut.getUserPublisher(id: "123")
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Unexpected failure")
                    }
                },
                receiveValue: { user in
                    receivedUser = user
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedUser?.id, expectedUser.id)
    }
}
```

## Integration Testing

### 🔗 Testing Component Interactions

```swift
class UserRepositoryIntegrationTests: XCTestCase {
    
    private var sut: UserRepository!
    private var coreDataStack: TestCoreDataStack!
    private var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        coreDataStack = TestCoreDataStack()
        mockNetworkService = MockNetworkService()
        sut = UserRepository(
            coreDataStack: coreDataStack,
            networkService: mockNetworkService
        )
    }
    
    override func tearDown() {
        sut = nil
        coreDataStack = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    func testGetUser_WhenCachedLocally_ReturnsLocalUser() async throws {
        // Given
        let localUser = User.mock()
        try coreDataStack.saveUser(localUser)
        
        // When
        let result = try await sut.getUser(id: localUser.id)
        
        // Then
        XCTAssertEqual(result.id, localUser.id)
        XCTAssertEqual(mockNetworkService.requestCount, 0) // No network call
    }
    
    func testGetUser_WhenNotCached_FetchesFromNetworkAndCaches() async throws {
        // Given
        let networkUser = User.mock()
        mockNetworkService.getUserResult = .success(networkUser)
        
        // When
        let result = try await sut.getUser(id: networkUser.id)
        
        // Then
        XCTAssertEqual(result.id, networkUser.id)
        XCTAssertEqual(mockNetworkService.requestCount, 1)
        
        // Verify caching
        let cachedUser = try coreDataStack.fetchUser(id: networkUser.id)
        XCTAssertNotNil(cachedUser)
    }
}
```

### 🌐 API Integration Tests

```swift
class APIIntegrationTests: XCTestCase {
    
    private var sut: APIService!
    private var mockURLSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        sut = APIService(urlSession: mockURLSession)
    }
    
    func testFetchUsers_WithValidResponse_ReturnsDecodedUsers() async throws {
        // Given
        let users = [User.mock(), User.mock()]
        let responseData = try JSONEncoder().encode(users)
        
        mockURLSession.data = responseData
        mockURLSession.response = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        let result = try await sut.fetchUsers()
        
        // Then
        XCTAssertEqual(result.count, users.count)
        XCTAssertEqual(result.first?.id, users.first?.id)
    }
    
    func testFetchUsers_WithServerError_ThrowsNetworkError() async {
        // Given
        mockURLSession.response = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When & Then
        do {
            _ = try await sut.fetchUsers()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
}
```

## UI Testing

### 📱 Basic UI Test Structure

```swift
class UserListUITests: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    func testUserList_WhenLaunched_DisplaysUsers() {
        // Given
        let userList = app.tables["UserList"]
        
        // When
        // App launches with mock data in UI testing mode
        
        // Then
        XCTAssertTrue(userList.exists)
        XCTAssertTrue(userList.cells.count > 0)
    }
    
    func testUserList_WhenUserTapped_NavigatesToDetail() {
        // Given
        let userList = app.tables["UserList"]
        let firstUser = userList.cells.firstMatch
        
        // When
        firstUser.tap()
        
        // Then
        let detailView = app.otherElements["UserDetailView"]
        XCTAssertTrue(detailView.waitForExistence(timeout: 2.0))
    }
    
    func testUserList_WhenSearching_FiltersResults() {
        // Given
        let searchField = app.searchFields["Search users"]
        let userList = app.tables["UserList"]
        
        let initialCellCount = userList.cells.count
        
        // When
        searchField.tap()
        searchField.typeText("John")
        
        // Then
        let filteredCellCount = userList.cells.count
        XCTAssertLessThan(filteredCellCount, initialCellCount)
    }
}
```

### 🎭 Page Object Pattern

```swift
// MARK: - Page Objects
struct UserListPage {
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    // MARK: - Elements
    var userList: XCUIElement {
        app.tables["UserList"]
    }
    
    var searchField: XCUIElement {
        app.searchFields["Search users"]
    }
    
    var addButton: XCUIElement {
        app.buttons["Add User"]
    }
    
    // MARK: - Actions
    func tapUser(at index: Int) {
        userList.cells.element(boundBy: index).tap()
    }
    
    func search(for text: String) {
        searchField.tap()
        searchField.typeText(text)
    }
    
    func tapAddButton() {
        addButton.tap()
    }
    
    // MARK: - Assertions
    func assertUserListExists() {
        XCTAssertTrue(userList.exists)
    }
    
    func assertUserCount(_ expectedCount: Int) {
        XCTAssertEqual(userList.cells.count, expectedCount)
    }
}

struct UserDetailPage {
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var detailView: XCUIElement {
        app.otherElements["UserDetailView"]
    }
    
    var nameLabel: XCUIElement {
        app.staticTexts["UserName"]
    }
    
    var emailLabel: XCUIElement {
        app.staticTexts["UserEmail"]
    }
    
    var backButton: XCUIElement {
        app.navigationBars.buttons.element(boundBy: 0)
    }
    
    func waitForAppearance() -> Bool {
        return detailView.waitForExistence(timeout: 2.0)
    }
    
    func tapBack() {
        backButton.tap()
    }
}

// MARK: - Usage in Tests
class UserFlowUITests: XCTestCase {
    
    private var app: XCUIApplication!
    private var userListPage: UserListPage!
    private var userDetailPage: UserDetailPage!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
        
        userListPage = UserListPage(app: app)
        userDetailPage = UserDetailPage(app: app)
    }
    
    func testCompleteUserFlow() {
        // Given
        userListPage.assertUserListExists()
        
        // When
        userListPage.tapUser(at: 0)
        
        // Then
        XCTAssertTrue(userDetailPage.waitForAppearance())
        
        // When
        userDetailPage.tapBack()
        
        // Then
        userListPage.assertUserListExists()
    }
}
```

## Testing Patterns

### 🏭 Test Data Builders

```swift
// MARK: - Test Data Builder
class UserBuilder {
    private var id: String = UUID().uuidString
    private var name: String = "John Doe"
    private var email: String = "john@example.com"
    private var age: Int = 30
    private var isActive: Bool = true
    
    func withId(_ id: String) -> UserBuilder {
        self.id = id
        return self
    }
    
    func withName(_ name: String) -> UserBuilder {
        self.name = name
        return self
    }
    
    func withEmail(_ email: String) -> UserBuilder {
        self.email = email
        return self
    }
    
    func withAge(_ age: Int) -> UserBuilder {
        self.age = age
        return self
    }
    
    func inactive() -> UserBuilder {
        self.isActive = false
        return self
    }
    
    func build() -> User {
        return User(
            id: id,
            name: name,
            email: email,
            age: age,
            isActive: isActive
        )
    }
}

// MARK: - Usage
class UserServiceTests: XCTestCase {
    
    func testFilterActiveUsers_WithMixedUsers_ReturnsOnlyActive() {
        // Given
        let users = [
            UserBuilder().withName("Active User").build(),
            UserBuilder().withName("Inactive User").inactive().build(),
            UserBuilder().withName("Another Active").build()
        ]
        
        // When
        let activeUsers = sut.filterActiveUsers(users)
        
        // Then
        XCTAssertEqual(activeUsers.count, 2)
        XCTAssertTrue(activeUsers.allSatisfy { $0.isActive })
    }
}
```

### 🎯 Parameterized Tests

```swift
class EmailValidationTests: XCTestCase {
    
    private var sut: EmailValidator!
    
    override func setUp() {
        super.setUp()
        sut = EmailValidator()
    }
    
    func testValidEmails() {
        let validEmails = [
            "user@example.com",
            "test.email@domain.co.uk",
            "user+tag@example.org",
            "123@numbers.com"
        ]
        
        for email in validEmails {
            XCTAssertTrue(
                sut.isValid(email),
                "Expected \(email) to be valid"
            )
        }
    }
    
    func testInvalidEmails() {
        let invalidEmails = [
            "invalid-email",
            "@example.com",
            "user@",
            "user..double.dot@example.com",
            ""
        ]
        
        for email in invalidEmails {
            XCTAssertFalse(
                sut.isValid(email),
                "Expected \(email) to be invalid"
            )
        }
    }
}
```

## Mocking and Stubbing

### 🎭 Protocol-Based Mocks

```swift
// MARK: - Protocol
protocol UserServiceProtocol {
    func getUser(id: String) async throws -> User
    func getUsers() async throws -> [User]
    func createUser(_ user: User) async throws -> User
}

// MARK: - Mock Implementation
class MockUserService: UserServiceProtocol {
    
    // MARK: - Call Tracking
    private(set) var getUserCallCount = 0
    private(set) var getUsersCallCount = 0
    private(set) var createUserCallCount = 0
    
    private(set) var lastGetUserId: String?
    private(set) var lastCreatedUser: User?
    
    // MARK: - Stubbed Results
    var getUserResult: Result<User, Error> = .failure(TestError.notImplemented)
    var getUsersResult: Result<[User], Error> = .failure(TestError.notImplemented)
    var createUserResult: Result<User, Error> = .failure(TestError.notImplemented)
    
    // MARK: - Protocol Implementation
    func getUser(id: String) async throws -> User {
        getUserCallCount += 1
        lastGetUserId = id
        
        switch getUserResult {
        case .success(let user):
            return user
        case .failure(let error):
            throw error
        }
    }
    
    func getUsers() async throws -> [User] {
        getUsersCallCount += 1
        
        switch getUsersResult {
        case .success(let users):
            return users
        case .failure(let error):
            throw error
        }
    }
    
    func createUser(_ user: User) async throws -> User {
        createUserCallCount += 1
        lastCreatedUser = user
        
        switch createUserResult {
        case .success(let createdUser):
            return createdUser
        case .failure(let error):
            throw error
        }
    }
    
    // MARK: - Helper Methods
    func reset() {
        getUserCallCount = 0
        getUsersCallCount = 0
        createUserCallCount = 0
        lastGetUserId = nil
        lastCreatedUser = nil
    }
}

enum TestError: Error {
    case notImplemented
    case mockError
}
```

### 🔧 Dependency Injection for Testing

```swift
// MARK: - Production Code
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userService: UserServiceProtocol
    
    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }
    
    func loadUsers() {
        Task {
            await MainActor.run { isLoading = true }
            
            do {
                let fetchedUsers = try await userService.getUsers()
                await MainActor.run {
                    self.users = fetchedUsers
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Test Code
class UserViewModelTests: XCTestCase {
    
    private var sut: UserViewModel!
    private var mockUserService: MockUserService!
    
    override func setUp() {
        super.setUp()
        mockUserService = MockUserService()
        sut = UserViewModel(userService: mockUserService)
    }
    
    func testLoadUsers_Success() {
        // Given
        let expectedUsers = [User.mock(), User.mock()]
        mockUserService.getUsersResult = .success(expectedUsers)
        
        // When
        sut.loadUsers()
        
        // Then
        // Test implementation...
    }
}
```

## Test Organization

### 📁 Test File Structure

```
Tests/
├── UnitTests/
│   ├── Domain/
│   │   ├── Entities/
│   │   │   └── UserTests.swift
│   │   └── UseCases/
│   │       └── GetUserUseCaseTests.swift
│   ├── Data/
│   │   ├── Repositories/
│   │   │   └── UserRepositoryTests.swift
│   │   └── Services/
│   │       └── APIServiceTests.swift
│   └── Presentation/
│       ├── ViewModels/
│       │   └── UserViewModelTests.swift
│       └── Views/
│           └── UserViewTests.swift
├── IntegrationTests/
│   ├── API/
│   │   └── UserAPIIntegrationTests.swift
│   └── Database/
│       └── CoreDataIntegrationTests.swift
├── UITests/
│   ├── UserFlowUITests.swift
│   └── OnboardingUITests.swift
└── TestHelpers/
    ├── Mocks/
    │   ├── MockUserService.swift
    │   └── MockAPIService.swift
    ├── Builders/
    │   └── UserBuilder.swift
    └── Extensions/
        └── XCTestCase+Extensions.swift
```

### 🏷️ Test Naming Conventions

```swift
// Pattern: test[MethodName]_[Scenario]_[ExpectedResult]

func testGetUser_WithValidId_ReturnsUser() { }
func testGetUser_WithInvalidId_ThrowsError() { }
func testGetUser_WhenNetworkFails_ThrowsNetworkError() { }

func testValidateEmail_WithValidFormat_ReturnsTrue() { }
func testValidateEmail_WithInvalidFormat_ReturnsFalse() { }
func testValidateEmail_WithEmptyString_ReturnsFalse() { }
```

### 🧹 Test Helpers and Extensions

```swift
// MARK: - XCTestCase Extensions
extension XCTestCase {
    
    func waitForPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output where T.Failure == Never {
        
        var result: T.Output?
        let expectation = XCTestExpectation(description: "Publisher expectation")
        
        let cancellable = publisher
            .sink { value in
                result = value
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: timeout)
        cancellable.cancel()
        
        guard let unwrappedResult = result else {
            XCTFail("Publisher did not emit a value", file: file, line: line)
            throw TestError.publisherTimeout
        }
        
        return unwrappedResult
    }
    
    func assertThrowsError<T, E: Error>(
        _ expression: @autoclosure () async throws -> T,
        errorType: E.Type,
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expected error of type \(errorType) to be thrown", file: file, line: line)
        } catch {
            XCTAssertTrue(error is E, "Expected error of type \(errorType), got \(type(of: error))", file: file, line: line)
        }
    }
}

// MARK: - Mock Data Extensions
extension User {
    static func mock(
        id: String = UUID().uuidString,
        name: String = "John Doe",
        email: String = "john@example.com",
        age: Int = 30
    ) -> User {
        return User(id: id, name: name, email: email, age: age)
    }
}
```

## Continuous Integration

### 🔄 CI Test Configuration

```yaml
# .github/workflows/tests.yml
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Select Xcode Version
      run: sudo xcode-select -s /Applications/Xcode_14.2.app/Contents/Developer
    
    - name: Install Dependencies
      run: |
        # Install any dependencies (e.g., via SPM, CocoaPods)
        
    - name: Run Unit Tests
      run: |
        xcodebuild test \
          -scheme YourApp \
          -destination 'platform=iOS Simulator,name=iPhone 14,OS=16.2' \
          -only-testing:YourAppTests \
          -enableCodeCoverage YES
    
    - name: Run Integration Tests
      run: |
        xcodebuild test \
          -scheme YourApp \
          -destination 'platform=iOS Simulator,name=iPhone 14,OS=16.2' \
          -only-testing:YourAppIntegrationTests
    
    - name: Generate Code Coverage
      run: |
        xcrun xccov view --report --json DerivedData/Logs/Test/*.xcresult > coverage.json
    
    - name: Upload Coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.json
```

### 📊 Test Metrics

```swift
// MARK: - Test Performance Measurement
class PerformanceTests: XCTestCase {
    
    func testUserProcessingPerformance() {
        let users = (0..<1000).map { User.mock(id: "\($0)") }
        
        measure {
            let processedUsers = UserProcessor.process(users)
            XCTAssertEqual(processedUsers.count, users.count)
        }
    }
    
    func testDatabaseQueryPerformance() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            let users = coreDataStack.fetchUsers(limit: 1000)
            XCTAssertLessThanOrEqual(users.count, 1000)
        }
    }
}
```

## Performance Testing

### ⚡ Memory and CPU Testing

```swift
class MemoryLeakTests: XCTestCase {
    
    func testViewModelDoesNotLeak() {
        weak var weakViewModel: UserViewModel?
        
        autoreleasepool {
            let viewModel = UserViewModel()
            weakViewModel = viewModel
            
            // Use the view model
            viewModel.loadUsers()
        }
        
        XCTAssertNil(weakViewModel, "ViewModel should be deallocated")
    }
    
    func testImageCacheMemoryUsage() {
        let imageCache = ImageCache()
        
        measure(metrics: [XCTMemoryMetric()]) {
            for i in 0..<100 {
                let image = UIImage(systemName: "star")!
                imageCache.store(image, forKey: "image_\(i)")
            }
        }
    }
}
```

---

## 📋 Testing Checklist

### ✅ Before Writing Tests

- [ ] **Understand Requirements**: Know what the code should do
- [ ] **Identify Edge Cases**: Consider boundary conditions
- [ ] **Plan Test Structure**: Organize tests logically
- [ ] **Set Up Mocks**: Create necessary test doubles
- [ ] **Prepare Test Data**: Use builders or factories

### ✅ Writing Good Tests

- [ ] **Clear Names**: Test names describe scenario and expectation
- [ ] **Single Responsibility**: Each test verifies one behavior
- [ ] **Arrange-Act-Assert**: Follow the AAA pattern
- [ ] **Independent**: Tests don't depend on each other
- [ ] **Deterministic**: Tests produce consistent results

### ✅ Test Maintenance

- [ ] **Keep Updated**: Tests evolve with code changes
- [ ] **Remove Obsolete**: Delete tests for removed features
- [ ] **Refactor**: Improve test code quality
- [ ] **Monitor Coverage**: Maintain appropriate test coverage
- [ ] **Review Regularly**: Ensure tests still provide value

---

**Remember**: Good tests are an investment in code quality and team productivity. Write tests that provide confidence and enable fearless refactoring! 🚀