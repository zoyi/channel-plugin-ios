# 7.1.5
## Bug fixes
* Fixed some layout bug
* Fixed popup click area properly
* Fixed chat lastmessage to include buttons

# 7.1.4
## Updates
* Add Button Link in in-app-push and message
* Add boolean and date change UI on user profile type
* Remove resource bundle on podspec

# 7.1.3
## Bug fixes
* Fixed issue that inappPush face-type not working correctly

# 7.1.2
## Bug fixes
* Fixed permission logic properly

# 7.1.1
## Bug fixes
* Add misssing permission on photo and camera
* Fixed issue which avatar image was distorted
* Fixed hide function completion not working when animated option is ture
* Add existing inappNotification hide logic when showUserChat function called
* Fixed sdk push click logic because of double boot

# 7.1.0
## Updates
* Add memberHash on boot.
* Add userUpdate function.
* Add unsubscribed option on boot, userUpdate, settingView.

# 7.0.17
## Bug fixes
* Fixed issue where support bot first messages containing webpage were not displayed correctly.

# 7.0.16
## Bug fixes
* Fixed support bot change issue when state is unstable

# 7.0.15
## Updates
* Add resoures on podspec because of flutter asset not displaying issue

# 7.0.14
## Bug fixes
* Fixed an issue that always has a click event even if the plugin button is not visible

# 7.0.13
## Bug fixes
* Fixed supprotBot Button on lastline didn't click sometimes issue  

# 7.0.12
## Bug fixes
* Fixed pad actionsheet crash issue
* Fixed token not delete issue
* Fixed push ack not send issue
* Fixed in-app-push giant emoji height bug

# 7.0.11
## Bug fixes
* Fixed wrong size when supportbot button has only emoji

# 7.0.10
## Updates
* Fixed logic so that in-app push disappears when Open, OpenChat function is called

# 7.0.9
## Updates
* Update Rx version because of UIWebview deprecated

# 7.0.8
## Bug fixes
* Fixed not showing launcher button on multi window envirnment(with SceneDelegate). Please check 'https://developers.channel.io/docs/ios-installation' if you use SceneDelegate.

# 7.0.7
## Updates
* Add some debug log

# 7.0.6
## Bug fixes
* Changed thirdparty library from SVProgressHUD to JGProgressHUD
* Remove CRToast
* Fixed some objective-c issue

# 7.0.5
## Bug fixes
* Fixed launcher window cut off issue

# 7.0.4
## Bug fixes
* Fixed private name duplicate issue after xcode 11.4 updating

# 7.0.3
## Updates
* Update some localize string

# 7.0.2
## Bug fixes
* Fixed RN language bug


# 7.0.1
## Updates
* Update Alamofire version 4.9 -> 5.0

# 7.0.0
## Updates
* Added Marketing feature
* Redesigned in app push notification views
* Refactored chat view
* Changed markdown to ANTLR to parse messages
* Changed file views (image, video)

## Bug fixes
* Fixed minor bugs

# 6.1.24
## Bug fixes
* Cleaned up socketio connection properly

# 6.1.23
## Bug fixes
* Restore host window to be key window after insert uiwindow

# 6.1.22
## Updates
* Please check your `LauncherConfig` if you happen to use it. We updated container view frame position for launcher, so after this updates the launcher's position might not be what you intended
 
## Bug fixes
* Insert UIWindow only if needed (only when launcher is needed to be displayed)
* Set UIWindow size properly under status bar

# 6.1.21
## Bug fixes
* Removed UIWindow properly
* Fixed status bar style
* Fixed Welcome message that was not set properly

# 6.1.20
## Bug fixes
* Fixed attributed welcome message

# 6.1.19
## Bug fixes
* Fixed missing files

# 6.1.18
## Updates
* Changed plugin button and InappNotification present on UIWindow
## Bug fixes
* Fixed Badge minus display
* Fixed wrong user chat cell height calculate
* Solved conflict with SkeletonView

# 6.1.17
## Bug fixes
* Fixed some broken emoji display
* Fixed text height calculation for welcome
* Changed user chat cell height calculation to automatic

# 6.1.15
## Updates
* Changed minimum os version to 10
* Updated depandencies versions for swift 5 (Reusable, SnapKit, SwiftyJSON, ObjectMapper, NVActivityIndicatorView, PhoneNumberKit)

