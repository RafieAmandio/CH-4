# iOS Design Patterns Guide 🏗️

A comprehensive guide to common design patterns used in iOS development, with practical Swift examples.

## 📋 Table of Contents

1. [Architectural Patterns](#architectural-patterns)
2. [Creational Patterns](#creational-patterns)
3. [Structural Patterns](#structural-patterns)
4. [Behavioral Patterns](#behavioral-patterns)
5. [iOS-Specific Patterns](#ios-specific-patterns)

## Architectural Patterns

### 🏛️ MVVM (Model-View-ViewModel)

**Purpose**: Separates UI logic from business logic in reactive applications.

```swift
// Model
struct User {
    let id: String
    let name: String
    let email: String
}

// ViewModel
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    
    private let userService: UserService
    
    init(userService: UserService) {
        self.userService = userService
    }
    
    func loadUsers() async {
        isLoading = true
        users = await userService.fetchUsers()
        isLoading = false
    }
}

// View
struct UserListView: View {
    @StateObject private var viewModel = UserViewModel(userService: UserService())
    
    var body: some View {
        List(viewModel.users, id: \.id) { user in
            Text(user.name)
        }
        .task {
            await viewModel.loadUsers()
        }
    }
}
```

### 🧅 Clean Architecture

**Purpose**: Creates maintainable, testable, and framework-independent code.

```swift
// Domain Layer - Entity
struct Product {
    let id: String
    let name: String
    let price: Double
}

// Domain Layer - Use Case Protocol
protocol GetProductsUseCase {
    func execute() async throws -> [Product]
}

// Domain Layer - Repository Protocol
protocol ProductRepository {
    func fetchProducts() async throws -> [Product]
}

// Data Layer - Repository Implementation
class ProductRepositoryImpl: ProductRepository {
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    func fetchProducts() async throws -> [Product] {
        let dtos = try await apiService.getProducts()
        return dtos.map { Product(from: $0) }
    }
}

// Domain Layer - Use Case Implementation
class GetProductsUseCaseImpl: GetProductsUseCase {
    private let repository: ProductRepository
    
    init(repository: ProductRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [Product] {
        return try await repository.fetchProducts()
    }
}
```

## Creational Patterns

### 🏭 Factory Pattern

**Purpose**: Creates objects without specifying their concrete classes.

```swift
protocol NetworkService {
    func request<T: Codable>(_ endpoint: String) async throws -> T
}

class ProductionNetworkService: NetworkService {
    func request<T: Codable>(_ endpoint: String) async throws -> T {
        // Real network implementation
    }
}

class MockNetworkService: NetworkService {
    func request<T: Codable>(_ endpoint: String) async throws -> T {
        // Mock implementation for testing
    }
}

class NetworkServiceFactory {
    static func create(environment: Environment) -> NetworkService {
        switch environment {
        case .production:
            return ProductionNetworkService()
        case .testing:
            return MockNetworkService()
        }
    }
}
```

### 🏗️ Builder Pattern

**Purpose**: Constructs complex objects step by step.

```swift
struct APIRequest {
    let url: URL
    let method: HTTPMethod
    let headers: [String: String]
    let body: Data?
    let timeout: TimeInterval
}

class APIRequestBuilder {
    private var url: URL?
    private var method: HTTPMethod = .GET
    private var headers: [String: String] = [:]
    private var body: Data?
    private var timeout: TimeInterval = 30
    
    func url(_ url: URL) -> APIRequestBuilder {
        self.url = url
        return self
    }
    
    func method(_ method: HTTPMethod) -> APIRequestBuilder {
        self.method = method
        return self
    }
    
    func header(_ key: String, _ value: String) -> APIRequestBuilder {
        headers[key] = value
        return self
    }
    
    func body(_ data: Data) -> APIRequestBuilder {
        self.body = data
        return self
    }
    
    func timeout(_ interval: TimeInterval) -> APIRequestBuilder {
        self.timeout = interval
        return self
    }
    
    func build() throws -> APIRequest {
        guard let url = url else {
            throw BuilderError.missingURL
        }
        
        return APIRequest(
            url: url,
            method: method,
            headers: headers,
            body: body,
            timeout: timeout
        )
    }
}

// Usage
let request = try APIRequestBuilder()
    .url(URL(string: "https://api.example.com/users")!)
    .method(.POST)
    .header("Content-Type", "application/json")
    .header("Authorization", "Bearer token")
    .body(jsonData)
    .timeout(60)
    .build()
```

### 🔧 Dependency Injection

**Purpose**: Provides dependencies from external sources rather than creating them internally.

```swift
// Container-based DI
class DIContainer {
    static let shared = DIContainer()
    
    private var services: [String: Any] = [:]
    
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        services[key] = factory
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        guard let factory = services[key] as? () -> T else {
            fatalError("Service \(key) not registered")
        }
        return factory()
    }
}

// Registration
DIContainer.shared.register(UserService.self) {
    UserServiceImpl(apiService: DIContainer.shared.resolve(APIService.self))
}

DIContainer.shared.register(APIService.self) {
    APIServiceImpl()
}

// Usage
class UserViewModel: ObservableObject {
    private let userService: UserService
    
    init(userService: UserService = DIContainer.shared.resolve(UserService.self)) {
        self.userService = userService
    }
}
```

## Structural Patterns

### 🔌 Adapter Pattern

**Purpose**: Allows incompatible interfaces to work together.

```swift
// Third-party library with different interface
class ThirdPartyImageLoader {
    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Third-party implementation
    }
}

// Our app's expected interface
protocol ImageLoader {
    func loadImage(url: URL) async -> UIImage?
}

// Adapter
class ImageLoaderAdapter: ImageLoader {
    private let thirdPartyLoader = ThirdPartyImageLoader()
    
    func loadImage(url: URL) async -> UIImage? {
        await withCheckedContinuation { continuation in
            thirdPartyLoader.downloadImage(from: url.absoluteString) { image in
                continuation.resume(returning: image)
            }
        }
    }
}
```

### 🎭 Facade Pattern

**Purpose**: Provides a simplified interface to a complex subsystem.

```swift
class MediaPlayerFacade {
    private let audioPlayer = AudioPlayer()
    private let videoPlayer = VideoPlayer()
    private let subtitleManager = SubtitleManager()
    private let networkManager = NetworkManager()
    
    func playMedia(url: URL, withSubtitles: Bool = false) async {
        // Simplified interface that coordinates multiple subsystems
        await networkManager.checkConnection()
        
        if url.pathExtension == "mp4" {
            await videoPlayer.load(url)
            videoPlayer.play()
        } else {
            await audioPlayer.load(url)
            audioPlayer.play()
        }
        
        if withSubtitles {
            await subtitleManager.loadSubtitles(for: url)
            subtitleManager.show()
        }
    }
    
    func pause() {
        audioPlayer.pause()
        videoPlayer.pause()
    }
    
    func stop() {
        audioPlayer.stop()
        videoPlayer.stop()
        subtitleManager.hide()
    }
}
```

## Behavioral Patterns

### 👀 Observer Pattern

**Purpose**: Defines a one-to-many dependency between objects.

```swift
// Using Combine
class NotificationCenter: ObservableObject {
    @Published var notifications: [Notification] = []
    
    func addNotification(_ notification: Notification) {
        notifications.append(notification)
    }
    
    func removeNotification(id: String) {
        notifications.removeAll { $0.id == id }
    }
}

// Observer
class NotificationBadgeView: ObservableObject {
    @Published var badgeCount = 0
    private var cancellables = Set<AnyCancellable>()
    
    init(notificationCenter: NotificationCenter) {
        notificationCenter.$notifications
            .map { $0.filter { !$0.isRead }.count }
            .assign(to: &$badgeCount)
    }
}
```

### 🎯 Strategy Pattern

**Purpose**: Defines a family of algorithms and makes them interchangeable.

```swift
protocol SortingStrategy {
    func sort<T: Comparable>(_ array: [T]) -> [T]
}

class QuickSortStrategy: SortingStrategy {
    func sort<T: Comparable>(_ array: [T]) -> [T] {
        // Quick sort implementation
        return array.sorted()
    }
}

class BubbleSortStrategy: SortingStrategy {
    func sort<T: Comparable>(_ array: [T]) -> [T] {
        // Bubble sort implementation
        var result = array
        // ... bubble sort logic
        return result
    }
}

class DataSorter {
    private var strategy: SortingStrategy
    
    init(strategy: SortingStrategy) {
        self.strategy = strategy
    }
    
    func setStrategy(_ strategy: SortingStrategy) {
        self.strategy = strategy
    }
    
    func sort<T: Comparable>(_ data: [T]) -> [T] {
        return strategy.sort(data)
    }
}

// Usage
let sorter = DataSorter(strategy: QuickSortStrategy())
let sortedData = sorter.sort([3, 1, 4, 1, 5, 9, 2, 6])

// Switch strategy for large datasets
sorter.setStrategy(BubbleSortStrategy())
```

### 🔗 Command Pattern

**Purpose**: Encapsulates requests as objects, allowing you to parameterize clients with different requests.

```swift
protocol Command {
    func execute()
    func undo()
}

class CreateUserCommand: Command {
    private let userService: UserService
    private let userData: UserData
    private var createdUserId: String?
    
    init(userService: UserService, userData: UserData) {
        self.userService = userService
        self.userData = userData
    }
    
    func execute() {
        createdUserId = userService.createUser(userData)
    }
    
    func undo() {
        if let userId = createdUserId {
            userService.deleteUser(userId)
        }
    }
}

class CommandManager {
    private var history: [Command] = []
    private var currentIndex = -1
    
    func execute(_ command: Command) {
        command.execute()
        
        // Remove any commands after current index
        if currentIndex < history.count - 1 {
            history.removeSubrange((currentIndex + 1)...)
        }
        
        history.append(command)
        currentIndex += 1
    }
    
    func undo() {
        guard currentIndex >= 0 else { return }
        
        history[currentIndex].undo()
        currentIndex -= 1
    }
    
    func redo() {
        guard currentIndex < history.count - 1 else { return }
        
        currentIndex += 1
        history[currentIndex].execute()
    }
}
```

## iOS-Specific Patterns

### 🧭 Coordinator Pattern

**Purpose**: Manages navigation flow and removes navigation logic from view controllers.

```swift
protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let homeView = HomeView()
        let hostingController = UIHostingController(rootView: homeView)
        navigationController.pushViewController(hostingController, animated: false)
    }
    
    func showUserProfile(userId: String) {
        let profileCoordinator = ProfileCoordinator(navigationController: navigationController)
        profileCoordinator.userId = userId
        childCoordinators.append(profileCoordinator)
        profileCoordinator.start()
    }
}
```

### 🔄 Repository Pattern

**Purpose**: Encapsulates data access logic and provides a more object-oriented view of the persistence layer.

```swift
protocol UserRepository {
    func getUser(id: String) async throws -> User
    func getUsers() async throws -> [User]
    func saveUser(_ user: User) async throws
    func deleteUser(id: String) async throws
}

class UserRepositoryImpl: UserRepository {
    private let remoteDataSource: RemoteUserDataSource
    private let localDataSource: LocalUserDataSource
    private let cachePolicy: CachePolicy
    
    init(
        remoteDataSource: RemoteUserDataSource,
        localDataSource: LocalUserDataSource,
        cachePolicy: CachePolicy = .cacheFirst
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.cachePolicy = cachePolicy
    }
    
    func getUser(id: String) async throws -> User {
        switch cachePolicy {
        case .cacheFirst:
            if let cachedUser = try? await localDataSource.getUser(id: id) {
                return cachedUser
            }
            let remoteUser = try await remoteDataSource.getUser(id: id)
            try await localDataSource.saveUser(remoteUser)
            return remoteUser
            
        case .networkFirst:
            do {
                let remoteUser = try await remoteDataSource.getUser(id: id)
                try await localDataSource.saveUser(remoteUser)
                return remoteUser
            } catch {
                return try await localDataSource.getUser(id: id)
            }
        }
    }
}
```

### 🎛️ State Management Pattern

**Purpose**: Manages application state in a predictable way.

```swift
// Redux-like pattern for SwiftUI
struct AppState {
    var user: User?
    var isLoading: Bool = false
    var error: Error?
}

enum AppAction {
    case setLoading(Bool)
    case setUser(User)
    case setError(Error?)
    case logout
}

class Store: ObservableObject {
    @Published var state = AppState()
    
    func dispatch(_ action: AppAction) {
        state = reduce(state: state, action: action)
    }
    
    private func reduce(state: AppState, action: AppAction) -> AppState {
        var newState = state
        
        switch action {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setUser(let user):
            newState.user = user
            newState.isLoading = false
            newState.error = nil
            
        case .setError(let error):
            newState.error = error
            newState.isLoading = false
            
        case .logout:
            newState.user = nil
            newState.error = nil
        }
        
        return newState
    }
}
```

## 🎯 When to Use Each Pattern

| Pattern | Use When | Benefits | Drawbacks |
|---------|----------|----------|-----------|
| **MVVM** | Building reactive UIs | Clear separation, testable | Can be overkill for simple views |
| **Clean Architecture** | Complex apps, team development | Maintainable, testable | Initial complexity |
| **Factory** | Creating related objects | Flexible object creation | Can become complex |
| **Builder** | Complex object construction | Readable, flexible | More code for simple objects |
| **Adapter** | Integrating third-party code | Maintains clean interfaces | Additional abstraction layer |
| **Observer** | Reactive programming | Loose coupling | Can lead to memory leaks |
| **Strategy** | Multiple algorithms | Easy to extend | Can be overkill |
| **Coordinator** | Complex navigation | Decoupled navigation | Additional complexity |
| **Repository** | Data access abstraction | Testable, flexible | Abstraction overhead |

## 📚 Best Practices

1. **Start Simple**: Don't over-engineer. Use patterns when they solve real problems.
2. **Consistency**: Stick to chosen patterns throughout the project.
3. **Documentation**: Document pattern usage and decisions.
4. **Testing**: Ensure patterns improve testability.
5. **Team Agreement**: Make sure the team understands chosen patterns.

---

**Remember**: Patterns are tools to solve problems, not goals in themselves. Choose the right pattern for your specific use case! 🛠️