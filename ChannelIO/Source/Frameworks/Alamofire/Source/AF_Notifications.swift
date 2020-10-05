//
//  Notifications.swift
//
//  Copyright (c) 2014-2018 Alamofire Software Foundation (http://alamofire.org/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

extension AF_Request {
    /// Posted when a `Request` is resumed. The `Notification` contains the resumed `Request`.
    static let didResumeNotification = Notification.Name(rawValue: "org.alamofire.notification.name.request.didResume")
    /// Posted when a `Request` is suspended. The `Notification` contains the suspended `Request`.
    static let didSuspendNotification = Notification.Name(rawValue: "org.alamofire.notification.name.request.didSuspend")
    /// Posted when a `Request` is cancelled. The `Notification` contains the cancelled `Request`.
    static let didCancelNotification = Notification.Name(rawValue: "org.alamofire.notification.name.request.didCancel")
    /// Posted when a `Request` is finished. The `Notification` contains the completed `Request`.
    static let didFinishNotification = Notification.Name(rawValue: "org.alamofire.notification.name.request.didFinish")

    /// Posted when a `URLSessionTask` is resumed. The `Notification` contains the `Request` associated with the `URLSessionTask`.
    static let didResumeTaskNotification = Notification.Name(rawValue: "org.alamofire.notification.name.request.didResumeTask")
    /// Posted when a `URLSessionTask` is suspended. The `Notification` contains the `Request` associated with the `URLSessionTask`.
    static let didSuspendTaskNotification = Notification.Name(rawValue: "org.alamofire.notification.name.request.didSuspendTask")
    /// Posted when a `URLSessionTask` is cancelled. The `Notification` contains the `Request` associated with the `URLSessionTask`.
    static let didCancelTaskNotification = Notification.Name(rawValue: "org.alamofire.notification.name.request.didCancelTask")
    /// Posted when a `URLSessionTask` is completed. The `Notification` contains the `Request` associated with the `URLSessionTask`.
    static let didCompleteTaskNotification = Notification.Name(rawValue: "org.alamofire.notification.name.request.didCompleteTask")
}

// MARK: -

extension Notification {
    /// The `Request` contained by the instance's `userInfo`, `nil` otherwise.
    var request: AF_Request? {
        userInfo?[String.requestKey] as? AF_Request
    }

    /// Convenience initializer for a `Notification` containing a `Request` payload.
    ///
    /// - Parameters:
    ///   - name:    The name of the notification.
    ///   - request: The `Request` payload.
    init(name: Notification.Name, request: AF_Request) {
        self.init(name: name, object: nil, userInfo: [String.requestKey: request])
    }
}

extension NotificationCenter {
    /// Convenience function for posting notifications with `Request` payloads.
    ///
    /// - Parameters:
    ///   - name:    The name of the notification.
    ///   - request: The `Request` payload.
    func postNotification(named name: Notification.Name, with request: AF_Request) {
        let notification = Notification(name: name, request: request)
        post(notification)
    }
}

extension String {
    /// User info dictionary key representing the `Request` associated with the notification.
    fileprivate static let requestKey = "org.alamofire.notification.key.request"
}

/// `EventMonitor` that provides Alamofire's notifications.
final class AlamofireNotifications: AF_EventMonitor {
    func requestDidResume(_ request: AF_Request) {
        NotificationCenter.default.postNotification(named: AF_Request.didResumeNotification, with: request)
    }

    func requestDidSuspend(_ request: AF_Request) {
        NotificationCenter.default.postNotification(named: AF_Request.didSuspendNotification, with: request)
    }

    func requestDidCancel(_ request: AF_Request) {
        NotificationCenter.default.postNotification(named: AF_Request.didCancelNotification, with: request)
    }

    func requestDidFinish(_ request: AF_Request) {
        NotificationCenter.default.postNotification(named: AF_Request.didFinishNotification, with: request)
    }

    func request(_ request: AF_Request, didResumeTask task: URLSessionTask) {
        NotificationCenter.default.postNotification(named: AF_Request.didResumeTaskNotification, with: request)
    }

    func request(_ request: AF_Request, didSuspendTask task: URLSessionTask) {
        NotificationCenter.default.postNotification(named: AF_Request.didSuspendTaskNotification, with: request)
    }

    func request(_ request: AF_Request, didCancelTask task: URLSessionTask) {
        NotificationCenter.default.postNotification(named: AF_Request.didCancelTaskNotification, with: request)
    }

    func request(_ request: AF_Request, didCompleteTask task: URLSessionTask, with error: AFError?) {
        NotificationCenter.default.postNotification(named: AF_Request.didCompleteTaskNotification, with: request)
    }
}
