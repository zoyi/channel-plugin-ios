# Channel Plugin API Reference

## ChannelPlugin properties
----

#### debugMode
| | |
| --- | --- |
| description | a `boolean` to set debug mode or not |
#### hideLauncherButton
| | |
| --- | --- |
| description | a `boolean` to show/hide launcher button after checkin succeed |
#### badgeDelegate
| | |
| --- | --- |
| description | a `ChannelBadgeDelegate` 

## Class methods
----

### initialize:
```swift
public func initialize(pluginKey: String)
```
| | |
| --- | --- |
| description | initialize channel plugin |
| parameter | pluginKey - a `String` that represents plugin key |

### checkin:completion:
```swift
public func checkin(_ checkinObj: Checkin? = nil, 
                      completion: ((ChannelCheckinCompletionState) -> Void)? = nil) 
```
| | |
| --- | --- |
| description | check in channel |
| parameter | checkin - [checkin](#Checkin) object |
|  | completion - a block to be called after checkin is completed |

### checkout
```swift
public func checkOut()
```
| | |
| --- | --- |
| description | checkout from Channel |

### show:
```swift
public func show(animated: Bool)
```

| | |
| --- | --- |
| description | show `ChannelPlugin` messenger |
| parameter | animated - a `boolean` to animate or not |

### hide:
```swift
public func hide(animated: Bool)
```

| | |
| --- | --- |
| description | hide `ChannelPlugin` messenger |
| parameter | animated - a `boolean` to animate or not |

### showLauncher:
```swift
public func showLauncher(animated: Bool)
```

| | |
| --- | --- |
| description | show `ChannelPlugin` launcher |
| parameter | animated - a `boolean` to animate or not |

### hideLauncher:
```swift
public func hideLauncher(animated: Bool)
```
| | |
| --- | --- |
| description | hide `ChannelPlugin` launcher |
| parameter | animated - a `boolean` to animate or not |

### register:
```swift
public func register(deviceToken: Data)
```

| | |
| --- | --- |
| description | register device token |
| parameter | deviceToken - a `Data` represents device token |

### handlePushNotification:
```swift
public func handlePushNotification(_ userInfo: [AnyHashable: Any]) 
```

| | |
| --- | --- |
| description | handle push notification |
| parameter | userInfo - a `Dictionary` contains push data |


## Protocol
----

### ChannelBadgeDelegate protocol
```swift
public protocol ChannelBadgeDelegate {
    func badgeDidChanged(count: Int)
}
```
| | |
| --- | --- |
| description | a protocol method to get badge count |

## Checkin 
----
Provide methods to contain user information for check in
### with:
```swift
public func with(userId: String)
```
| | |
| --- | --- |
| description | set user Id |
| parameter | userId - a `String` represents user Id |

### with:
```swift
public func with(name: String)
```
| | |
| --- | --- |
| description | set user name |
| parameter | name - a `String` represents name |

### with:
```swift
public func with(mobileNumber: String)
```
| | |
| --- | --- |
| description | set mobile number |
| parameter | mobileNumber - a `String` represents mobile number |

### with:
```swift
public func with(avatarUrl: String)
```
| | |
| --- | --- |
| description | set user avatar url |
| parameter | avatarUrl - a `String` represents an avatar url |

### with:
```swift
public func with(metaKey: String, metaValue: Any)
```
| | |
| --- | --- |
| description | set other meta info |
| parameter | metaKey - a `String` represents key |
| | metaValue - `Any` value |



