# Movy App - Simplified Project Structure 🎬

A more practical and manageable project structure that maintains Clean Architecture principles without overwhelming complexity.

## 📁 Simplified Directory Structure

```
CH-4/
├── Project.swift                          # Tuist project configuration
├── Tuist.swift                           # Tuist workspace configuration
├── Tuist/
│   └── Package.swift                     # External dependencies
├── .gitignore
│
├── Sources/                              # 📱 Main Application Code
│   ├── App/                             # App entry point
│   │   ├── CH4App.swift
│   │   └── ContentView.swift
│   │
│   ├── Features/                        # 🎯 Feature Modules 
│   │   ├── Home/
│   │   │   ├── Presentation/
│   │   │   │   ├── HomeView.swift
│   │   │   │   ├── HomeViewModel.swift
│   │   │   │   └── Components/
│   │   │   │       ├── MovieCard.swift
│   │   │   │       └── SearchBar.swift
│   │   │   ├── Domain/
│   │   │   │   ├── Models/
│   │   │   │   │   └── Movie.swift
│   │   │   │   ├── UseCases/
│   │   │   │   │   └── SearchMoviesUseCase.swift
│   │   │   │   └── Repositories/
│   │   │   │       └── MovieRepositoryProtocol.swift
│   │   │   └── Data/
│   │   │       ├── Repository/
│   │   │       │   └── MovieRepository.swift
│   │   │       ├── DataSources/
│   │   │       │   └── MovieAPIDataSource.swift
│   │   │       └── Models/
│   │   │           └── MovieResponse.swift
│   │   │
│   │   └── MovieDetail/
│   │       ├── Presentation/
│   │       │   ├── MovieDetailView.swift
│   │       │   └── MovieDetailViewModel.swift
│   │       ├── Domain/
│   │       │   ├── Models/
│   │       │   │   └── MovieDetail.swift
│   │       │   └── UseCases/
│   │       │       └── GetMovieDetailUseCase.swift
│   │       └── Data/
│   │           ├── Repository/
│   │           │   └── MovieDetailRepository.swift
│   │           └── Models/
│   │               └── MovieDetailResponse.swift
│   │
│   ├── Shared/                          # 🔧 Shared Components
│   │   ├── Networking/
│   │   │   ├── NetworkManager.swift
│   │   │   ├── APIEndpoint.swift
│   │   │   └── NetworkError.swift
│   │   ├── UI/
│   │   │   ├── Components/
│   │   │   │   ├── LoadingView.swift
│   │   │   │   ├── ErrorView.swift
│   │   │   │   └── AsyncImageView.swift
│   │   │   ├── Extensions/
│   │   │   │   ├── View+Extensions.swift
│   │   │   │   └── Color+Extensions.swift
│   │   │   └── Theme/
│   │   │       ├── AppTheme.swift
│   │   │       └── Colors.swift
│   │   ├── Utils/
│   │   │   ├── Logger.swift
│   │   │   └── Constants.swift
│   │   └── DependencyInjection/
│   │       └── DIContainer.swift
│   │
│   └── Resources/                       # 📦 App Resources
│       ├── Assets.xcassets/
│       ├── Info.plist
│       └── Preview Content/
│
├── Tests/                               # 🧪 Test Files
│   ├── Features/
│   │   ├── Home/
│   │   │   ├── HomeViewModelTests.swift
│   │   │   └── SearchMoviesUseCaseTests.swift
│   │   └── MovieDetail/
│   │       └── MovieDetailViewModelTests.swift
│   ├── Shared/
│   │   ├── NetworkManagerTests.swift
│   │   └── DIContainerTests.swift
│   └── Mocks/
│       ├── MockMovieRepository.swift
│       └── MockNetworkManager.swift
│
└── docs/                               # 📚 Documentation
    └── architecture/
        ├── CLEAN_ARCHITECTURE_MVVM_REVISED.md
        └── SIMPLIFIED_PROJECT_STRUCTURE.md
```

## 🎯 Key Simplifications

### 1. **Single Module Approach**
- All code lives in one main module
- No complex inter-module dependencies
- Easier to navigate and understand

### 2. **Feature Folders Instead of Modules**
- Features are organized as folders, not separate modules
- Maintains separation without Tuist complexity
- Faster build times

