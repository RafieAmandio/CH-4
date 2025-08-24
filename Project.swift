import ProjectDescription

let iOSDeployment: DeploymentTargets = .iOS("16.0")

let packages: [Package] = [
  .package(
    url: "https://github.com/supabase-community/supabase-swift.git",
    .upToNextMajor(from: "2.0.0")
  ),
  .package(
    url: "https://github.com/twostraws/CodeScanner",
    .upToNextMajor(from: "2.0.0")
  )
]

let project = Project(
    name: "CH-4",
    packages: packages,
    targets: [
        // MARK: - Shared module
        .target(
           name: "FoundationExtras",
           destinations: [.iPhone], // Changed to iPhone only
           product: .staticFramework,
           bundleId: "dev.tuist.CH4.FoundationExtras",
           deploymentTargets: iOSDeployment,
           sources: ["Modules/FoundationExtras/Sources/**"]
         ),
        .target(
          name: "NetworkingKit",
          destinations: [.iPhone], // Changed to iPhone only
          product: .staticFramework,
          bundleId: "dev.tuist.CH4.NetworkingKit",
          deploymentTargets: iOSDeployment,
          sources: ["Modules/NetworkingKit/Sources/**"],
          dependencies: [
            .target(name: "FoundationExtras"),
            .package(product: "Supabase")
          ]
        ),
        .target(
          name: "UIComponentsKit",
          destinations: [.iPhone], // Changed to iPhone only
          product: .staticFramework,
          bundleId: "dev.tuist.CH4.UIComponentsKit",
          deploymentTargets: iOSDeployment,
          infoPlist: .file(path: "Modules/UIComponentsKit/Info.plist"),
          sources: ["Modules/UIComponentsKit/Sources/**"],
          resources: ["Modules/UIComponentsKit/Resources/**"], // images, strings, etc.
          dependencies: [
            .target(name: "FoundationExtras")
          ]
        ),
        // MARK: - App (host)
        .target(
            name: "CH-4",
            destinations: [.iPhone], // Changed to iPhone only
            product: .app,
            bundleId: "dev.tuist.CH-4",
            deploymentTargets: iOSDeployment,
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "Findect",
                "UILaunchStoryboardName": "LaunchScreen",
                "NSCameraUsageDescription": "This app needs camera access to scan QR codes.",
                "NSLocationWhenInUseUsageDescription": "This app needs location access to help you set event locations.",
                "NSLocationAlwaysAndWhenInUseUsageDescription": "This app needs location access to help you set event locations.",
                "NSLocationTemporaryUsageDescriptionDictionary": .dictionary([
                    "NearbyMap": .string("We need precise location briefly to show accurate nearby results.")
                ]),
                "UIAppFonts": [
                    "Urbanist-Thin.ttf",
                    "Urbanist-Bold.ttf",
                    "Urbanist-Regular.ttf",
                    "Urbanist-Medium.ttf",
                    "Urbanist-SemiBold.ttf"
                ],
                // Add iPhone-specific interface orientations
                "UISupportedInterfaceOrientations": [
                    "UIInterfaceOrientationPortrait"
                ]
            ]),
            sources: ["CH-4/Sources/**"],
            resources: ["CH-4/Resources/**", "Modules/UIComponentsKit/Resources/Fonts/**"],
            entitlements: .file(path: "CH-4/CH-4.entitlements"),
            dependencies: [
                .target(name: "NetworkingKit"),
                .target(name: "UIComponentsKit"),
                .package(product: "CodeScanner"),
                .target(name: "CH4-AppClip") // embed the clip
              ],
            settings: .settings(
                base: [
                    "TARGETED_DEVICE_FAMILY": "1", // 1 = iPhone only
                    "SUPPORTS_MACCATALYST": "NO"
                ]
            )
        ),

        // MARK: - App Clip
        .target(
            name: "CH4-AppClip",
            destinations: [.iPhone], // Changed to iPhone only
            product: .appClip,
            bundleId: "dev.tuist.CH-4.Clip",
            deploymentTargets: iOSDeployment,
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "Findect",
                "NSAppClip": [
                    "NSAppClipRequestEphemeralUserNotification": false,
                    "NSAppClipRequestLocationConfirmation": false
                ],
                "UILaunchScreen": [
                    "UIColorName": "",
                    "UIImageName": "",
                ],
                 "UIAppFonts": [
                    "Urbanist-Thin.ttf",
                    "Urbanist-Regular.ttf",
                    "Urbanist-Medium.ttf",
                    "Urbanist-SemiBold.ttf",
                    "Urbanist-Bold.ttf"
                ]
            ]),
            sources: ["CH4-AppClip/Sources/**"],
            resources: ["CH4-AppClip/Resources/**", "Modules/UIComponentsKit/Resources/Fonts/**"],
            entitlements: .file(path: "CH4-AppClip/CH4-AppClip.entitlements"),
            dependencies: [
                 .target(name: "NetworkingKit"),
                 .target(name: "UIComponentsKit") 
               ],
            settings: .settings(
                base: [
                    "CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION": "YES",
                    "TARGETED_DEVICE_FAMILY": "1", // 1 = iPhone only
                    "SUPPORTS_MACCATALYST": "NO"
                ],
                configurations: [
                    .debug(name: "Debug"),
                    .release(name: "Release")
                ]
            )
        )
    ]
)