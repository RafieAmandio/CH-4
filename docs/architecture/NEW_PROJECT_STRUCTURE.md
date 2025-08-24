# Movy App - New Project Structure 🏗️

This document outlines the new modular project structure based on the revised Clean Architecture + MVVM approach.

## 📁 Complete Directory Structure

```
CH-4/
├── Project.swift                          # Tuist project configuration
├── Tuist.swift                           # Tuist workspace configuration
├── Tuist/
│   └── Package.swift                     # External dependencies
├── mise.toml                             # Development environment setup
├── .gitignore
│
├── Features/                             # 🎯 Feature Modules
│   ├── Home/                            # Home feature module
│   │   ├── Project.swift                # Feature-specific Tuist config
│   │   ├── Sources/
│   │   │   ├── Presentation/           # 🎨 UI Layer
│   │   │   │   ├── ViewModels/
│   │   │   │   │   └── HomeViewModel.swift
│   │   │   │   ├── Views/
│   │   │   │   │   ├── HomeView.swift
│   │   │   │   │   └── Components/
│   │   │   │   │       ├── MovieCard.swift
│   │   │   │   │       └── SearchBar.swift
│   │   │   │   └── Navigation/
│   │   │   │       └── HomeCoordinator.swift
│   │   │   ├── Domain/                 # 🧠 Business Logic Layer
│   │   │   │   ├── Models/
│   │   │   │   │   ├── MovieModel.swift
│   │   │   │   │   └── SearchResultModel.swift
│   │   │   │   ├── UseCases/
│   │   │   │   │   ├── SearchMoviesUseCase.swift
│   │   │   │   │   └── GetPopularMoviesUseCase.swift
│   │   │   │   └── Protocols/
│   │   │   │       └── HomeRepositoryProtocol.swift
│   │   │   └── Data/                   # 💾 Data Layer
│   │   │       ├── Repositories/
│   │   │       │   └── HomeRepository.swift
│   │   │       ├── DataSources/
│   │   │       │   ├── Remote/
│   │   │       │   │   ├── HomeRemoteDataSource.swift
│   │   │       │   │   └── HomeRemoteDataSourceProtocol.swift
│   │   │       │   └── Local/
│   │   │       │       ├── HomeLocalDataSource.swift
│   │   │       │       └── HomeLocalDataSourceProtocol.swift
│   │   │       ├── Responses/
│   │   │       │   ├── MovieSearchResponse.swift
│   │   │       │   └── PopularMoviesResponse.swift
│   │   │       └── Mappers/
│   │   │           └── MovieMapper.swift
│   │   └── Tests/
│   │       ├── Presentation/
│   │       │   └── HomeViewModelTests.swift
│   │       ├── Domain/
│   │       │   └── SearchMoviesUseCaseTests.swift
│   │       └── Data/
│   │           └── HomeRepositoryTests.swift
│   │
│   ├── Movie/                           # Movie detail feature module
│   │   ├── Project.swift
│   │   ├── Sources/
│   │   │   ├── Presentation/
│   │   │   │   ├── ViewModels/
│   │   │   │   │   └── MovieDetailViewModel.swift
│   │   │   │   ├── Views/
│   │   │   │   │   ├── MovieDetailView.swift
│   │   │   │   │   └── Components/
│   │   │   │   │       ├── MoviePoster.swift
│   │   │   │   │       ├── MovieInfo.swift
│   │   │   │   │       └── RatingView.swift
│   │   │   │   └── Navigation/
│   │   │   │       └── MovieCoordinator.swift
│   │   │   ├── Domain/
│   │   │   │   ├── Models/
│   │   │   │   │   └── MovieDetailModel.swift
│   │   │   │   ├── UseCases/
│   │   │   │   │   ├── GetMovieDetailUseCase.swift
│   │   │   │   │   └── AddToFavoritesUseCase.swift
│   │   │   │   └── Protocols/
│   │   │   │       └── MovieRepositoryProtocol.swift
│   │   │   └── Data/
│   │   │       ├── Repositories/
│   │   │       │   └── MovieRepository.swift
│   │   │       ├── DataSources/
│   │   │       │   ├── Remote/
│   │   │       │   │   ├── MovieRemoteDataSource.swift
│   │   │       │   │   └── MovieRemoteDataSourceProtocol.swift
│   │   │       │   └── Local/
│   │   │       │       ├── MovieLocalDataSource.swift
│   │   │       │       └── MovieLocalDataSourceProtocol.swift
│   │   │       ├── Responses/
│   │   │       │   └── MovieDetailResponse.swift
│   │   │       └── Mappers/
│   │   │           └── MovieDetailMapper.swift
│   │   └── Tests/
│   │       ├── Presentation/
│   │       ├── Domain/
│   │       └── Data/
│   │
│   └── Favorites/                       # Favorites feature module
│       ├── Project.swift
│       ├── Sources/
│       │   ├── Presentation/
│       │   ├── Domain/
│       │   └── Data/
│       └── Tests/
│
├── Infrastructure/                      # 🔧 Shared Infrastructure
│   ├── Networking/                     # Network layer
│   │   ├── Project.swift
│   │   ├── Sources/
│   │   │   ├── Core/
│   │   │   │   ├── NetworkManager.swift
│   │   │   │   ├── APIEndpoint.swift
│   │   │   │   ├── NetworkError.swift
│   │   │   │   └── HTTPMethod.swift
│   │   │   ├── Services/
│   │   │   │   ├── OMDBService.swift
│   │   │   │   └── ImageService.swift
│   │   │   ├── Interceptors/
│   │   │   │   ├── AuthInterceptor.swift
│   │   │   │   └── LoggingInterceptor.swift
│   │   │   └── Utils/
│   │   │       ├── URLSessionExtensions.swift
│   │   │       └── NetworkReachability.swift
│   │   └── Tests/
│   │       ├── NetworkManagerTests.swift
│   │       └── OMDBServiceTests.swift
│   │
│   ├── CommonUI/                       # Shared UI components
│   │   ├── Project.swift
│   │   ├── Sources/
│   │   │   ├── Components/
│   │   │   │   ├── LoadingView.swift
│   │   │   │   ├── ErrorView.swift
│   │   │   │   ├── EmptyStateView.swift
│   │   │   │   └── AsyncImageView.swift
│   │   │   ├── Extensions/
│   │   │   │   ├── View+Extensions.swift
│   │   │   │   ├── Color+Extensions.swift
│   │   │   │   └── Font+Extensions.swift
│   │   │   ├── Modifiers/
│   │   │   │   ├── CardModifier.swift
│   │   │   │   └── ShimmerModifier.swift
│   │   │   └── Theme/
│   │   │       ├── AppTheme.swift
│   │   │       ├── Colors.swift
│   │   │       └── Typography.swift
│   │   └── Tests/
│   │       └── ComponentTests.swift
│   │
│   ├── Core/                          # Core utilities
│   │   ├── Project.swift
│   │   ├── Sources/
│   │   │   ├── DependencyInjection/
│   │   │   │   ├── DependencyContainer.swift
│   │   │   │   ├── FeatureAssembly.swift
│   │   │   │   └── ServiceLocator.swift
│   │   │   ├── Storage/
│   │   │   │   ├── UserDefaults+Extensions.swift
│   │   │   │   ├── KeychainManager.swift
│   │   │   │   └── CoreDataManager.swift
│   │   │   ├── Utils/
│   │   │   │   ├── Logger.swift
│   │   │   │   ├── DateFormatter+Extensions.swift
│   │   │   │   └── String+Extensions.swift
│   │   │   └── Constants/
│   │   │       ├── AppConstants.swift
│   │   │       └── APIConstants.swift
│   │   └── Tests/
│   │       ├── DependencyContainerTests.swift
│   │       └── UtilsTests.swift
│   │
│   └── Database/                       # Local database
│       ├── Project.swift
│       ├── Sources/
│       │   ├── CoreData/
│       │   │   ├── MovyDataModel.xcdatamodeld
│       │   │   ├── CoreDataStack.swift
│       │   │   └── ManagedObjectExtensions.swift
│       │   ├── Entities/
│       │   │   ├── MovieEntity+CoreDataClass.swift
│       │   │   └── FavoriteEntity+CoreDataClass.swift
│       │   └── Repositories/
│       │       └── LocalStorageRepository.swift
│       └── Tests/
│           └── DatabaseTests.swift
│
├── App/                                # 📱 Main Application
│   ├── Project.swift
│   ├── Sources/
│   │   ├── CH4App.swift               # App entry point
│   │   ├── ContentView.swift          # Root view
│   │   ├── AppCoordinator.swift       # Main navigation coordinator
│   │   └── Configuration/
│   │       ├── AppConfiguration.swift
│   │       └── Environment.swift
│   ├── Resources/
│   │   ├── Assets.xcassets/
│   │   │   ├── AppIcon.appiconset/
│   │   │   ├── Colors/
│   │   │   └── Images/
│   │   ├── Info.plist
│   │   └── Preview Content/
│   │       └── Preview Assets.xcassets/
│   └── Tests/
│       └── AppTests.swift
│
├── docs/                              # 📚 Documentation
│   ├── README.md
│   ├── architecture/
│   │   ├── CLEAN_ARCHITECTURE_MVVM.md
│   │   ├── CLEAN_ARCHITECTURE_MVVM_REVISED.md
│   │   ├── NEW_PROJECT_STRUCTURE.md
│   │   └── DESIGN_PATTERNS.md
│   ├── guidelines/
│   │   ├── CODING_STANDARDS.md
│   │   ├── GIT_WORKFLOW.md
│   │   └── TESTING_STRATEGY.md
│   └── setup/
│       ├── CI_CD_SETUP.md
│       ├── ENVIRONMENT_SETUP.md
│       └── PROJECT_SETUP.md
│
└── Scripts/                           # 🔧 Build & Automation Scripts
    ├── generate_project.sh
    ├── run_tests.sh
    ├── lint.sh
    └── setup_environment.sh
```

