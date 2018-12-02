# 5.0.2
## Bug fixes
* Displayed button and input visibility properly based on channel settings
* Fixed missing localizations

# 5.0.0
## New
* Added Push bot feature

## Updates
* swift 4.2 migration
* Set closed user chat visibility to true by default
* Added unit tests for push bot evaluation 
* Improved data flow consistency
* Refactored model and related methods

# 4.2.7
## Bug fixes
* Unwrapped Any type properly with reflection

# 4.2.6
## Bug fixes
* Fixed message with image cell layout

# 4.2.3
## Updates
* Fixed requestId to query params

# 4.2.2
## Bug fixes
* Fixed support bot close action 
* Improved string tag parsing

# 4.2
## New 
* Added Support bot feature 

## Updates
* Updated and synced localization

## Bug fixes
* Fixed to apply alert count properly 
* Fixed push notification handling edge cases 

# 4.1.10
## Updates
* Removed and merged frameworks (Manuallayout, CGFlaotLiteral, Then, HexColors)

## Bug fixes
* Fixed actionable message when context type is other than just text

# 4.1.9
## Updates 
* Updated models to make compatible with react native

## Bug fixes
* Fixed in-app push notification leak 

# 4.1.8
## Bug fixes
* Fixed navigation item layout for iOS 9

# 4.1.7
## Updates
* react-native support with carthage

## Bug fixes
* Fixed carthage installation issue
* Fixed dependencies version
* Fixed to set locale properly

# 4.1.5
## Bug fixes
* Fixed onChangeBadge didn't get called properly 
* Fixed `profile` fields sync
* Ensured all UI updates on main thread

# 4.1.3
## Bug fixes
* Fixed launcher button inconsistently appears on random position
* Fixed possible force unwrapped crash in message model

# 4.1.2
## Updates
* Refactored channel properties 

## Bug fixes 
* Fixed unable to boot for startup
* Fixed boot params 

# 4.1.0 
## Updates
* `boot:` will not show launcher automatically
* `show:` and `hide:` is visibility control property for launcher and it appears globally over application
* Changed image viewer framework
* Displayed watermark for startup
* Updated Cartfile 

# 4.0.2 (Sept 4, 2018)
## Bug fixes
* Fixed unintentionally delete cookie 

# 4.0.1 (Sept 3, 2018)
## Bug fixes
* Remove warnings 
* Fixed email link behavior

# 4.0.0 (August 31, 2018)
## Deprecated
* ChannelPluginSetting's hideDefaultLauncher property has been deprecated

## Update
* Users now will be asked to close chat
* Web link will be opened in application instead default browser
* Updated internal APIs related to session and read
* Cleared all data properly on `shutdown`
* Cached country data locally 

# 3.2.8 (August 28, 2018)
## Bug fixes 
* Fixed crash caused by string forced unwrapping

# 3.2.7 (August 1, 2018)
## Update
* Removed install objc header option from build option
* Handled phone number in text 
* Supported settings' legacy keys

# 3.2.6
## Update
* Removed AdSupport

# 3.2.5 
## Bug fixes
* Fixed condition to handle link for delegate

# 3.2.4 (July 18, 2018)
## Update
* Updated in-app push notification design
* Refactored push and guest update logics
* Showed closed user chats by default

## Bug fixes
* Fixed blocked user UX
* Fixed settings unarchived error

# 3.2.3 (July 10, 2018)
## New
* Added message translation
 
## Updates
* Fixed GIF display on chat
* Refactored launcher view logics
* Added default launcher position config in ChannelPluginSettings

## Bug fixes
* Fixed message sync when plugin launched from push notification

# 3.2.2 (July 05, 2018)
## Updates
* Enlarged emoji if text contains only emoji
* Added view parameter for `show:`

## Bug fixes
* Return proper value for `onClickChatLink`

# 3.2.0 (June 29, 2018)
## New 
* Added actionable message type

## Updates
* Handled long press on link 
* In-app push vibration when a phone is on silent
* Improved camera feature 
* Updated in-app push notification view layout

## Bug fixes
* Fixed bubble text line height calculation

# 3.1.6 (June 22, 2018)
## Bug fixes
* Fixed a crash when app was launched by push notification
* Fixed opening new chat logic 

# 3.1.5 (June 19, 2018)
## Bug fixes
* Fixed a bug that messages were not sync when app became active
* Fixed message bubble UI issue

