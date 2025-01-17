# [AppMetrica Push SDK](https://appmetrica.io)

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/AppMetricaPush.svg?style=for-the-badge)](https://cocoapods.org/pods/AppMetricaPush)
[![SPM Index Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fappmetrica%2Fpush-sdk-ios%2Fbadge%3Ftype%3Dswift-versions&style=for-the-badge)](https://swiftpackageindex.com/appmetrica/push-sdk-ios)
[![SPM Index Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fappmetrica%2Fpush-sdk-ios%2Fbadge%3Ftype%3Dplatforms&style=for-the-badge)](https://swiftpackageindex.com/appmetrica/push-sdk-ios)

AppMetrica Push SDK allows you to send targeted push notifications to app users. These notifications are called push campaigns. You can use push campaigns to engage your audience and help reduce churn.

## Installation

### Swift Package Manager

#### Through Xcode:

1. Go to **File** > **Add Package Dependency**.
2. Put the GitHub link of the AppMetrica Push SDK: https://github.com/appmetrica/push-sdk-ios.
3. In **Add to Target**, select **None** for modules you don't want.

#### Via Package.swift Manifest:

1. Add the SDK to your project's dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/appmetrica/push-sdk-ios", from: "3.0.0")
],
```

2. List the modules in your target's dependencies:

```swift
.target(
    name: "YourTargetName",
    dependencies: [
        .product(name: "AppMetricaPush", package: "push-sdk-ios"),
        // Optionally include 'AppMetricaPushLazy' for lazy push feature
    ]
)
```

### CocoaPods

1. If you haven't set up CocoaPods, run `pod init` in your project directory.
2. In your Podfile, add AppMetrica Push dependencies:

```ruby
target 'YourAppName' do
    # For all analytics features, add this umbrella module:
    pod 'AppMetricaPush', '~> 3.0.0'

    # Optionally add Lazy Push pod
    pod 'AppMetricaPushLazy', '~> 3.0.0'
end
```

3. Install the dependencies using `pod install`.
4. Open your project in Xcode with the `.xcworkspace` file.

### Optional

### Modules Overview

- `AppMetricaPush`: Required for basic SDK use.
- `AppMetricaPushLazy`: Enables lazy push support

## Integration Quickstart
Here's how to add AppMetrica Push SDK to your project (works for both SwiftUI and UIKit):

1. Add [AppMetrica](https://github.com/appmetrica/appmetrica-sdk-ios/) into project

2. `import AppMetricaPush`.

3. Configure AppMetricaPush by setting `UNUserNotificationCenter.current().delegate = AppMetricaPush.userNotificationCenterDelegate` in `application(_:didFinishLaunchingWithOptions:)`.

4. Register device token in `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`

5. Call `UIApplication.registerForRemoteNotifications()`. See [documentation](https://developer.apple.com/documentation/uikit/uiapplication/1623078-registerforremotenotifications) to enable visible notifications.

6. (Optional) If you also use `UISceneDelegate` add `AppMetricaPush.handleSceneWillConnectToSession(with:)` in `scene(_:willConnectTo:options:)`

### For UIKit:

Put this in your `AppDelegate.swift`:

```swift
import UIKit
import UserNotifications
import AppMetrica
import AppMetricaPush

class AppDelegate: UIResponder, UIApplicationDelegate {

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
	    if let configuration = AppMetricaConfiguration(apiKey: "Your_API_Key") {
	        AppMetrica.activate(with: configuration)
	    }
	    
	    UNUserNotificationCenter.current().delegate = AppMetricaPush.userNotificationCenterDelegate
	    return true
	}
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
	    AppMetricaPush.setDeviceToken(deviceToken)
	}

}
```

If you are using scenes, put this in your `SceneDelegate.swift`
```swift
import UIKit
import AppMetricaPush

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	func scene(_ scene: UIScene, willConnectTo
	           session: UISceneSession, options
	           connectionOptions: UIScene.ConnectionOptions) {
	     AppMetricaPush.handleSceneWillConnectToSession(with: connectionOptions)
	}
}
```

### For SwiftUI:

For integrating AppMetrica Push SDK into a SwiftUI application, you can use an AppDelegate adapter to handle lifecycle events related to push notifications. Create a new AppDelegate.swift and set it up similarly to the UIKit approach:


Then in your `App` struct:

```swift
@main
struct YourAppNameApp: App {
    // Use the `@UIApplicationDelegateAdaptor` property wrapper to work with AppDelegate and set up AppMetrica Push SDK
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Documentation

You can find comprehensive integration details and instructions for installation, configuration, testing, and more in our [full documentation](https://appmetrica.io/docs/en/push/).

## License

AppMetrica Push SDK is released under the MIT License.
License agreement is available at [LICENSE](LICENSE).