## Bug fixes
* Fixed becoming online bug when app is not running

# 6.1.14
## Bug fixes
* Fixed new banner logic
* Added missing video type

# 6.1.13
## Bug fixes
* Fixed iOS 13 layout (Dicarded some UIScreen.main usage due to changing default present style)

# 6.1.12
## Updates
* Removed M13ProgressView

# 6.1.11
## Updates
* Added deleted message cell
* Updates dependencies

## Bug fixes
* Fixed presentation style for image viewer
* Fixed dark mode issue

# 6.1.10
## Updates
* Disabled darkmode temporary

# 6.1.9
## Updates
* Updated dependencies version

# 6.1.8
## Bug fixes
* Fixed proj file linking problem 

# 6.1.7
## Updates
* Improved view transition

## Bug fixes
* Fixed SupportBot sync issue
* Fixed Lounge additional chat count
* Wrapped `track:` into main thread

# 6.1.6
## Updates
* Updated marketing version 

# 6.1.5
## Bug fixes
* Fixed navigation coloring issue

# 6.1.4
## Updates
* Handled swipe to dismiss for iOS 13
 
## Bug fixes
* Fixed iOS 13 crash issue due to private layout change access denied
* Removed image asset forced unwrapping 

# 6.1.1
## Bug fixes
* Added missing nudge keep API

# 6.1.0
## Updates
* Changed some user chats' state
* Hided delete message from chat
* Added line integration
* Updated InApp Push Notification view layout

# 6.0.4
## Updates
* Excluded UIAlertController from topController

# 6.0.3
## Updates
* Updated SDWebImage framework
* Removed FLAnimatedImage framework
* Removed CHNavBar framework

# 6.0.1
## Updates
* Removed unnecessary public keyword

# 6.0.0
## Updates
* Introduced lounge view 
* Added `onChnageProfile` delegate method
* Applied operation time in real-time
* Improved test cases

# 5.5.6
## Updates
* Detached TLPhotoPicker from project (added to podspec and cartfile) - Don't forget to add this to your linked frameworks if you use Carthage)
* Cocopaods bundle resource 

# 5.5.4
## Updates
* Removed unecessory public classes

# 5.5.3
## Bug fixes
* Fixed missing file caused build failure

# 5.5.1
## Updates
* Swift 5
* Set minimum required version from ios 9.0 to 9.1
* Replaced photo picker framework (Removed DKImagePickerController, DKCamera, CropViewController, DKGallery)
* Replaced photo viewer (Removed Lightbox, submodule Imaginary, Cache)

# 5.4.0
## Updates
* Updated default launcher icon and rebranding

# 5.3.4
## Updates
* Added `initPushToken: String` for react native
* Renamed `willOpenMessenger` and `willCloseMessenger` to `willShowMessenger` and `willHideMessenger`

# 5.3.3
## Updates
* Displayed launcher on proper top controller view

# 5.3.2
## Bug fixes
* Fixed retry loader to dismiss properly

# 5.3.1
## Updates
* Optimized `close:` to handle edge cases

# 5.3.0
## Updates
* Support bot will not be working below 5.3
* Updated support bot api and flows
* Added APIs retry logics
* Added RxSwiftExt framework

# 5.2.4
## Bug fixes
* Removed test related frameworks from project due to carthage build error

# 5.2.3
## Bug fixes
* Fixed actionsheet issue for ipad

# 5.2.1
## Bug fixes
* Fixed country code parsing

# 5.2.0
## Updates
* Updated pushbot flow logics
* Added pushbot button and image redirection
* Added keep push bot button
* Updated event api 
* Removed target evaluation logic

# 5.1.8
## Bug fixes
* Fixed int overflow issue for requestId
* Adjusted navigation margin 

# 5.1.6
## Bug fixes
* Fixed onReceivePush call multiple times

# 5.1.5
## Bug fixes
* Fixed to apply locale setting properly
* Refactored chat notification view reusability

# 5.1.4
## Bug fixes
* Displayed status bar properly and fixed freezing on chat view

# 5.1.3
## Bug fixes
* Hided in-app push notification after handled redirect url

# 5.1.2
## Bug fixes 
* Updated dependencies and structures to work with Carthage properly

# 5.1.0
## Updates
* Added `canShowLauncher` for custom launcher

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
