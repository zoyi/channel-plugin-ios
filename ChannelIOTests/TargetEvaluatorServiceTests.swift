//
//  TargetEvaluatorServiceTests.swift
//  ChannelIOTests
//
//  Created by Haeun Chung on 09/11/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Quick
import Nimble
//import ReSwift

@testable import ChannelIO

class TargetEvaluatorTests: QuickSpec {

  override func spec() {
    
    describe("TargetConditions AND/OR evalutions") {
      context("given userInfo should be evaluated logical AND and OR properly") {
        let userInfo:[String: Any] = [
          TargetKey.device.rawValue: "iPhone 7",
          TargetKey.os.rawValue: "iOS 11",
          TargetKey.guestProfile.rawValue: [
            TargetKey.guestType.rawValue: "veil",
            TargetKey.guestId.rawValue: "123"
          ]
        ]
        
        let conditions: [[CHTargetCondition]] = [
          [CHTargetCondition(key: .os, value: TargetValue("iOS 11"), op: .equal, subKey: nil)],
          [CHTargetCondition(key: .device, value: TargetValue("iPhone"), op: .contain, subKey: nil)],
          [CHTargetCondition(key: .guestProfile, value: TargetValue("veil"), op: .equal, subKey: TargetSubKey(TargetKey.guestType.rawValue))]
        ]
        
        let evaluated = TargetEvaluatorService.evaluate(with: conditions, userInfo: userInfo)
        it("should be true with match all outer conditions") {
          expect(evaluated).to(beTrue())
        }
      }
    }
    
    describe("TargetConditions OR evaluation") {
      context("given matching userInfo should be evaluated logical OR") {
        let userInfo:[String: Any] = [
          TargetKey.device.rawValue: "iPhone 7",
          TargetKey.os.rawValue: "iOS 12",
          TargetKey.guestProfile.rawValue: [
            TargetKey.guestType.rawValue: "veil",
            TargetKey.guestId.rawValue: "123"
          ]
        ]
        
        let conditions: [CHTargetCondition] = [
          CHTargetCondition(key: .os, value: TargetValue("iOS 11"), op: .equal, subKey: nil),
          CHTargetCondition(key: .device, value: TargetValue("Nexus"), op: .contain, subKey: nil),
          CHTargetCondition(key: .guestProfile, value: TargetValue("veil"), op: .equal, subKey: TargetSubKey(TargetKey.guestType.rawValue))
        ]
        
        let evaluated = TargetEvaluatorService.evaluate(conditions, userInfo: userInfo)
        it("should be true with matching one of condition") {
          expect(evaluated).to(beTrue())
        }
      }
      
      context("given non-matching userInfo should be evaluated logical OR") {
        let userInfo:[String: Any] = [
          TargetKey.device.rawValue: "iPhone 7",
          TargetKey.os.rawValue: "iOS 12",
          TargetKey.guestProfile.rawValue: [
            TargetKey.guestId.rawValue: "123"
          ]
        ]
        
        let conditions: [CHTargetCondition] = [
          CHTargetCondition(key: .os, value: TargetValue("iOS 11"), op: .equal, subKey: nil),
          CHTargetCondition(key: .device, value: TargetValue("Nexus"), op: .contain, subKey: nil),
          CHTargetCondition(key: .guestProfile, value: TargetValue("veil"), op: .equal, subKey: TargetSubKey(TargetKey.guestType.rawValue))
        ]
        
        let evaluated = TargetEvaluatorService.evaluate(conditions, userInfo: userInfo)
        it("should be false with matching none of condition") {
          expect(evaluated).to(beFalse())
        }
      }
    }
    
    describe("TargetCondition evaluation") {
      context("target with given userInfo should be evaluated properly") {
        let userInfo:[String: Any] = [
          TargetKey.device.rawValue: "iPhone 6",
          TargetKey.deviceCategory.rawValue: "mobile",
          TargetKey.os.rawValue: "iOS 10"
        ]
        
        var targetCondition = CHTargetCondition()
        targetCondition.key = .os
        targetCondition.value = "iOS 11"
        targetCondition.op = .equal
        
        let evaluated = TargetEvaluatorService.evaluate(
          with: targetCondition, userInfo: userInfo
        )
        
        it("should be not match with given different os version") {
          expect(evaluated).to(beFalse())
        }
      }
      
      context("target with given userInfo should be evaluated properly") {
        let userInfo:[String: Any] = [
          TargetKey.device.rawValue: "iPhone 6",
          TargetKey.deviceCategory.rawValue: "mobile",
          TargetKey.os.rawValue: "iOS 10"
        ]
        
        var targetCondition = CHTargetCondition()
        targetCondition.key = .os
        targetCondition.value = "iOS 10"
        targetCondition.op = .equal
        
        let evaluated = TargetEvaluatorService.evaluate(
          with: targetCondition, userInfo: userInfo
        )
        
        it("should be match with given same os version") {
          expect(evaluated).to(beTrue())
        }
      }
    }
    
    describe("Operators") {
      context("greaterThan should perform correctly") {
        it("should be true with decimal point greater") {
          expect(TargetEvaluatorService.evaluate(
            with: .greaterThan,
            conditionValue: "100",
            value: "100.1"))
            .to(beTrue())
        }
        
        it("should be true with int point greater") {
          expect(TargetEvaluatorService.evaluate(
            with: .greaterThan,
            conditionValue: "1001",
            value: "1002"))
            .to(beTrue())
        }
        
        it("should be true with more than one precision of decimal") {
          expect(TargetEvaluatorService.evaluate(
            with: .greaterThan,
            conditionValue: "100.123",
            value: "100.125"))
            .to(beTrue())
        }
      }

      context("greaterThanOrEqual should perform correctly") {
        it("should be true with decimal point greater") {
          expect(TargetEvaluatorService.evaluate(
            with: .greaterThanOrEqual,
            conditionValue: "100.1",
            value: "100.1"))
            .to(beTrue())
        }
        
        it("should be true with int point greater") {
          expect(TargetEvaluatorService.evaluate(
            with: .greaterThanOrEqual,
            conditionValue: "1001",
            value: "1001.0"))
            .to(beTrue())
        }
        
        it("should be true with more than one precision of decimal") {
          expect(TargetEvaluatorService.evaluate(
            with: .greaterThanOrEqual,
            conditionValue: "100.123",
            value: "100.43"))
            .to(beTrue())
        }
      }

      context("lessThan should perform correctly") {
        it("should be true with decimal point less") {
          expect(TargetEvaluatorService.evaluate(
            with: .lessThan,
            conditionValue: "100.1",
            value: "100.0"))
            .to(beTrue())
        }
        
        it("should be false with same values") {
          expect(TargetEvaluatorService.evaluate(
            with: .lessThan,
            conditionValue: "1001",
            value: "1001.0"))
            .to(beFalse())
        }

        it("should be false with same decimal point values") {
          expect(TargetEvaluatorService.evaluate(
            with: .lessThan,
            conditionValue: "100.101",
            value: "100.101"))
            .to(beFalse())
        }
      }
      
      context("lessThanOrEqual should perform correctly") {
        it("should be true with decimal point less") {
          expect(TargetEvaluatorService.evaluate(
            with: .lessThanOrEqual,
            conditionValue: "100.02",
            value: "100.01"))
            .to(beTrue())
        }
        
        it("should be true with same values") {
          expect(TargetEvaluatorService.evaluate(
            with: .lessThanOrEqual,
            conditionValue: "1001",
            value: "1001.0"))
            .to(beTrue())
        }
        
        it("should be true with decimal point values less") {
          expect(TargetEvaluatorService.evaluate(
            with: .lessThanOrEqual,
            conditionValue: "100.101",
            value: "100.001"))
            .to(beTrue())
        }
      }

      context("Contains should perform correctly") {
        it("should be true when exactly matched") {
          expect(TargetEvaluatorService.evaluate(
            with: .contain,
            conditionValue: "abc",
            value: "abc"))
            .to(beTrue())
        }
      
        it("should be false if different values") {
          expect(TargetEvaluatorService.evaluate(
            with: .contain,
            conditionValue: "abcde",
            value: "abc"))
            .to(beFalse())
        }
        
        it("should be false if different values") {
          expect(TargetEvaluatorService.evaluate(
            with: .contain,
            conditionValue: "abc",
            value: "abcde"))
            .to(beTrue())
        }
      }
      
      context("Exist should perform correctly") {
        it("should be true if value exists") {
          expect(TargetEvaluatorService.evaluate(
            with: .exist,
            conditionValue: "",
            value: "abc"))
            .to(beTrue())
        }
        
        it("should be false when value is not present") {
          expect(TargetEvaluatorService.evaluate(
            with: .contain,
            conditionValue: "",
            value: nil))
            .to(beFalse())
        }
        
        it("should be true if value exists") {
          expect(TargetEvaluatorService.evaluate(
            with: .contain,
            conditionValue: "abc",
            value: "abcde"))
            .to(beTrue())
        }
      }
   
      context("notExist should perform correctly") {
        it("should be false when value exists") {
          expect(TargetEvaluatorService.evaluate(
            with: .notExist,
            conditionValue: "",
            value: "abc"))
            .to(beFalse())
        }
        
        it("should be true if value is not present") {
          expect(TargetEvaluatorService.evaluate(
            with: .notExist,
            conditionValue: "",
            value: nil))
            .to(beTrue())
        }
        
        it("should be false if value exists") {
          expect(TargetEvaluatorService.evaluate(
            with: .notExist,
            conditionValue: "abc",
            value: "abcde"))
            .to(beFalse())
        }
      }

      context("Prefix should perform correctly"){
        it("should be true if empty prefix") {
          expect(TargetEvaluatorService.evaluate(
            with: .prefix,
            conditionValue: "",
            value: "abc"))
            .to(beTrue())
        }
        
        it("should be true with identifical prefix") {
          expect(TargetEvaluatorService.evaluate(
            with: .prefix,
            conditionValue: "ab",
            value: "abcaa"))
            .to(beTrue())
        }
        
        it("sholud be false with different prefix") {
          expect(TargetEvaluatorService.evaluate(
            with: .prefix,
            conditionValue: "abc",
            value: "bcdd"))
            .to(beFalse())
        }
      }

      context("notPrefix should perform correctly"){
        it("should be true with different prefix") {
          expect(TargetEvaluatorService.evaluate(
            with: .notPrefix,
            conditionValue: "bb",
            value: "abc"))
            .to(beTrue())
        }
        
        it("should be false with same prefix") {
          expect(TargetEvaluatorService.evaluate(
            with: .notPrefix,
            conditionValue: "ab",
            value: "abcaa"))
            .to(beFalse())
        }
        
        it("should be true with different prefix") {
          expect(TargetEvaluatorService.evaluate(
            with: .notPrefix,
            conditionValue: "abc",
            value: "bcdd"))
            .to(beTrue())
        }
      }
    }
  }
}