# 3.1.4 (June 6, 2018)
## Bug fixes
* Removed UINavigationItem+Margin due to iOS 11 bug
* Fixed NavigationItem margin properly
* Fixed emoji regex 

# 3.1.3 (June 1, 2018)
## Updates
* Added completion callback parameter in `close:` method
* Added animated parameter in `openChat:`
* Updated Guest property to immutable

## Bug fixes
* Fixed edge cases in message formating
 
# 3.1.2 (May 22, 2018)
## Updates
* Added Guest as parameter in boot completion block

## Bug fixes
* Fixed default launcher button visibility

# 3.1.0 (May 16, 2018)
## Updates
* Renamed Guest to Profile
* Changed locale field type from String to Enum
* Changed userId location from Profile to ChannelPluginSettings
* Added ProfileBot feature
* Updated default launcher visibility condition

## Bug fixes
* Fixed unexpected behavior when homepage and/or phoneNumber is missing in ProfileView
* Fixed scrollView behavior when input field is selected

# 3.0.6 (May 11, 2018)
* Resolved carthage dependencies conflicts
* SocketIO version to 13.x 
* Removed UIColor-hex-swift and added HexColors
* Fixed right button that was not able to click after chat was completed

# 3.0.4 (Apr 26, 2018)
* Registered push token properly

# 3.0.3 (Apr 22, 2018)
* Removed colon escape from message

# 3.0.2 (Apr 15, 2018)
* Fixed to boot / shutdown properly 

# 3.0.1 (Apr 13, 2018)
## Updates
* Renamed default event name `CheckIn` to `Boot`
* Added default event `ChannelOpen`

# 3.0.0 (Apr 12, 2018)
## Breaking Changes
* Renamed framework and class name from CHPlugin to ChannelIO
* Removed ChannelPlugin public properties `debugMode`, `hideLauncherButton`,
`enabledTrackDefaultEvent` and `showInAppPush` (these properties moved into `ChannelPluginSettings`)
* Removed `initialize:` and `checkIn` method and added `boot:`
* Renamed `checkOut` to `shutdown`
* Renamed `register:` to `initPushToken:`
* Renamed `show:` and `hide:` to `open:` and `close:` respectively
* Renamed `showLauncher:` and `hideLauncher:` to `show:` and `hide:` respectively
* Renamed `showChat:` to `openChat:`
* Renamed `track:` parameter names to `eventName` and `eventProperty`
* Renamed `ChannelCheckinCompletionStatus` to `ChannelPluginCompletionStatus`
* Renamed `CheckIn` to `Guest`

## New
* Introduced `ChannelPluginSettings` class for ChannelIO configuration
* Added locale option in `ChannelPluginSettings`
* Added locale option view in profile view
* Introduced message formatting (i.e. \*something\* for italic and \*\*more\*\* for bold)
* Upload video is available

## Updates
* Refactored message cell structures

# 2.6.2 (Mar 21, 2018)
## Updates
* Renamed `ChannelUserChat` to `PushEvent`

# 2.6.0 (Mar 15, 2018)
## Updates
* Updated Channel model
* Updated `showChat:` to show new chat if chat id is nil
* Allowed trial channel to pass checkin validation
* Improved error logs
* Removed CHPhotoBrowser specific version from dependency
 
# 2.5.0 (Feb 28, 2018)
## New
* In-app push notification customization available.
* Added `didReceivePush:` `showChat:` methods and a class that contains necessary properties to display push view
* Refactor some of chat logics 

## Bug fixes
* Fixed retain cycle

# 2.4.5 (Feb 21, 2018)
## Bug fixes
* Displayed bot avatar and name on in-app push notification
* Show Launcher properly 
* Fixed incorrect timestamp
 
# 2.4.3 (Feb 1, 2018)
## Bug fixes
* Synced launcher visibility based on channel settings

# 2.4.2 (Jan 17, 2018)
## Updates
* Removed SwiftDate framework

# 2.4.1 (Jan 12, 2018)
## Updates
* Added watermark

## Bug fixes
* Fixed launcher button layout for iPhone X

# 2.4.0 (Dec 22, 2017)
## Updates
* Redesigned UserChat UI/UX

## Bug fixes
* Fixed minor bugs
* Fixed file upload logic (GIF)

# 2.3.3 (Nov 21, 2017)
## Updates
* Updated new message view 

# 2.3.2 (Nov 21, 2017)
## Bug fixes
* Fixed country code json format