## 🎯 Key Structure Principles

### 1. **Feature-Based Modularization**
- Each feature is a separate module with its own `Project.swift`
- Features can be developed, tested, and deployed independently
- Clear boundaries between features prevent tight coupling

### 2. **Vertical Slice Architecture**
- Each feature contains all layers: Presentation → Domain → Data
- Business logic stays within feature boundaries
- Shared functionality lives in Infrastructure modules

### 3. **Infrastructure Separation**
- **Networking**: HTTP client, API services, network utilities
- **CommonUI**: Reusable UI components and design system
- **Core**: Dependency injection, utilities, constants
- **Database**: Local storage and Core Data management

### 4. **Clear Layer Boundaries**
```
Presentation Layer (UI)
    ↓ (ViewModels call UseCases)
Domain Layer (Business Logic)
    ↓ (UseCases call Repository protocols)
Data Layer (Data Access)
    ↓ (Repositories use DataSources)
Infrastructure Layer (External concerns)
```

### 5. **Dependency Direction**
- **Presentation** depends on **Domain**
- **Data** depends on **Domain** (through protocols)
- **Domain** depends on nothing (pure business logic)
- **Infrastructure** provides implementations

## 📦 Module Dependencies

### Feature Modules
```swift
// Home feature dependencies
Home → Domain (HomeRepositoryProtocol)
Home → Infrastructure.Networking (API calls)
Home → Infrastructure.CommonUI (UI components)
Home → Infrastructure.Core (DI, utilities)
```

