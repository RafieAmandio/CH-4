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
           destinations: .iOS,
           product: .staticFramework,
           bundleId: "dev.tuist.CH4.FoundationExtras",
           deploymentTargets: iOSDeployment,
           sources: ["Modules/FoundationExtras/Sources/**"]
         ),
        .target(
          name: "NetworkingKit",
          destinations: .iOS,
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
          destinations: .iOS,
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
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.CH-4",
            deploymentTargets: iOSDeployment,
            infoPlist: .extendingDefault(with: [
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
                ]
            ]),
            sources: ["CH-4/Sources/**"],
            resources: ["CH-4/Resources/**", "Modules/UIComponentsKit/Resources/Fonts/**"],
            entitlements: .file(path: "CH-4/CH-4.entitlements"),
            // Adding the App Clip as a dependency here makes Xcode embed it in the host app
            dependencies: [
                .target(name: "NetworkingKit"),
                .target(name: "UIComponentsKit"),
                .package(product: "CodeScanner"),
                .target(name: "CH4-AppClip") // embed the clip
              ]
        ),

        // MARK: - App Clip
        .target(
            name: "CH4-AppClip",
            destinations: .iOS,
            product: .appClip,
            bundleId: "dev.tuist.CH-4.Clip",
            deploymentTargets: iOSDeployment,
            infoPlist: .extendingDefault(with: [
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
                    "Urbanist-SemiBold.ttf"
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
                    "CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION": "YES"
                ],
                configurations: [
                    .debug(name: "Debug"),
                    .release(name: "Release")
                ]
            )
        )
    ]
)