# 2.3.1 (Nov 17, 2017)
## Bug fixes 
* Fixed potential memory leak

# 2.3.0 (Nov 16, 2017)
## Updates
* Added live typing indicator 
* Raised min os version to 9.0

# 2.2.6 (Nov 15, 2017)
## Bug fixes
* Fixed scopes for objective-c
* Fixed symbol error for iOS 8

# 2.2.4 (Nov 9, 2017)
## New
* Added willShow/willHideChatList delegate methods

## Updates
* SwiftyJSON 4.0 migration 
* Rolled back to deployment target 8.0

# 2.2.2 (Nov 5, 2017)
## Updates
* Dwifft to CHDwifft (forceRemoveAnimation)
* iPhone X layout supports

## Bug fixes
* Fixed animation issue

# 2.2.0 (Nov 2, 2017)
## Updates
* Detached all in-project dependecies 
* Swift 4 migration 
* Refactored code style
* Added API Error convention 

# 2.1.0 (Oct 26, 2017)
## New
* Added `shouldHandleChatLink:` delegate method 

## Updates
* Increased deployment target to 9.0

## Bug fixes
* Fixed channel open properly after duplicated checkin 
* Fixed minor bugs 

# 2.0.5 (Sept 25, 2017)
## Updates
* PhoneNumberKit to 2.0 (Swift 4.0)

# 2.0.4 (Sept 22, 2017)
## Bug fixes
* Fixed minor bugs

# 2.0.3 (Sept 20, 2017)
## Updates
* Downgraded PhoneNumberKit to 1.4 (compatibility issue)

# 2.0.2 (Sept 14, 2017)
## Updates
* iOS 11 migration
* Changed name `trackCheckIn` -> `enabledTrackDefaultEvent`
* enabled `bitcode` feature

# 2.0.0 (Sept 8, 2017)
## Breaking Changes
* Renamed some properties and methods

## New
* Introduced new method `track` to send event to channel

## Bug fixes
* Fixed minor bugs

# 1.1.1 (Aug 26, 2017)
## Bug fixes
* Fixed message height calculation

# 1.1.0  (Aug 25, 2017)
## Updates
* Updated socket io v2
* Added StarstreamSocketIO framework to support socket v2
* If incoming push is same chat as current chat, It won't push new chat but update
* Removed unused 'isVisible' property

## Bug fixes
* Fixed html unescaped for welcome message
* Fixed link color
* Fixed off by one error for new message label
* Fixed badge count issues when launched app with push notification
* Fixed name/phone number dialog layout and localizations
* Fixed background layout for phone number picker view
* Fixed font size for in-app chat notification

# 1.0.5  (July 26, 2017)
## Bug fixes
* Updated UIState in redux correctly
* Reversed photo indexes

# 1.0.4 (July 22, 2017)
## Bug fixes
* Fixed duplicate `show:` method

# 1.0.3 (July 21, 2017)
## Updates
* Added in-app push notification sound
* Added sound option
* Saved closed user chat option state

## Bug fixes
* Fixed minor bugs

# 1.0.2 (July 13, 2017)
## Bug fixes
* Fixed deleted user chats handling
* Fixed avatar background color issue

# 1.0.1 (July 10, 2017)
## Updates
* Added sound for in app push notification
* Added clear button in user info editing field
* Updated new chat banner UI

## Bug fixes
* Fixed layout bugs

# 1.0.0 (July 5, 2017)
## New
* Veil can now update name/phone number
* Introduced review process after finish conversation

## Bug fixes
* Fixed UI / layout issues
* Validated when show(:) method is called
* Displayed new messages in user chat view properly

# 0.2.5 (June 9, 2017)
## Bug fixes
* Fixed credential errors when app become active
* Adjusted redux states

# 0.2.2 (May 31, 2017)
## Bug fixes
* Fixed user default key conflict
* Fixed launcher display bug

# 0.2.1 (May 24, 2017)
## Updates
* Redesinged profile view (top left of chat list)
* Added Error toast
* Changed launcher icon
* Optimized socket connectivity

## Bug fixes
* Updated badge count properly when app become active from background
* Fixed session sync when app launched by clicking push notification

# 0.1.17 (May 10, 2017)
## Updates
* Migrated to Swift 3.1
* WebSocket connect/disconnect when app state changes

# 0.1.15 (Apr 19, 2017)
* Fixed minor bugs
* Improved socket connectivity

# 0.1.14 (Apr 7, 2017)
* first beta release
