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
            XCTAssert(false)
            return
          }
          guard let result = date.next(weekday: weekday, mintues: minutes) else {
            XCTAssert(false)
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
            XCTAssert(false)
            return
          }
          guard let date2 = Date.from(dateString: "2019-05-23 09:00:00") else {
            XCTAssert(false)
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
        
        it("should outout correct Asia/Seoul GMT+9 timezone") {
          let currentTime = Date()
          if let remoteTime = currentTime.convertTimeZone(with: "ETC/GMT+9") {
            expect(remoteTime.hours - currentTime.hours).to(equal(-9))
          }
        }
        
        it("should output correct Asia/Seoul GMT+9 timezone") {
          let currentTime = Date()
          if let remoteTime = currentTime.convertTimeZone(with: "GMT+9") {
            expect(remoteTime.hours - currentTime.hours).to(equal(-9))
          }
        }
        
        it("should outout nil with invalid format") {
          let currentTime = Date()
          let remoteTime = currentTime.convertTimeZone(with: "GMT9")
          expect(remoteTime).to(beNil())
        }
        
        it("should output same time with current calendar") {
          let currentTime = Date()
          let remoteTime = currentTime.convertTimeZone(with: "Asia/Seoul")
          expect(remoteTime).to(equal(currentTime))
        }
      }
      
      context("Weekday emum") {
        it("should return valid index with given weekday") {
          expect(Weekday.sun.toIndex).to(equal(1))
          expect(Weekday.mon.toIndex).to(equal(2))
          expect(Weekday.tue.toIndex).to(equal(3))
          expect(Weekday.wed.toIndex).to(equal(4))
          expect(Weekday.thu.toIndex).to(equal(5))
          expect(Weekday.fri.toIndex).to(equal(6))
          expect(Weekday.sat.toIndex).to(equal(7))
        }
        
        it("should return valid weekday with given index") {
          expect(Weekday.toWeekday(from: 1)).to(equal(.sun))
          expect(Weekday.toWeekday(from: 2)).to(equal(.mon))
          expect(Weekday.toWeekday(from: 3)).to(equal(.tue))
          expect(Weekday.toWeekday(from: 4)).to(equal(.wed))
          expect(Weekday.toWeekday(from: 5)).to(equal(.thu))
          expect(Weekday.toWeekday(from: 6)).to(equal(.fri))
          expect(Weekday.toWeekday(from: 7)).to(equal(.sat))
          expect(Weekday.toWeekday(from: 9)).to(equal(.mon))
        }
      }
      
      context("empty weekday dictionary") {
        it("should return empty weekday dictionary") {
          let empty = DateUtils.emptyArrayWithWeekday()
          expect(empty.keys.count).to(equal(7))
          for (_, range) in empty {
            expect(range.count).to(equal(0))
          }
        }
      }
      
      context("merge two time ranges") {
        it("should perform merging ranges properly") {
          let result = DateUtils.merge(ranges:[[3, 5], [1, 4], [7, 9], [5, 6], [9, 13]])
          let expectValues: [TimeRange] = [[1, 6], [7 , 13]]
          let singleRange: TimeRange = [0, 1]
          
          expect(result).to(contain(expectValues))
          expect(DateUtils.merge(ranges: [])).to(beEmpty())
          expect(DateUtils.merge(ranges: [singleRange])).to(contain(singleRange))
        }
      }
      
      context("substract two time ranges") {
        it("should return properly substract on each rnage") {
          let result = DateUtils.substract(
            ranges: [[1, 4], [6, 10]],
            otherRanges: [[2, 3], [5, 8]]
          )
          
          let expectValues: [TimeRange] = [[1, 2], [3, 4], [8, 10]]
        
          expect(result).to(contain(expectValues))
          expect(DateUtils.substract(ranges: [], otherRanges: [])).to(beEmpty())
          
          let result2 = DateUtils.substract(
            ranges: [[1, 4], [6, 10], [2, 5], [10, 14], [4, 8], [2, 3], [17, 22]],
            otherRanges: [[11, 19], [2, 3], [21, 30]]
          )
          
          let expectValues2: [TimeRange] = [[1, 2], [3, 11], [19, 21]]

          expect(result2).to(contain(expectValues2))
        }
      }
      
      context("get closest time range") {
        it("should return correct time range with given date") {
          guard let date = Date.from(dateString: "2019-04-08 23:00:00") else {
            XCTAssert(false)
            return
          }
          let expectValue: (Weekday, Int) = (.wed, 600)
          let result = DateUtils.getClosestTimeFromWeekdayRange(
            date: date,
            weekdayRange: [
              .mon: [[600, 1200]],
              .tue: [],
              .wed: [[600, 1200]],
              .thu: [],
              .fri: [],
              .sat: [],
              .sun: []
            ]
          )
          
          expect(result).notTo(beNil())
          expect(result! == expectValue).to(beTrue())
        }
      }
    
    }
  }
}