### 3. **Consolidated Shared Code**
- One `Shared` folder for all common functionality
- Networking, UI components, and utilities in one place
- Simple dependency injection container

### 4. **Minimal Layer Structure**
```
Presentation (Views + ViewModels)
    ↓
Domain (Models + UseCases + Repository Protocols)
    ↓
Data (Repository Implementations + DataSources + Response Models)
```

## 🔄 Simplified Data Flow

```
1. HomeView → HomeViewModel.searchMovies()
2. HomeViewModel → SearchMoviesUseCase.execute()
3. UseCase → MovieRepository.searchMovies()
4. Repository → MovieAPIDataSource.searchMovies()
5. DataSource → NetworkManager.request()
6. Response flows back through the same chain
7. UI updates with new data
```

## 📦 Core Components

### Movie Model (Domain)
```swift
// Sources/Features/Home/Domain/Models/Movie.swift
struct Movie {
    let id: String
    let title: String
    let year: String
    let posterURL: URL?
    let type: MovieType
    
    enum MovieType: String {
        case movie, series, episode
    }
}
```

### Search Use Case
```swift
// Sources/Features/Home/Domain/UseCases/SearchMoviesUseCase.swift
protocol SearchMoviesUseCaseProtocol {
    func execute(query: String) async -> Result<[Movie], Error>
}

class SearchMoviesUseCase: SearchMoviesUseCaseProtocol {
    private let repository: MovieRepositoryProtocol
    
    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(query: String) async -> Result<[Movie], Error> {
        guard !query.isEmpty else {
            return .failure(SearchError.emptyQuery)
        }
        
        return await repository.searchMovies(query: query)
    }
}
```

### Simple Repository
```swift
// Sources/Features/Home/Data/Repository/MovieRepository.swift
class MovieRepository: MovieRepositoryProtocol {
    private let dataSource: MovieAPIDataSource
    
    init(dataSource: MovieAPIDataSource) {
        self.dataSource = dataSource
    }
    
    func searchMovies(query: String) async -> Result<[Movie], Error> {
        do {
            let response = try await dataSource.searchMovies(query: query)
            let movies = response.search.map { $0.toDomain() }
            return .success(movies)
        } catch {
            return .failure(error)
        }
    }
}
```

### Basic ViewModel
```swift
// Sources/Features/Home/Presentation/HomeViewModel.swift
@MainActor
class HomeViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let searchUseCase: SearchMoviesUseCaseProtocol
    
    init(searchUseCase: SearchMoviesUseCaseProtocol) {
        self.searchUseCase = searchUseCase
    }
    
    func searchMovies(query: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            let result = await searchUseCase.execute(query: query)
            
            switch result {
            case .success(let movies):
                self.movies = movies
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
            
            self.isLoading = false
        }
    }
}
```

## 🧪 Simple Testing Strategy

### Unit Tests
- **ViewModels**: Test state management and user interactions
- **UseCases**: Test business logic
- **Repositories**: Test data transformation

### Mock Objects
```swift
// Tests/Mocks/MockMovieRepository.swift
class MockMovieRepository: MovieRepositoryProtocol {
    var searchResult: Result<[Movie], Error> = .success([])
    
    func searchMovies(query: String) async -> Result<[Movie], Error> {
        return searchResult
    }
}
```

## 🚀 Benefits of Simplified Structure

1. **Easy to Understand**: Clear folder structure, minimal complexity
2. **Fast Setup**: No complex module configuration
3. **Quick Development**: Less boilerplate, faster iteration
4. **Maintainable**: Still follows Clean Architecture principles
5. **Testable**: Clear separation allows for easy testing
6. **Scalable**: Can evolve into more complex structure when needed

## 📈 When to Add Complexity

Consider the more complex modular structure when:
- Team grows beyond 3-4 developers
- App has 5+ major features
- Build times become problematic
- Need feature-specific deployment
- Require strict module boundaries

## 🎯 Getting Started

1. **Start with this simplified structure**
2. **Implement core features** (Home, Movie Detail)
3. **Add shared components** as needed
4. **Write tests** for critical paths
5. **Refactor to modular** when complexity justifies it

This structure provides a solid foundation while keeping things manageable for a small team or solo developer. You can always evolve it into the more complex modular structure as your app and team grow.