### Infrastructure Modules
```swift
// Infrastructure dependencies
Networking → Core (utilities, constants)
CommonUI → Core (theme, extensions)
Database → Core (utilities)
```

### App Module
```swift
// Main app dependencies
App → All Features (Home, Movie, Favorites)
App → Infrastructure.Core (DI container)
App → Infrastructure.CommonUI (root UI)
```

## 🔄 Data Flow Example

```
1. User taps search → HomeView
2. HomeView calls → HomeViewModel.searchMovies()
3. HomeViewModel calls → SearchMoviesUseCase.execute()
4. UseCase calls → HomeRepository.searchMovies()
5. Repository calls → HomeRemoteDataSource.searchMovies()
6. DataSource calls → OMDBService.searchMovies()
7. Service makes → HTTP request to OMDB API
8. Response flows back through the same chain
9. DataSource transforms → Response to Domain Model
10. UI updates with → new movie list
```

## 🧪 Testing Strategy

### Unit Tests
- **ViewModels**: Test UI state management
- **UseCases**: Test business logic
- **Repositories**: Test data coordination
- **DataSources**: Test API integration

### Integration Tests
- **Feature modules**: Test complete user flows
- **Infrastructure**: Test cross-module communication

### UI Tests
- **App module**: Test end-to-end user journeys

## 🚀 Benefits of This Structure

1. **Scalability**: Easy to add new features without affecting existing ones
2. **Maintainability**: Clear separation of concerns and responsibilities
3. **Testability**: Each layer can be tested in isolation
4. **Team Collaboration**: Multiple developers can work on different features
5. **Code Reusability**: Shared infrastructure components
6. **Build Performance**: Incremental compilation of changed modules only
7. **Deployment Flexibility**: Features can be feature-flagged or deployed separately

## 📋 Migration Steps

1. **Create Infrastructure modules** (Networking, CommonUI, Core, Database)
2. **Move shared code** to appropriate infrastructure modules
3. **Create feature modules** (Home, Movie, Favorites)
4. **Migrate existing code** to feature-specific modules
5. **Update dependencies** in Tuist project files
6. **Update import statements** throughout the codebase
7. **Run tests** to ensure everything works correctly

This structure provides a solid foundation for building a scalable, maintainable iOS application using Clean Architecture principles with MVVM pattern.