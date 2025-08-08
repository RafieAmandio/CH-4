import ProjectDescription

let project = Project(
    name: "CH-4",
    targets: [
        .target(
            name: "CH-4",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.CH-4",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["CH-4/Sources/**"],
            resources: ["CH-4/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "CH4-AppClip",
            destinations: .iOS,
            product: .appClip,
            bundleId: "dev.tuist.CH-4.Clip",
            infoPlist: .extendingDefault(
                with: [
                    "NSAppClip": [
                                      "NSAppClipRequestEphemeralUserNotification": false,
                                      "NSAppClipRequestLocationConfirmation": false
                                  ],
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["CH4-AppClip/Sources/**"],
            resources: ["CH4-AppClip/Resources/**"],
            entitlements: .file(path: "CH4-AppClip/CH4-AppClip.entitlements"),
            dependencies: [],
            settings: .settings(
                base: [
                    "CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION": "YES"
                ],
                configurations: [
                    .debug(name: "Debug"),
                    .release(name: "Release")
                ]
            )
        ),
//        .target(
//            name: "CH-4Tests",
//            destinations: .iOS,
//            product: .unitTests,
//            bundleId: "dev.tuist.CH-4Tests",
//            infoPlist: .default,
//            sources: ["CH-4/Tests/**"],
//            resources: [],
//            dependencies: [.target(name: "CH-4")]
//        ),
    ]
)
