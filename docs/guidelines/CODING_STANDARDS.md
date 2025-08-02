# Swift Coding Standards Guide 📝

A comprehensive guide to Swift coding conventions and best practices for iOS development teams.

## 📋 Table of Contents

1. [General Principles](#general-principles)
2. [Naming Conventions](#naming-conventions)
3. [Code Organization](#code-organization)
4. [Swift Language Features](#swift-language-features)
5. [SwiftUI Best Practices](#swiftui-best-practices)
6. [Error Handling](#error-handling)
7. [Performance Guidelines](#performance-guidelines)
8. [Documentation Standards](#documentation-standards)

## General Principles

### 🎯 Core Values

1. **Clarity over Brevity**: Code should be self-documenting
2. **Consistency**: Follow established patterns throughout the codebase
3. **Safety**: Prefer safe, explicit code over clever shortcuts
4. **Performance**: Write efficient code without sacrificing readability
5. **Maintainability**: Code should be easy to modify and extend

### ✅ Code Quality Checklist

- [ ] **Readable**: Code tells a story
- [ ] **Consistent**: Follows team conventions
- [ ] **Safe**: Handles edge cases and errors
- [ ] **Tested**: Has appropriate test coverage
- [ ] **Documented**: Complex logic is explained

## Naming Conventions

### 🏷️ General Rules

```swift
// ✅ Good: Clear, descriptive names
class UserProfileViewController { }
var isUserLoggedIn: Bool = false
func calculateTotalPrice() -> Double { }

// ❌ Bad: Unclear, abbreviated names
class UsrProfVC { }
var isUsrLog: Bool = false
func calcTotPrc() -> Double { }
```

### 📝 Naming Patterns

| Element | Convention | Example |
|---------|------------|----------|
| **Classes** | PascalCase, noun | `UserManager`, `NetworkService` |
| **Structs** | PascalCase, noun | `UserProfile`, `APIResponse` |
| **Enums** | PascalCase, noun | `NetworkError`, `UserRole` |
| **Protocols** | PascalCase, adjective (-able) | `Cacheable`, `Downloadable` |
| **Variables** | camelCase, descriptive | `userName`, `isLoading` |
| **Functions** | camelCase, verb | `loadUser()`, `validateEmail()` |
| **Constants** | camelCase | `maxRetryCount`, `defaultTimeout` |
| **Enum Cases** | camelCase | `.loading`, `.success`, `.failure` |

### 🔤 Specific Naming Guidelines

```swift
// ✅ Boolean variables: Use "is", "has", "can", "should"
var isVisible: Bool
var hasPermission: Bool
var canEdit: Bool
var shouldRefresh: Bool

// ✅ Collections: Use plural nouns
var users: [User]
var activeConnections: Set<Connection>
var userPreferences: [String: Any]

// ✅ Functions: Start with verb, describe what they do
func loadUserProfile() { }
func validateEmailAddress(_ email: String) -> Bool { }
func transformDataToModel(_ data: Data) -> User? { }

// ✅ Protocols: Use "-able" suffix for capabilities
protocol Cacheable {
    func cache()
    func clearCache()
}

protocol Downloadable {
    func download() async throws
}
```

## Code Organization

### 📁 File Structure

```swift
// ✅ Good: Organized file structure
import Foundation
import SwiftUI
import Combine

// MARK: - Protocol Definitions
protocol UserServiceProtocol {
    func getUser(id: String) async throws -> User
}

// MARK: - Main Implementation
class UserService: UserServiceProtocol {
    
    // MARK: - Properties
    private let apiService: APIService
    private let cacheManager: CacheManager
    
    // MARK: - Initialization
    init(apiService: APIService, cacheManager: CacheManager) {
        self.apiService = apiService
        self.cacheManager = cacheManager
    }
    
    // MARK: - Public Methods
    func getUser(id: String) async throws -> User {
        // Implementation
    }
    
    // MARK: - Private Methods
    private func validateUserId(_ id: String) -> Bool {
        // Implementation
    }
}

// MARK: - Extensions
extension UserService {
    func getUsersInBatch(_ ids: [String]) async throws -> [User] {
        // Implementation
    }
}
```

### 🏗️ Class Organization

```swift
class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    // MARK: - Properties
    private var viewModel: ViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        return !titleLabel.text?.isEmpty ?? false
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Implementation
    }
    
    // MARK: - Setup
    private func setupUI() {
        // UI setup code
    }
    
    private func bindViewModel() {
        // Binding code
    }
    
    // MARK: - Actions
    @IBAction private func submitButtonTapped(_ sender: UIButton) {
        // Action implementation
    }
    
    // MARK: - Private Methods
    private func validateForm() -> Bool {
        // Validation logic
    }
}
```

### 📦 Import Organization

```swift
// ✅ Good: Organized imports
// System frameworks first
import Foundation
import UIKit
import SwiftUI
import Combine

// Third-party frameworks
import Alamofire
import Kingfisher

// Internal modules
import Core
import Domain
import Data

// ❌ Bad: Random import order
import Kingfisher
import Foundation
import Core
import UIKit
```

## Swift Language Features

### 🔒 Access Control

```swift
// ✅ Good: Explicit access control
class UserManager {
    
    // Public interface
    public func getUser(id: String) -> User? {
        return findUser(by: id)
    }
    
    // Internal implementation
    internal var cache: [String: User] = [:]
    
    // Private helpers
    private func findUser(by id: String) -> User? {
        return cache[id]
    }
    
    // File-private utilities
    fileprivate func clearExpiredCache() {
        // Implementation
    }
}

// ✅ Use private(set) for read-only properties
class ViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var users: [User] = []
    
    func loadUsers() {
        isLoading = true
        // Load users...
        isLoading = false
    }
}
```

### 🎯 Optionals

```swift
// ✅ Good: Safe optional handling
func processUser(_ user: User?) {
    guard let user = user else {
        print("No user provided")
        return
    }
    
    // Process user safely
    print("Processing user: \(user.name)")
}

// ✅ Use nil coalescing for defaults
let userName = user?.name ?? "Anonymous"
let userAge = user?.age ?? 0

// ✅ Use optional chaining
let profileImageURL = user?.profile?.imageURL?.absoluteString

// ❌ Bad: Force unwrapping
let userName = user!.name  // Dangerous!
let userAge = user?.age!   // Dangerous!
```

### 🔄 Error Handling

```swift
// ✅ Good: Comprehensive error handling
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingFailed
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .noData:
            return "No data received from server"
        case .decodingFailed:
            return "Failed to decode response"
        case .serverError(let code):
            return "Server error with code: \(code)"
        }
    }
}

// ✅ Use Result type for async operations
func fetchUser(id: String) async -> Result<User, NetworkError> {
    do {
        let user = try await apiService.getUser(id: id)
        return .success(user)
    } catch {
        return .failure(.serverError(500))
    }
}

// ✅ Handle errors gracefully
func loadUserData() {
    Task {
        let result = await fetchUser(id: "123")
        
        switch result {
        case .success(let user):
            await MainActor.run {
                self.user = user
            }
        case .failure(let error):
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
```

### 🏃‍♂️ Async/Await

```swift
// ✅ Good: Proper async/await usage
class UserService {
    
    func getUser(id: String) async throws -> User {
        let url = URL(string: "https://api.example.com/users/\(id)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(User.self, from: data)
    }
    
    func getMultipleUsers(ids: [String]) async throws -> [User] {
        // Use TaskGroup for concurrent operations
        return try await withThrowingTaskGroup(of: User.self) { group in
            for id in ids {
                group.addTask {
                    try await self.getUser(id: id)
                }
            }
            
            var users: [User] = []
            for try await user in group {
                users.append(user)
            }
            return users
        }
    }
}

// ✅ Handle MainActor updates properly
class ViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    
    func loadUsers() {
        Task {
            await MainActor.run {
                isLoading = true
            }
            
            do {
                let fetchedUsers = try await userService.getUsers()
                await MainActor.run {
                    self.users = fetchedUsers
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    // Handle error
                }
            }
        }
    }
}
```

## SwiftUI Best Practices

### 🎨 View Composition

```swift
// ✅ Good: Small, focused views
struct UserProfileView: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 16) {
            UserAvatarView(user: user)
            UserInfoView(user: user)
            UserActionsView(user: user)
        }
        .padding()
    }
}

struct UserAvatarView: View {
    let user: User
    
    var body: some View {
        AsyncImage(url: user.avatarURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Circle()
                .fill(Color.gray.opacity(0.3))
        }
        .frame(width: 80, height: 80)
        .clipShape(Circle())
    }
}

// ✅ Use ViewBuilder for complex layouts
struct ConditionalView: View {
    let showDetails: Bool
    
    var body: some View {
        VStack {
            HeaderView()
            
            contentView
            
            FooterView()
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if showDetails {
            DetailedContentView()
        } else {
            SummaryContentView()
        }
    }
}
```

### 🔄 State Management

```swift
// ✅ Good: Proper state management
struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var showingSheet = false
    @State private var selectedItem: Item?
    
    var body: some View {
        NavigationView {
            List(viewModel.items) { item in
                ItemRow(item: item)
                    .onTapGesture {
                        selectedItem = item
                        showingSheet = true
                    }
            }
            .task {
                await viewModel.loadItems()
            }
            .sheet(isPresented: $showingSheet) {
                if let item = selectedItem {
                    ItemDetailView(item: item)
                }
            }
        }
    }
}

// ✅ Use @Published for reactive updates
class ContentViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let itemService: ItemService
    
    init(itemService: ItemService = ItemService()) {
        self.itemService = itemService
    }
    
    @MainActor
    func loadItems() async {
        isLoading = true
        errorMessage = nil
        
        do {
            items = try await itemService.fetchItems()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
```

### 🎭 Custom Modifiers

```swift
// ✅ Good: Reusable view modifiers
struct CardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .shadow(radius: shadowRadius)
    }
}

extension View {
    func cardStyle(
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat = 4
    ) -> some View {
        modifier(CardModifier(
            cornerRadius: cornerRadius,
            shadowRadius: shadowRadius
        ))
    }
}

// Usage
struct ItemCard: View {
    let item: Item
    
    var body: some View {
        VStack {
            Text(item.title)
            Text(item.description)
        }
        .padding()
        .cardStyle()
    }
}
```

## Error Handling

### 🚨 Error Types

```swift
// ✅ Good: Structured error handling
enum UserServiceError: Error, LocalizedError {
    case invalidUserId
    case userNotFound
    case networkUnavailable
    case authenticationRequired
    case serverError(message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidUserId:
            return "The provided user ID is invalid"
        case .userNotFound:
            return "User not found"
        case .networkUnavailable:
            return "Network connection unavailable"
        case .authenticationRequired:
            return "Authentication required to access this resource"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable:
            return "Please check your internet connection and try again"
        case .authenticationRequired:
            return "Please log in to continue"
        default:
            return nil
        }
    }
}
```

### 🛡️ Defensive Programming

```swift
// ✅ Good: Input validation and error handling
func processUserData(_ userData: [String: Any]) throws -> User {
    guard let id = userData["id"] as? String, !id.isEmpty else {
        throw UserServiceError.invalidUserId
    }
    
    guard let name = userData["name"] as? String, !name.isEmpty else {
        throw ValidationError.missingRequiredField("name")
    }
    
    guard let email = userData["email"] as? String, isValidEmail(email) else {
        throw ValidationError.invalidEmail
    }
    
    return User(id: id, name: name, email: email)
}

// ✅ Use precondition for development-time checks
func calculatePercentage(value: Double, total: Double) -> Double {
    precondition(total > 0, "Total must be greater than zero")
    return (value / total) * 100
}

// ✅ Use assert for debug-only checks
func processArray<T>(_ array: [T]) {
    assert(!array.isEmpty, "Array should not be empty")
    // Process array
}
```

## Performance Guidelines

### ⚡ Memory Management

```swift
// ✅ Good: Avoid retain cycles
class ViewController: UIViewController {
    private var viewModel: ViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel?.onUpdate = { [weak self] in
            self?.updateUI()
        }
    }
}

// ✅ Use weak references in closures
class NetworkManager {
    func fetchData(completion: @escaping (Data?) -> Void) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            // Process data
            completion(data)
        }.resume()
    }
}

// ✅ Lazy initialization for expensive operations
class DataProcessor {
    lazy var expensiveResource: ExpensiveResource = {
        return ExpensiveResource()
    }()
    
    lazy var complexCalculation: Double = {
        return performComplexCalculation()
    }()
}
```

### 🔄 Collection Performance

```swift
// ✅ Good: Efficient collection operations
func filterAndTransformUsers(_ users: [User]) -> [UserViewModel] {
    return users
        .filter { $0.isActive }
        .map { UserViewModel(user: $0) }
}

// ✅ Use Set for membership testing
func filterActiveUsers(_ users: [User], activeIds: Set<String>) -> [User] {
    return users.filter { activeIds.contains($0.id) }
}

// ✅ Use compactMap to filter and transform
func getValidEmails(from users: [User]) -> [String] {
    return users.compactMap { user in
        isValidEmail(user.email) ? user.email : nil
    }
}
```

## Documentation Standards

### 📚 Code Documentation

```swift
/// Manages user authentication and session handling.
/// 
/// This class provides methods for logging in, logging out, and maintaining
/// user session state. It integrates with the keychain for secure token storage.
/// 
/// Example usage:
/// ```swift
/// let authManager = AuthenticationManager()
/// try await authManager.login(email: "user@example.com", password: "password")
/// ```
class AuthenticationManager {
    
    /// The currently authenticated user, if any.
    /// 
    /// This property is updated automatically when the user logs in or out.
    /// Observers can monitor changes to this property to update the UI accordingly.
    @Published private(set) var currentUser: User?
    
    /// Authenticates a user with email and password.
    /// 
    /// - Parameters:
    ///   - email: The user's email address
    ///   - password: The user's password
    /// - Returns: The authenticated user object
    /// - Throws: `AuthenticationError` if login fails
    /// 
    /// - Note: This method stores the authentication token securely in the keychain
    /// - Warning: Ensure the password is transmitted securely
    func login(email: String, password: String) async throws -> User {
        // Implementation
    }
    
    /// Logs out the current user and clears stored credentials.
    /// 
    /// This method:
    /// 1. Invalidates the current session
    /// 2. Removes tokens from keychain
    /// 3. Clears user data from memory
    /// 
    /// - Important: Always call this method when the user explicitly logs out
    func logout() async {
        // Implementation
    }
}
```

### 📝 Inline Comments

```swift
func processPayment(_ amount: Double, currency: String) async throws -> PaymentResult {
    // Validate input parameters
    guard amount > 0 else {
        throw PaymentError.invalidAmount
    }
    
    // Convert to smallest currency unit (e.g., cents for USD)
    let amountInCents = Int(amount * 100)
    
    // Create payment request
    let request = PaymentRequest(
        amount: amountInCents,
        currency: currency,
        timestamp: Date()
    )
    
    // Process payment through external service
    // Note: This may take several seconds for card verification
    let response = try await paymentService.processPayment(request)
    
    // Log successful payment for audit trail
    logger.info("Payment processed successfully: \(response.transactionId)")
    
    return PaymentResult(from: response)
}
```

## 📋 Code Review Checklist

### ✅ Before Submitting

- [ ] **Naming**: All names are clear and descriptive
- [ ] **Organization**: Code is properly organized with MARK comments
- [ ] **Access Control**: Appropriate access levels are used
- [ ] **Error Handling**: Errors are handled gracefully
- [ ] **Performance**: No obvious performance issues
- [ ] **Memory**: No retain cycles or memory leaks
- [ ] **Testing**: Code is testable and has tests
- [ ] **Documentation**: Complex logic is documented
- [ ] **Consistency**: Follows established patterns
- [ ] **Safety**: Uses safe Swift features appropriately

### 🔍 During Review

- [ ] **Logic**: Code logic is correct and handles edge cases
- [ ] **Architecture**: Follows established architecture patterns
- [ ] **Dependencies**: Dependencies are minimal and appropriate
- [ ] **Reusability**: Code is reusable where appropriate
- [ ] **Maintainability**: Code will be easy to modify in the future

---

**Remember**: These standards are guidelines to help create better code. Use judgment and adapt them to your specific project needs! 🚀