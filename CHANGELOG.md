# Change Log
----
### 2.1.0
#### Updated
* Added `didClickOn:` delegate method 

#### Bug fixes
* Fixed channel open properly after duplicated checkin 
* Fixed minor bugs 

### 2.0.5
* Fixed minor bugs
* PhoneNumberKit to 2.0 (Swift 4.0)

### 2.0.4
* Fixed minor bugs

### 2.0.3
* Downgraded PhoneNumberKit to 1.4 (compatibility issue)

### 2.0.2
* iOS 11 migration
* Changed name `trackCheckIn` -> `enabledTrackDefaultEvent`
* enabled `bitcode` feature

### 2.0.1
* Updated Framework version string

### 2.0.0 (Sep 8, 2017)
* BREAKING CHANGE: Renamed some properties and methods
* Introduced new method `track` to send event to channel
* Fixed minor bugs

### 1.1.1
* Fixed message height calculation

### 1.1.0
#### Updated
* Updated socket io v2
* Added StarstreamSocketIO framework to support socket v2
* If incoming push is same chat as current chat, It won't push new chat but update
* Removed unused 'isVisible' property

#### Bug fixes
* Fixed html unescaped for welcome message
* Fixed link color
* Fixed off by one error for new message label
* Fixed badge count issues when launched app with push notification
* Fixed name/phone number dialog layout and localizations
* Fixed background layout for phone number picker view
* Fixed font size for in-app chat notification

### 1.0.5
* Updated UIState in redux correctly
* Reversed photo indexes

### 1.0.4
* Fixed duplicate `show:` method

### 1.0.3
* Added in-app push notification sound
* Added sound option
* Saved closed user chat option state
* Fixed minor bugs

### 1.0.2
* Fixed deleted user chats handling
* Fixed avatar background color issue

### 1.0.1
* Added sound for in app push notification
* Added clear button in user info editing field
* Updated new chat banner UI
* Fixed layout bugs

### 1.0.0
#### Features
* Veil can now update name/phone number
* Introduced review process after finish conversation

#### Bug fixes
* Fixed UI / layout issues
* Validated when show(:) method is called
* Displayed new messages in user chat view properly

### 0.2.5
* Fixed credential errors when app become active
* Adjusted redux states

### 0.2.2
* Fixed user default key conflict
* Fixed launcher display bug

### 0.2.1
* Changed SlackTextViewController to CHSlackTextViewController to avoid conflict

### 0.2.0
#### Improvement
* Redesinged profile view (top left of chat list)
* Added Error toast
* Changed launcher icon
* Optimized socket connectivity

#### Bug fixes
* Updated badge count properly when app become active from background
* Fixed session sync when app launched by clicking push notification

### 0.1.17
* Migrated to Swift 3.1
* WebSocket connect/disconnect when app state changes

### 0.1.15 (April 19, 2017)
* Fixed minor bugs
* Improved socket connectivity

### 0.1.14 (April 7, 2017)
* first beta release
