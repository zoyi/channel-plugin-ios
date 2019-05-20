//
//  DateUtilsTests.swift
//  ChannelIOTests
//
//  Created by Haeun Chung on 20/05/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Quick
import Nimble
//import RxSwift
//import ReSwift

@testable import ChannelIO

class DateUtilsTests: QuickSpec {
  override func spec() {
    describe("date extension") {
      context("date in minutes") {
        it("should return today as minutes") {
          var date = Date.from(dateString: "2019-05-20 12:00:00")
          expect(date?.minutes).to(equal(720))
          
          date = Date.from(dateString: "2019-05-20 01:30:00")
          expect(date?.minutes).to(equal(90))
        }
      }

      context("string to date") {
        it("should convert string date properly") {
          let date = Date.from(dateString: "2019-05-20 12:00:00")
          expect(date).notTo(beNil())
        }
      }

      context("invalid string to date") {
        it("should return nil with invalid date string") {
          let date = Date.from(dateString: "2019-05-20")
          expect(date).to(beNil())
        }
      }

      context("next date to target date") {
        it("get next monday date") {
          let weekday = Weekday.mon
          let minutes = 720
          guard let date = Date.from(dateString: "2019-05-20 12:00:00") else {
            assert(false)
            return
          }
          guard let result = date.next(weekday: weekday, mintues: minutes) else {
            assert(false)
            return
          }

          let components = Calendar.current.dateComponents([.weekday, .hour], from: result)
          expect(components.weekday).to(equal(Weekday.mon.toIndex))
          expect(components.hour).to(equal(12))
        }
      }

      context("diff two dates") {
        it("should output with correct diff") {
          guard let date1 = Date.from(dateString: "2019-05-20 12:00:00") else {
            assert(false)
            return
          }
          guard let date2 = Date.from(dateString: "2019-05-23 09:00:00") else {
            assert(false)
            return
          }

          let diff = date1.diff(from: date2, components: [.weekday, .hour, .minute])
          expect(diff.weekday).to(equal(2))
          expect(diff.hour).to(equal(21))
          expect(diff.minute).to(equal(0))
        }
      }

      context("convert time zone") {
        it("should outout correct America New york timezone") {
          let currentTime = Date()
          if let remoteTime = currentTime.convertTimeZone(with: "America/New_York") {
            expect(remoteTime.hours - currentTime.hours).to(equal(-4))
          }
        }
      }
    }
  }
}
