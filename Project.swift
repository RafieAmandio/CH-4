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
            name: "CH-4Tests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.CH-4Tests",
            infoPlist: .default,
            sources: ["CH-4/Tests/**"],
            resources: [],
            dependencies: [.target(name: "CH-4")]
        ),
    ]
)
