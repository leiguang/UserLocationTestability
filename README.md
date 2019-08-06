# 使用Swift协议来提升代码的可测试性



> 本文翻译自[《Improving code testability with Swift protocols》](https://medium.com/flawless-app-stories/solving-dependencies-in-swift-9ee6ad4a8941)



![lego_bricks.png](https://github.com/leiguang/UserLocationTestability/blob/master/Resources/lego_bricks.png)



作为开发者，面临的最大挑战之一就是实现高可测试性的代码。这些测试是非常有用的，它不仅保证已完成的代码正常工作，并且确保添加新功能时不会影响旧功能。当你在团队中工作时，会有许多人修改同一个项目，因此确保代码的完整性就更加重要了。

有许多种测试方法，它们应该是清晰、明确、简单的。那么，为什么许多开发者不写测试呢？主要的 ~~excuse~~ 原因 是时间不够。我认为，其中很大的因素是由于我们的代码 在不同层、类、外部依赖框架之间的关系过于耦合。

我想证明创建一个框架的抽象层或者解耦类并不是一件困难的事。



**本文代码 [GitHub](https://github.com/leiguang/UserLocationTestability)**



## 场景

假设我们需要开发一个获取用户定位的应用，我们需要使用到 **CoreLocation**。



**ViewController** 中的代码可能像下面这样：

```swift
import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    var locationManager: CLLocationManager
    var userLocation: CLLocation?
    
    init(locationProvider: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
    }

    func requestUserLocation() {
        if case .authorizedWhenInUse = CLLocationManager.authorizationStatus() {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if case .authorizedWhenInUse = status {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
        manager.stopUpdatingLocation()
    }
}
```

**ViewController** 有一个属性 *locationManager*，它是 **CLLocationManager** 的实例，用来请求用户的位置或权限。**ViewController** 遵守 **CLLocationManagerDelegate** 协议，接收 *locationManager* 输出的信息。

在这里，我们可以看到 **ViewController** 与 **CoreLocation** 耦合在一起，存在职责分离不清晰等问题。



无论如何，让我们试着为 **ViewController** 编写测试代码，这是一个例子：

```swift
class ViewControllerTests: XCTestCase {
    
    var sut: ViewController!

    override func setUp() {
        super.setUp()
        sut = ViewController(locationProvider: CLLocationManager())
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testRequestUserLocation() {
        sut.requestUserLocation()
        XCTAssertNotNil(sut.userLocation)
    }
}
```

我们能够看到 **sut** (System Under Test) 和一个可能的测试用例。我们请求用户的位置，并将它存到变量 *userLocation* 中。



问题开始浮现了，虽然 **CLLocationManager** 负责请求用户位置，但它不是同步处理并返回结果的。所以当我们检查存储的位置属性时，*userLocation* 仍然为空。另外，我们也可能还未得到获取定位的权限，在这种场景下，*userLocation* 也将为空。

现在，我们有一些可能的解决方案：

- 测试 **ViewController** 但不测试与位置相关的任何内容。
- 创建 **CLLocationManager** 的子类并模拟方法，或者尝试正确的执行它并将 **CLLocationManager** 与我们的类解耦。

我选择后者。



## 面向协议编程来解决

> “At the heart of Swift’s design are two incredibly powerful ideas: *protocol-oriented programming* and first class value semantics” - Apple



**面向协议编程** 对开发人员来说是非常强大的工具，而Swift无疑是一种面向协议的语言。所以我的建议是使用协议解决这些依赖关系。

首先，要抽象 **CLLocation**，先定义一个带有我们需要的变量和函数的协议。

```swift
typealias Coordinate = CLLocationCoordinate2D

protocol UserLocation {
    var coordinate: Coordinate { get }
}

extension CLLocation: UserLocation {}
```

现在，我们可以得到一个不需要 **CoreLocation** 的 *location*。所以如果我们分析 **ViewController**，会发现其实也并不是真的需要 **CLLocationManager**，我们只是需要一个能够提供用户位置的提供者。因此，让我们来创建一个包含我们所需内容的协议，只要是遵守该协议的东西都能作为我们的位置提供者。

```swift
enum UserLocationError: Error {
    case canNotBeLocated
}

typealias UserLocationCompletionBlock = (Result<UserLocation, UserLocationError>) -> Void

protocol UserLocationProvider {
    func findUserLocation(then: @escaping UserLocationCompletionBlock)
}
```

**UserLocationProvider** 协议，它声明了我们所需的请求用户位置的方法，并将结果通过回调函数返回。

我们准备创建一个 **UserLocationService**，它将遵守提供用户位置的协议。通过这种方式，我们解决了 **CoreLocation** 和 **ViewController** 之间的依赖。但是...等等，**UserLocationService** 仍需要通过 **CLLocationManager** 来请求用户位置......。问题似乎还未解决😅。



再次使用协议来解决这个问题，只需创建一个新的协议来指定什么是位置提供者。

```swift
protocol LocationProvider {
    var isUserAuthorized: Bool { get }
    func requestWhenInUseAuthorization()
    func startUpdatingLocation()
}

extension CLLocationManager: LocationProvider {
    var isUserAuthorized: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedWhenInUse
    }
}
```

扩展 **CLLocationManager**，让它遵守我们的新协议。

现在，我们准备好创建 **UserLocationService** 🎉了，它看起来像下面这样：

```swift
class UserLocationService: NSObject, UserLocationProvider {
    
    private var provider: LocationProvider
    private var locationCompletionBlock: UserLocationCompletionBlock?
    
    init(provider: LocationProvider) {
        self.provider = provider
        super.init()
    }
    
    func findUserLocation(then: @escaping UserLocationCompletionBlock) {
        self.locationCompletionBlock = then
        if provider.isUserAuthorized {
            provider.startUpdatingLocation()
        } else {
            provider.requestWhenInUseAuthorization()
        }
    }
}

extension UserLocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            provider.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationCompletionBlock?(.success(location))
        } else {
            locationCompletionBlock?(.failure(.canNotBeLocated))
        }
    }
}
```

**UserLocationService** 有自己的位置提供者，但它并关心也不知道这个提供者具体是谁，因为它只需要请求位置时获取到用户所在的位置就够了，其余的不是他的责任。

因为我们将使用 **CoreLocation**，所以让 **UserLocationService** 遵守 **CLLocationManager** 协议。但是我们在测试代码中并不会用到这个协议。

我们可以在 **UserLocationProvider** 协议中添加任何类型的代理，但对于我们的例子来说，我认为它会显得太多余了。

在开始测试之前，看看用 **UserLocationProvider** 代替 **CLLocationManager** 之后，**ViewController** 的新面貌。

```swift
class ViewController: UIViewController {
    
    var locationProvider: UserLocationProvider
    var userLocation: UserLocation?
    
    init(locationProvider: UserLocationProvider) {
        self.locationProvider = locationProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func requestUserLocation() {
        locationProvider.findUserLocation { [weak self] (result) in
            switch result {
            case .success(let location):
                self?.userLocation = location
            case .failure:
                print("User can not be located 😔 ")
            }
        }
    }
}
```

可以看到，**ViewController** 拥有更少的代码，更少的职责，更易于测试了。



## Tests

让我们开始测试，首先我们需要创建一些模拟类用来测试 **ViewController**。

```swift
struct UserLocationMock: UserLocation {
    var coordinate: Coordinate {
        return Coordinate(latitude: 51.509865, longitude: -0.118092)
    }
}

class UserLocationProviderMock: UserLocationProvider {
    
    var locationResult: Result<UserLocation, UserLocationError>?
    
    func findUserLocation(then: @escaping UserLocationCompletionBlock) {
        if let result = locationResult {
            then(result)
        }
    }
}
```

使用这些模拟类，可以注入任何我们需要的结果，我们将模拟 **UserLocationProvider** 的工作方式。因此，我们将重点放在我们的真实目标 **ViewController** 上。

```swift
class ViewControllerTests: XCTestCase {
    
    var sut: ViewController!
    var locationProvider: UserLocationProviderMock!

    override func setUp() {
        super.setUp()
        locationProvider = UserLocationProviderMock()
        sut = ViewController(locationProvider: locationProvider)
    }

    override func tearDown() {
        sut = nil
        locationProvider = nil
        super.tearDown()
    }

    func testRequestUserLocation_NotAuthorized_ShouldFail() {
        // Given
        locationProvider.locationResult = .failure(.canNotBeLocated)
        
        // When
        sut.requestUserLocation()
        
        // Then
        XCTAssertNil(sut.userLocation)
    }
    
    func testRequestUserLocation_Authorized_ShouldReturnUserLocation() {
        // Given
        locationProvider.locationResult = .success(UserLocationMock())
        
        // When
        sut.requestUserLocation()
        
        // Then
        XCTAssertNotNil(sut.userLocation)
    }
}
```

我们创建了两个测试用例，一个用例检查是否有获取用户位置的权限，该位置提供者没有提供位置。另一个是相反的用例，如果有权限，将获取到用户的位置。就像你看到的那样，测试通过了！✅ 💪



除了 **ViewController** 我们还创建了一个额外的类 **UserLocationService**，因此我们的测试也应该覆盖它。

**LocationProvider** 需要被mock，因为它不是我们测试的目标对象。

```swift
class LocationProviderMock: LocationProvider {
    
    var isRequestWhenInUseAuthorizationCalled = false
    var isStartUpdatingLocationCalled = false

    var isUserAuthorized: Bool = false
    
    func requestWhenInUseAuthorization() {
        isRequestWhenInUseAuthorizationCalled = true
    }
    
    func startUpdatingLocation() {
        isStartUpdatingLocationCalled = true
    }
}
```

可以创建许多测试，其中之一是向提供者验证我们是否有权限，如果没有，则请求授权；如果有，就请求位置。

```swift
class UserLocationServiceTests: XCTestCase {
    
    var sut: UserLocationService!
    var locationProvider: LocationProviderMock!

    override func setUp() {
        super.setUp()
        locationProvider = LocationProviderMock()
        sut = UserLocationService(provider: locationProvider)
    }

    override func tearDown() {
        sut = nil
        locationProvider = nil
        super.tearDown()
    }
    
    func testRequestUserLocation_NotAuthorized_ShouldRequestAuthorization() {
        // Given
        locationProvider.isUserAuthorized = false
        
        // When
        sut.findUserLocation { _ in }
        
        // Then
        XCTAssertTrue(locationProvider.isRequestWhenInUseAuthorizationCalled)
    }
    
    func testRequestUserLocation_Authorized_ShouldNotRequestAuthorization() {
        // Given
        locationProvider.isUserAuthorized = true
        
        // When
        sut.findUserLocation { _ in }
        
        // Then
        XCTAssertFalse(locationProvider.isRequestWhenInUseAuthorizationCalled)
    }
}
```



## 总结

有许多种解耦代码的方式，而本文只是其中之一。但我认为本文可能是一个很好的例子，表明测试不是一项艰巨的任务。

如果你还记得文章顶部的图片，你可以看到乐高积木，我认为它们很好的解释了什么是解耦和抽象你的组件。最后，它被定义为一种特定的连接方式，但颜色并不重要。

创建mock对象可能是其中最懒得任务，不过已经有一些库和工具来辅助做这件事，例如：[Sourcery](https://github.com/krzysztofzablocki/Sourcery)。我的同事  [Hugo Peral](https://twitter.com/hugojperal) 也写了一篇文章 [Saving time with Sourcery](https://tech.edreamsodigeo.com/saving-time-with-sourcery) 来解释如何使用 *Sourcery* 节省测试时间。或者 [John Sundell](https://twitter.com/johnsundell) 的这篇 [Mocking in Swift](https://www.swiftbysundell.com/posts/mocking-in-swift)，它提供了有关如何制作mock的更多细节。

最后，感谢您阅读这篇文章。如果您觉得它对您有用或者您认为对某人有用，请分享它 😉。如果您有任何疑问或者改进意见，请随时在下面发表评论。
