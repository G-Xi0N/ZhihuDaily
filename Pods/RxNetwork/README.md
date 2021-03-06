# RxNetwork

[![CI Status](http://img.shields.io/travis/Pircate/RxNetwork.svg?style=flat)](https://travis-ci.org/Pircate/RxNetwork)
[![Version](https://img.shields.io/cocoapods/v/RxNetwork.svg?style=flat)](http://cocoapods.org/pods/RxNetwork)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/RxNetwork.svg?style=flat)](http://cocoapods.org/pods/RxNetwork)
![iOS 9.0+](https://img.shields.io/badge/iOS-9.0%2B-blue.svg)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* iOS 9.0+
* Swift 4

## Installation

RxNetwork is available through [CocoaPods](http://cocoapods.org) or [Carthage](https://github.com/Carthage/Carthage). To install
it, simply add the following line to your Podfile or Cartfile:

#### Podfile

```ruby
pod 'RxNetwork'
```
自己实现缓存
```ruby
pod 'RxNetwork/Cacheable'
```
默认基于 [Cache](https://github.com/onmyway133/Cache) 实现缓存
```ruby
pod 'RxNetwork/Cache'
```

#### Cartfile
```ruby
github "Pircate/RxNetwork"
```

## Usage

### Import

``` swift
import RxNetwork
```

### Configuration

```swift
Network.Configuration.default.timeoutInterval = 20
Network.Configuration.default.plugins = [NetworkIndicatorPlugin()]
Network.Configuration.default.taskClosure = { target in
    // configure common parameters etc.
    switch target.task {
    case let .requestParameters(parameters, encoding):
        let params: [String: Any] = ["token": "", "sign": "", "body": parameters]
        return .requestParameters(parameters: params, encoding: encoding)
    default:
        return target.task
    }
}

// or

let configuration = Network.Configuration()
configuration.timeoutInterval = 20
configuration.plugins = [NetworkIndicatorPlugin()]
Network.Configuration.default = configuration
```

### Request without cache

```swift
StoryAPI.latest
    .request()
    .map(StoryListModel.self)
    .subscribe(onSuccess: { (model) in
        
    }).disposed(by: disposeBag)
```

### Request with cache

```swift
/*
 {
    "top_stories": []
 }
 */
StoryAPI.latest
    .onCache(StoryListModel.self, { (model) in
        
    })
    .request()
    .subscribe(onSuccess: { (model) in
        
    })
    .disposed(by: disposeBag)

StoryAPI.latest
    .cache
    .request()
    .map(StoryListModel.self)
    .subscribe(onNext: { (model) in

    }).disposed(by: disposeBag)
```

```swift
/*
 {
    "code": 2000,
    "message": "Ok",
    "result": []
 }
 */
TestTarget.test(count: 10)
    .onCache([TestModel].self, { (models) in

    })
    .requestObject()
    .subscribe(onSuccess: { (models) in

    })
    .disposed(by: disposeBag)

TestTarget.test(count: 10)
    .cache
    .request()
    .mapObject([TestModel].self)
    .subscribe(onNext: { (models) in
        
    })
    .disposed(by: disposeBag)
```

### Cacheable

需要缓存请遵循 `Cacheable` 协议

```swift
enum API: TargetType, Cacheable {
    case api
}
```

### Notice

```swift
// You may need configure storage policy when use cache response
Network.Cache.shared.storagePolicyClosure = { response in
    guard let code = try? response.map(Int.self, atKeyPath: "code") else { return false }
    return code == 200
}
```

## Author

Pircate, gao497868860@163.com

## License

RxNetwork is available under the MIT license. See the LICENSE file for more info.
