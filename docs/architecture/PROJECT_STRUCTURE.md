# iOS Project Structure Guide 📁

A comprehensive guide for organizing iOS projects using Clean Architecture principles with practical examples and best practices.

## 📋 Table of Contents

1. [Overview](#overview)
2. [Folder Structure](#folder-structure)
3. [Layer Organization](#layer-organization)
4. [File Naming Conventions](#file-naming-conventions)
5. [Module Organization](#module-organization)
6. [Testing Structure](#testing-structure)
7. [Resource Organization](#resource-organization)
8. [Configuration Files](#configuration-files)

## Overview

A well-organized project structure is crucial for:
- **Maintainability**: Easy to find and modify code
- **Scalability**: Simple to add new features
- **Team Collaboration**: Clear conventions for all developers
- **Testing**: Logical separation for unit and integration tests
- **Build Performance**: Efficient compilation and linking

## Folder Structure

### 🏗️ Recommended Project Structure

```
YourApp/
├── 📁 YourApp/                          # Main app target
│   ├── 📁 Resources/                    # App resources
│   │   ├── 📁 Assets.xcassets/         # Images, colors, etc.
│   │   ├── 📁 Fonts/                   # Custom fonts
│   │   ├── 📁 Localization/            # String files
│   │   └── 📁 Preview Content/         # SwiftUI preview assets
│   │
│   ├── 📁 Sources/                      # Source code
│   │   ├── 📄 YourApp.swift            # App entry point
│   │   ├── 📄 RootView.swift           # Root view
│   │   │
│   │   ├── 📁 Core/                    # Infrastructure layer
│   │   │   ├── 📁 DependencyInjection/ # DI container
│   │   │   ├── 📁 Networking/          # Network layer
│   │   │   ├── 📁 Storage/             # Local storage
│   │   │   ├── 📁 Navigation/          # App navigation
│   │   │   ├── 📁 Extensions/          # Swift extensions
│   │   │   └── 📁 Utilities/           # Helper utilities
│   │   │
│   │   ├── 📁 Domain/                  # Business logic layer
│   │   │   ├── 📁 Entities/            # Business models
│   │   │   ├── 📁 UseCases/            # Business logic
│   │   │   ├── 📁 Repositories/        # Repository protocols
│   │   │   └── 📁 Services/            # Domain services
│   │   │
│   │   ├── 📁 Data/                    # Data access layer
│   │   │   ├── 📁 DTOs/                # Data transfer objects
│   │   │   ├── 📁 DataSources/         # Data sources
│   │   │   │   ├── 📁 Remote/          # API services
│   │   │   │   └── 📁 Local/           # Local storage
│   │   │   ├── 📁 Repositories/        # Repository implementations
│   │   │   └── 📁 Mappers/             # DTO to Entity mappers
│   │   │
│   │   └── 📁 Presentation/            # UI layer
│   │       ├── 📁 Common/              # Shared UI components
│   │       │   ├── 📁 Components/      # Reusable components
│   │       │   ├── 📁 Modifiers/       # SwiftUI modifiers
│   │       │   ├── 📁 Styles/          # UI styles
│   │       │   └── 📁 Extensions/      # UI extensions
│   │       │
│   │       └── 📁 Features/            # Feature modules
│   │           ├── 📁 Authentication/  # Auth feature
│   │           ├── 📁 Home/            # Home feature
│   │           ├── 📁 Profile/         # Profile feature
│   │           └── 📁 Settings/        # Settings feature
│   │
│   └── 📁 Configuration/                # App configuration
│       ├── 📄 Info.plist               # App info
│       ├── 📄 Config.xcconfig          # Build configuration
│       └── 📄 Entitlements.plist       # App entitlements
│
├── 📁 YourAppTests/                     # Unit tests
│   ├── 📁 Domain/                      # Domain layer tests
│   ├── 📁 Data/                        # Data layer tests
│   ├── 📁 Presentation/                # Presentation tests
│   ├── 📁 Mocks/                       # Mock objects
│   └── 📁 Helpers/                     # Test helpers
│
├── 📁 YourAppUITests/                   # UI tests
│   ├── 📁 Screens/                     # Screen objects
│   ├── 📁 Flows/                       # User flow tests
│   └── 📁 Helpers/                     # UI test helpers
│
├── 📁 docs/                            # Documentation
│   ├── 📁 architecture/               # Architecture guides
│   ├── 📁 guidelines/                 # Development guidelines
│   └── 📁 setup/                      # Setup instructions
│
├── 📁 scripts/                         # Build scripts
│   ├── 📄 build.sh                    # Build script
│   ├── 📄 test.sh                     # Test script
│   └── 📄 lint.sh                     # Linting script
│
├── 📄 Package.swift                    # Swift Package Manager
├── 📄 Project.swift                    # Tuist project (if using)
├── 📄 .gitignore                       # Git ignore rules
├── 📄 README.md                        # Project documentation
└── 📄 CHANGELOG.md                     # Version history
```

## Layer Organization

### 🎨 Presentation Layer Structure

```
Presentation/
├── Common/
│   ├── Components/
│   │   ├── Buttons/
│   │   │   ├── PrimaryButton.swift
│   │   │   ├── SecondaryButton.swift
│   │   │   └── IconButton.swift
│   │   ├── Forms/
│   │   │   ├── CustomTextField.swift
│   │   │   ├── CustomSecureField.swift
│   │   │   └── FormValidator.swift
│   │   ├── Loading/
│   │   │   ├── LoadingView.swift
│   │   │   ├── SkeletonView.swift
│   │   │   └── ProgressIndicator.swift
│   │   └── Navigation/
│   │       ├── CustomNavigationBar.swift
│   │       ├── TabBarView.swift
│   │       └── BackButton.swift
│   │
│   ├── Modifiers/
│   │   ├── CardModifier.swift
│   │   ├── ShadowModifier.swift
│   │   └── ShimmerModifier.swift
│   │
│   ├── Styles/
│   │   ├── ButtonStyles.swift
│   │   ├── TextStyles.swift
│   │   └── ColorScheme.swift
│   │
│   └── Extensions/
│       ├── View+Extensions.swift
│       ├── Color+Extensions.swift
│       └── Font+Extensions.swift
│
└── Features/
    ├── Authentication/
    │   ├── Views/
    │   │   ├── LoginView.swift
    │   │   ├── SignUpView.swift
    │   │   └── ForgotPasswordView.swift
    │   ├── ViewModels/
    │   │   ├── LoginViewModel.swift
    │   │   ├── SignUpViewModel.swift
    │   │   └── AuthenticationViewModel.swift
    │   └── Components/
    │       ├── SocialLoginButton.swift
    │       └── AuthFormField.swift
    │
    └── Home/
        ├── Views/
        │   ├── HomeView.swift
        │   ├── HomeTabView.swift
        │   └── HomeDetailView.swift
        ├── ViewModels/
        │   ├── HomeViewModel.swift
        │   └── HomeDetailViewModel.swift
        └── Components/
            ├── HomeCard.swift
            ├── HomeHeader.swift
            └── HomeSearchBar.swift
```

### 🏢 Domain Layer Structure

```
Domain/
├── Entities/
│   ├── User/
│   │   ├── User.swift
│   │   ├── UserProfile.swift
│   │   └── UserPreferences.swift
│   ├── Product/
│   │   ├── Product.swift
│   │   ├── ProductCategory.swift
│   │   └── ProductReview.swift
│   └── Common/
│       ├── Result.swift
│       ├── PaginatedResponse.swift
│       └── ErrorTypes.swift
│
├── UseCases/
│   ├── User/
│   │   ├── GetUserUseCase.swift
│   │   ├── UpdateUserUseCase.swift
│   │   └── DeleteUserUseCase.swift
│   ├── Product/
│   │   ├── GetProductsUseCase.swift
│   │   ├── SearchProductsUseCase.swift
│   │   └── GetProductDetailsUseCase.swift
│   └── Authentication/
│       ├── LoginUseCase.swift
│       ├── LogoutUseCase.swift
│       └── RefreshTokenUseCase.swift
│
├── Repositories/
│   ├── UserRepository.swift
│   ├── ProductRepository.swift
│   ├── AuthenticationRepository.swift
│   └── ConfigurationRepository.swift
│
└── Services/
    ├── ValidationService.swift
    ├── EncryptionService.swift
    └── NotificationService.swift
```

### 💾 Data Layer Structure

```
Data/
├── DTOs/
│   ├── User/
│   │   ├── UserDTO.swift
│   │   ├── UserProfileDTO.swift
│   │   └── UserPreferencesDTO.swift
│   ├── Product/
│   │   ├── ProductDTO.swift
│   │   ├── ProductListDTO.swift
│   │   └── ProductDetailsDTO.swift
│   └── Common/
│       ├── ResponseDTO.swift
│       ├── ErrorDTO.swift
│       └── PaginationDTO.swift
│
├── DataSources/
│   ├── Remote/
│   │   ├── API/
│   │   │   ├── APIService.swift
│   │   │   ├── APIEndpoints.swift
│   │   │   └── APIConfiguration.swift
│   │   ├── Services/
│   │   │   ├── UserAPIService.swift
│   │   │   ├── ProductAPIService.swift
│   │   │   └── AuthAPIService.swift
│   │   └── WebSocket/
│   │       ├── WebSocketManager.swift
│   │       └── WebSocketService.swift
│   │
│   └── Local/
│       ├── CoreData/
│       │   ├── CoreDataStack.swift
│       │   ├── CoreDataService.swift
│       │   └── Models/
│       │       ├── UserEntity+CoreDataClass.swift
│       │       └── ProductEntity+CoreDataClass.swift
│       ├── UserDefaults/
│       │   ├── UserDefaultsService.swift
│       │   └── UserDefaultsKeys.swift
│       └── Keychain/
│           ├── KeychainService.swift
│           └── KeychainKeys.swift
│
├── Repositories/
│   ├── UserRepositoryImpl.swift
│   ├── ProductRepositoryImpl.swift
│   ├── AuthRepositoryImpl.swift
│   └── ConfigRepositoryImpl.swift
│
└── Mappers/
    ├── UserMapper.swift
    ├── ProductMapper.swift
    └── ErrorMapper.swift
```

### ⚙️ Core Layer Structure

```
Core/
├── DependencyInjection/
│   ├── DIContainer.swift
│   ├── ServiceLocator.swift
│   └── Assemblies/
│       ├── DataAssembly.swift
│       ├── DomainAssembly.swift
│       └── PresentationAssembly.swift
│
├── Networking/
│   ├── NetworkManager.swift
│   ├── NetworkMonitor.swift
│   ├── RequestBuilder.swift
│   ├── ResponseHandler.swift
│   └── Interceptors/
│       ├── AuthInterceptor.swift
│       ├── LoggingInterceptor.swift
│       └── RetryInterceptor.swift
│
├── Storage/
│   ├── StorageManager.swift
│   ├── CacheManager.swift
│   ├── FileManager+Extensions.swift
│   └── ImageCache/
│       ├── ImageCacheManager.swift
│       └── ImageCachePolicy.swift
│
├── Navigation/
│   ├── Router.swift
│   ├── Coordinator.swift
│   ├── NavigationState.swift
│   └── DeepLinkHandler.swift
│
├── Extensions/
│   ├── Foundation/
│   │   ├── String+Extensions.swift
│   │   ├── Date+Extensions.swift
│   │   └── URL+Extensions.swift
│   ├── UIKit/
│   │   ├── UIColor+Extensions.swift
│   │   ├── UIImage+Extensions.swift
│   │   └── UIDevice+Extensions.swift
│   └── SwiftUI/
│       ├── View+Extensions.swift
│       ├── Binding+Extensions.swift
│       └── EnvironmentValues+Extensions.swift
│
└── Utilities/
    ├── Logger.swift
    ├── DateFormatter+Shared.swift
    ├── NumberFormatter+Shared.swift
    ├── Validator.swift
    └── Constants/
        ├── AppConstants.swift
        ├── APIConstants.swift
        └── UIConstants.swift
```

## File Naming Conventions

### 📝 General Rules

1. **PascalCase** for types (classes, structs, enums, protocols)
2. **camelCase** for variables, functions, and properties
3. **Descriptive names** that clearly indicate purpose
4. **Consistent suffixes** for different types of files

### 🏷️ File Naming Patterns

| File Type | Pattern | Example |
|-----------|---------|----------|
| **Views** | `[Feature][Purpose]View` | `UserProfileView.swift` |
| **ViewModels** | `[Feature][Purpose]ViewModel` | `UserProfileViewModel.swift` |
| **Entities** | `[Name]Entity` or just `[Name]` | `User.swift`, `ProductEntity.swift` |
| **DTOs** | `[Name]DTO` | `UserDTO.swift` |
| **Use Cases** | `[Action][Entity]UseCase` | `GetUserUseCase.swift` |
| **Repositories** | `[Entity]Repository` | `UserRepository.swift` |
| **Services** | `[Purpose]Service` | `NetworkService.swift` |
| **Extensions** | `[Type]+[Purpose]` | `String+Validation.swift` |
| **Protocols** | `[Name]Protocol` or `[Name]able` | `Cacheable.swift` |
| **Enums** | `[Name]` | `NetworkError.swift` |
| **Constants** | `[Context]Constants` | `APIConstants.swift` |

### 📁 Folder Naming

- Use **PascalCase** for feature folders
- Use **lowercase** for technical folders
- Group related files together
- Keep folder depth reasonable (max 4-5 levels)

## Module Organization

### 🧩 Feature-Based Modules

Organize code by features rather than by file types:

```
✅ Good: Feature-based
Features/
├── Authentication/
│   ├── Views/
│   ├── ViewModels/
│   ├── Models/
│   └── Services/
└── UserProfile/
    ├── Views/
    ├── ViewModels/
    ├── Models/
    └── Services/

❌ Avoid: Type-based
Views/
├── AuthenticationViews/
└── UserProfileViews/
ViewModels/
├── AuthenticationViewModels/
└── UserProfileViewModels/
```

### 🔗 Module Dependencies

```swift
// Clear dependency direction
Presentation → Domain ← Data
     ↓           ↑        ↑
   Core ←────────┴────────┘

// Example: Feature module structure
Authentication/
├── Domain/
│   ├── AuthEntity.swift
│   └── AuthUseCase.swift
├── Data/
│   ├── AuthDTO.swift
│   └── AuthRepository.swift
└── Presentation/
    ├── LoginView.swift
    └── LoginViewModel.swift
```

## Testing Structure

### 🧪 Test Organization

```
Tests/
├── UnitTests/
│   ├── Domain/
│   │   ├── UseCases/
│   │   │   ├── GetUserUseCaseTests.swift
│   │   │   └── LoginUseCaseTests.swift
│   │   └── Entities/
│   │       └── UserTests.swift
│   ├── Data/
│   │   ├── Repositories/
│   │   │   └── UserRepositoryTests.swift
│   │   └── DataSources/
│   │       └── APIServiceTests.swift
│   ├── Presentation/
│   │   └── ViewModels/
│   │       ├── LoginViewModelTests.swift
│   │       └── HomeViewModelTests.swift
│   └── Core/
│       ├── Networking/
│       │   └── NetworkManagerTests.swift
│       └── Utilities/
│           └── ValidatorTests.swift
│
├── IntegrationTests/
│   ├── API/
│   │   └── UserAPIIntegrationTests.swift
│   └── Database/
│       └── CoreDataIntegrationTests.swift
│
├── UITests/
│   ├── Flows/
│   │   ├── LoginFlowTests.swift
│   │   └── OnboardingFlowTests.swift
│   └── Screens/
│       ├── LoginScreenTests.swift
│       └── HomeScreenTests.swift
│
├── Mocks/
│   ├── Domain/
│   │   ├── MockUserRepository.swift
│   │   └── MockAuthService.swift
│   ├── Data/
│   │   └── MockAPIService.swift
│   └── Presentation/
│       └── MockViewModel.swift
│
└── Helpers/
    ├── TestHelpers.swift
    ├── MockData.swift
    └── XCTestCase+Extensions.swift
```

### 🎯 Test Naming Conventions

```swift
// Pattern: test_[methodName]_[scenario]_[expectedResult]
func test_login_withValidCredentials_shouldReturnSuccess() { }
func test_login_withInvalidCredentials_shouldReturnError() { }
func test_getUserProfile_whenUserExists_shouldReturnUser() { }
func test_getUserProfile_whenUserNotFound_shouldReturnNotFoundError() { }
```

## Resource Organization

### 🎨 Assets Structure

```
Assets.xcassets/
├── AppIcon.appiconset/
├── Colors/
│   ├── Primary.colorset/
│   ├── Secondary.colorset/
│   ├── Background.colorset/
│   └── Text.colorset/
├── Images/
│   ├── Icons/
│   │   ├── home-icon.imageset/
│   │   ├── profile-icon.imageset/
│   │   └── settings-icon.imageset/
│   ├── Illustrations/
│   │   ├── onboarding-1.imageset/
│   │   └── empty-state.imageset/
│   └── Backgrounds/
│       ├── gradient-bg.imageset/
│       └── pattern-bg.imageset/
└── Symbols/
    ├── custom-symbol-1.symbolset/
    └── custom-symbol-2.symbolset/
```

### 🌍 Localization Structure

```
Localization/
├── en.lproj/
│   ├── Localizable.strings
│   ├── InfoPlist.strings
│   └── LaunchScreen.strings
├── es.lproj/
│   ├── Localizable.strings
│   ├── InfoPlist.strings
│   └── LaunchScreen.strings
└── LocalizationKeys.swift
```

## Configuration Files

### ⚙️ Build Configuration

```
Configuration/
├── Debug.xcconfig
├── Release.xcconfig
├── Staging.xcconfig
├── Info.plist
├── Entitlements.plist
└── BuildSettings/
    ├── Common.xcconfig
    ├── iOS.xcconfig
    └── macOS.xcconfig
```

### 📦 Package Management

```swift
// Package.swift (for SPM)
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "YourApp",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Data", targets: ["Data"]),
        .library(name: "Presentation", targets: ["Presentation"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.9.0")
    ],
    targets: [
        .target(name: "Core", dependencies: []),
        .target(name: "Domain", dependencies: ["Core"]),
        .target(name: "Data", dependencies: ["Domain", "Alamofire"]),
        .target(name: "Presentation", dependencies: ["Domain", "Kingfisher"])
    ]
)
```

## 📋 Best Practices Checklist

### ✅ Structure Guidelines

- [ ] **Layer Separation**: Clear boundaries between layers
- [ ] **Feature Grouping**: Related files grouped together
- [ ] **Consistent Naming**: Follow naming conventions
- [ ] **Reasonable Depth**: Avoid deep folder nesting
- [ ] **Single Responsibility**: Each file has one clear purpose

### ✅ File Organization

- [ ] **Logical Grouping**: Related functionality together
- [ ] **Size Management**: Keep files reasonably sized (< 300 lines)
- [ ] **Import Organization**: Minimize and organize imports
- [ ] **Documentation**: Include header comments
- [ ] **Access Control**: Proper access level modifiers

### ✅ Testing Structure

- [ ] **Mirror Structure**: Test structure mirrors source structure
- [ ] **Mock Organization**: Centralized mock objects
- [ ] **Test Helpers**: Reusable test utilities
- [ ] **Coverage**: Comprehensive test coverage
- [ ] **Fast Tests**: Quick-running unit tests

### ✅ Resource Management

- [ ] **Asset Organization**: Logical asset grouping
- [ ] **Localization**: Proper string externalization
- [ ] **Configuration**: Environment-specific configs
- [ ] **Documentation**: Clear resource documentation
- [ ] **Optimization**: Optimized asset sizes

---

**Remember**: A good project structure grows with your app. Start simple and refactor as needed! 🚀