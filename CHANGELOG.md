# 3.0.1 (Apr 15, 2018)
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
