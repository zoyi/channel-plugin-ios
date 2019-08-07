//
//  ChannelTests.swift
//  CHPlugin
//
//  Created by R3alFr3e on 2/11/17.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Quick
import Nimble

@testable import ChannelIO

class ChannelTests: QuickSpec {
  
  override func spec() {
    
    describe("creation") {
      context("when using default constructor") {
        it("should contain default values") {
          let channel = CHChannel()
          expect(channel.id).to(equal(""))
          
          expect(channel.avatarUrl).to(beNil())
          expect(channel.initial).to(equal(""))
          expect(channel.color).to(equal(""))
          
          expect(channel.name).to(equal(""))
          expect(channel.domain).to(equal(""))
          expect(channel.country).to(equal(""))
          expect(channel.desc).to(equal(""))
          expect(channel.defaultPluginId).to(equal(""))
          expect(channel.textColor).to(equal("white"))
          expect(channel.working).to(beTrue())
          expect(channel.workingTime).to(beNil())
          expect(channel.lunchTime).to(beNil())
          expect(channel.phoneNumber).to(beNil())
          expect(channel.requestGuestInfo).to(beTrue())
          expect(channel.messengerPlan).to(equal(ChannelPlanType.pro))
          expect(channel.pushBotPlan).to(equal(ChannelPlanType.pro))
          expect(channel.supportBotPlan).to(equal(ChannelPlanType.none))
          expect(channel.blocked).to(beFalse())
          expect(channel.homepageUrl).to(equal(""))
          expect(channel.expectedResponseDelay).to(equal(""))
          expect(channel.timeZone).to(equal(""))
          expect(channel.utcOffset).to(equal(""))
          expect(channel.awayOption).to(equal(ChannelAwayOptionType.active))
          expect(channel.workingType).to(equal(ChannelWorkingType.always))
          expect(channel.trial).to(beTrue())
          expect(channel.trialEndDate).to(beNil())
        }
      }
      
      context("when using custom constructor") {
        it("should contain proper values") {
          let channel = CHChannel(id: "1", avatarUrl: "www.test.com", initial: "test_init", color: "test_color", name: "test", domain: "www.test.com", country: "test_country", desc: "", defaultPluginId: "2", textColor: "black", working: false, workingTime: nil, lunchTime: nil, phoneNumber: "12341234", requestGuestInfo: false, messengerPlan: ChannelPlanType.standard, pushBotPlan: ChannelPlanType.standard, supportBotPlan: ChannelPlanType.standard, blocked: true, homepageUrl: "www.test.com", expectedResponseDelay: "test_delay", timeZone: "test_timezone", utcOffset: "teset_offset", awayOption: ChannelAwayOptionType.disabled, workingType: ChannelWorkingType.custom, trial: false, trialEndDate: nil)
          
          expect(channel.id).to(equal("1"))
          
          expect(channel.avatarUrl).to(equal("www.test.com"))
          expect(channel.initial).to(equal("test_init"))
          expect(channel.color).to(equal("test_color"))
          
          expect(channel.name).to(equal("test"))
          expect(channel.domain).to(equal("www.test.com"))
          expect(channel.country).to(equal("test_country"))
          expect(channel.desc).to(equal(""))
          expect(channel.defaultPluginId).to(equal("2"))
          expect(channel.textColor).to(equal("black"))
          expect(channel.working).to(beFalse())
          expect(channel.workingTime).to(beNil())
          expect(channel.lunchTime).to(beNil())
          expect(channel.phoneNumber).to(equal("12341234"))
          expect(channel.requestGuestInfo).to(beFalse())
          expect(channel.messengerPlan).to(equal(ChannelPlanType.standard))
          expect(channel.pushBotPlan).to(equal(ChannelPlanType.standard))
          expect(channel.supportBotPlan).to(equal(ChannelPlanType.standard))
          expect(channel.blocked).to(beTrue())
          expect(channel.homepageUrl).to(equal("www.test.com"))
          expect(channel.expectedResponseDelay).to(equal("test_delay"))
          expect(channel.timeZone).to(equal("test_timezone"))
          expect(channel.utcOffset).to(equal("teset_offset"))
          expect(channel.awayOption).to(equal(ChannelAwayOptionType.disabled))
          expect(channel.workingType).to(equal(ChannelWorkingType.custom))
          expect(channel.trial).to(beFalse())
          expect(channel.trialEndDate).to(beNil())
        }
      }
    }
    
    describe("correct result by value") {
      var channel: CHChannel!
      beforeEach {
        channel = CHChannel()
      }
      
      describe("defaultPluginLink") {
        context("when domain is empty") {
          it("return link with empty domain") {
            expect(channel.defaultPluginLink).to(equal(".channel.io"))
          }
        }
        
        context("when domain is not empty") {
          it("return link with channel domain") {
            channel.domain = "test_domain"
            expect(channel.defaultPluginLink).to(equal("test_domain.channel.io"))
          }
        }
      }
      
      describe("canUseSDK") {
        context("if channel is not block") {
          beforeEach {
            channel.blocked = false
          }
          context("when trial") {
            beforeEach {
              channel.trial = true
            }
            it("return true") {
              channel.messengerPlan = .none
              expect(channel.canUseSDK).to(beTrue())
              
              channel.messengerPlan = .standard
              expect(channel.canUseSDK).to(beTrue())
              
              channel.messengerPlan = .pro
              expect(channel.canUseSDK).to(beTrue())
            }
          }
          
          context("when not trial") {
            beforeEach {
              channel.trial = false
            }
            context("plan is pro") {
              it("return true") {
                channel.messengerPlan = .pro
                expect(channel.canUseSDK).to(beTrue())
              }
            }
            
            context("plan is not pro") {
              it("return false") {
                channel.messengerPlan = .standard
                expect(channel.canUseSDK).to(beFalse())
                
                channel.messengerPlan = .none
                expect(channel.canUseSDK).to(beFalse())
              }
            }
          }
        }
        
        context("if channel is block") {
          beforeEach {
            channel.blocked = true
          }
          context("when trial") {
            beforeEach {
              channel.trial = true
            }
            it("return false") {
              channel.messengerPlan = .none
              expect(channel.canUseSDK).to(beFalse())
              
              channel.messengerPlan = .standard
              expect(channel.canUseSDK).to(beFalse())
              
              channel.messengerPlan = .pro
              expect(channel.canUseSDK).to(beFalse())
            }
          }
          
          context("when not trial") {
            beforeEach {
              channel.trial = false
            }
            it("return false") {
              channel.messengerPlan = .pro
              expect(channel.canUseSDK).to(beFalse())
              
              channel.messengerPlan = .standard
              expect(channel.canUseSDK).to(beFalse())
              
              channel.messengerPlan = .none
              expect(channel.canUseSDK).to(beFalse())
            }
          }
        }
      }
 
      describe("canUsePushBot") {
        context("if channel is not block") {
          beforeEach {
            channel.blocked = false
          }
          context("when trial") {
            beforeEach {
              channel.trial = true
            }
            it("return true") {
              channel.pushBotPlan = .none
              expect(channel.canUsePushBot).to(beTrue())
              
              channel.pushBotPlan = .standard
              expect(channel.canUsePushBot).to(beTrue())
              
              channel.pushBotPlan = .pro
              expect(channel.canUsePushBot).to(beTrue())
            }
          }
          
          context("when not trial") {
            beforeEach {
              channel.trial = false
            }
            context("plan is not none") {
              it("return true") {
                channel.pushBotPlan = .standard
                expect(channel.canUsePushBot).to(beTrue())
                
                channel.pushBotPlan = .pro
                expect(channel.canUsePushBot).to(beTrue())
              }
            }
            
            context("plan is none") {
              it("return false") {
                channel.pushBotPlan = .none
                expect(channel.canUsePushBot).to(beFalse())
              }
            }
          }
        }
        
        context("if channel is block") {
          beforeEach {
            channel.blocked = true
          }
          context("when trial") {
            beforeEach {
              channel.trial = true
            }
            it("return false") {
              channel.pushBotPlan = .none
              expect(channel.canUsePushBot).to(beFalse())
              
              channel.pushBotPlan = .standard
              expect(channel.canUsePushBot).to(beFalse())
              
              channel.pushBotPlan = .pro
              expect(channel.canUsePushBot).to(beFalse())
            }
          }
          
          context("when not trial") {
            beforeEach {
              channel.trial = false
            }
            it("return false") {
              channel.pushBotPlan = .pro
              expect(channel.canUsePushBot).to(beFalse())
              
              channel.pushBotPlan = .standard
              expect(channel.canUsePushBot).to(beFalse())
              
              channel.pushBotPlan = .none
              expect(channel.canUsePushBot).to(beFalse())
            }
          }
        }
      }
      
      describe("canUseSupportBot") {
        context("if channel is not block") {
          beforeEach {
            channel.blocked = false
          }
          context("when trial") {
            beforeEach {
              channel.trial = true
            }
            it("return true") {
              channel.supportBotPlan = .none
              expect(channel.canUseSupportBot).to(beTrue())
              
              channel.supportBotPlan = .standard
              expect(channel.canUseSupportBot).to(beTrue())
              
              channel.supportBotPlan = .pro
              expect(channel.canUseSupportBot).to(beTrue())
            }
          }
          
          context("when not trial") {
            beforeEach {
              channel.trial = false
            }
            context("plan is not none") {
              it("return true") {
                channel.supportBotPlan = .standard
                expect(channel.canUseSupportBot).to(beTrue())
                
                channel.supportBotPlan = .pro
                expect(channel.canUseSupportBot).to(beTrue())
              }
            }
            
            context("plan is none") {
              it("return false") {
                channel.supportBotPlan = .none
                expect(channel.canUseSupportBot).to(beFalse())
              }
            }
          }
        }
        
        context("if channel is block") {
          beforeEach {
            channel.blocked = true
          }
          context("when trial") {
            beforeEach {
              channel.trial = true
            }
            it("return false") {
              channel.supportBotPlan = .none
              expect(channel.canUseSupportBot).to(beFalse())
              
              channel.supportBotPlan = .standard
              expect(channel.canUseSupportBot).to(beFalse())
              
              channel.supportBotPlan = .pro
              expect(channel.canUseSupportBot).to(beFalse())
            }
          }
          
          context("when not trial") {
            beforeEach {
              channel.trial = false
            }
            it("return false") {
              channel.supportBotPlan = .pro
              expect(channel.canUseSupportBot).to(beFalse())
              
              channel.supportBotPlan = .standard
              expect(channel.canUseSupportBot).to(beFalse())
              
              channel.supportBotPlan = .none
              expect(channel.canUseSupportBot).to(beFalse())
            }
          }
        }
      }
      
      describe("shouldHideLauncher") {
        context("if awayOption is hidden") {
          beforeEach {
            channel.awayOption = .hidden
          }
          context("channel is not working") {
            it("return true") {
              channel.working = false
              expect(channel.shouldHideLauncher).to(beTrue())
            }
          }
          
          context("channel is working") {
            it("return false") {
              channel.working = true
              expect(channel.shouldHideLauncher).to(beFalse())
            }
          }
        }
        
        context("if awayOption is not hidden") {
          beforeEach {
            channel.awayOption = .active
          }
          context("channel is not working") {
            it("return false") {
              channel.working = false
              expect(channel.shouldHideLauncher).to(beFalse())
            }
          }
          
          context("channel is working") {
            it("return false") {
              channel.working = true
              expect(channel.shouldHideLauncher).to(beFalse())
            }
          }
        }
      }
      
      describe("allowNewChat") {
        context("if workingType is always") {
          beforeEach {
            channel.workingType = .always
          }
          
          context("if awayOption is active") {
            beforeEach {
              channel.awayOption = .active
            }
            it("return true") {
              expect(channel.allowNewChat).to(beTrue())
            }
          }
          
          context("if awayOption is not active") {
            beforeEach {
              channel.awayOption = .hidden
            }
            it("return true") {
              expect(channel.allowNewChat).to(beTrue())
            }
          }
        }
        
        context("if workingType is custom") {
          beforeEach {
            channel.workingType = .custom
          }
          context("if awayOption is active") {
            beforeEach {
              channel.awayOption = .active
            }
            context("channel is working") {
              beforeEach {
                channel.working = true
              }
              it("return true") {
                expect(channel.allowNewChat).to(beTrue())
              }
            }
            
            context("channel is not working") {
              beforeEach {
                channel.working = false
              }
              it("return true") {
                expect(channel.allowNewChat).to(beTrue())
              }
            }
          }
          
          context("if awayOption is not active") {
            beforeEach {
              channel.awayOption = .disabled
            }
            context("channel is working") {
              beforeEach {
                channel.working = true
              }
              it("return true") {
                expect(channel.allowNewChat).to(beTrue())
              }
            }
            
            context("channel is not working") {
              beforeEach {
                channel.working = false
              }
              it("return false") {
                expect(channel.allowNewChat).to(beFalse())
              }
            }
          }
        }
        
        context("if workingType is not always and not custom") {
          beforeEach {
            channel.workingType = .never
          }
          context("if awayOption is active") {
            beforeEach {
              channel.awayOption = .active
            }
            context("channel is working") {
              beforeEach {
                channel.working = true
              }
              it("return true") {
                expect(channel.allowNewChat).to(beTrue())
              }
            }
            
            context("channel is not working") {
              beforeEach {
                channel.working = false
              }
              it("return true") {
                expect(channel.allowNewChat).to(beTrue())
              }
            }
          }
          
          context("if awayOption is not active") {
            beforeEach {
              channel.awayOption = .disabled
            }
            context("channel is working") {
              beforeEach {
                channel.working = true
              }
              it("return true") {
                expect(channel.allowNewChat).to(beFalse())
              }
            }
            
            context("channel is not working") {
              beforeEach {
                channel.working = false
              }
              it("return false") {
                expect(channel.allowNewChat).to(beFalse())
              }
            }
          }
        }
      }
      
      describe("shouldShowWorkingTimes") {
        context("if wokingTime is nil") {
          it("return false") {
            expect(channel.shouldShowWorkingTimes).to(beFalse())
          }
        }
        
        context("if wokingTime is not nil") {
          context("workingTime count is 0") {
            it("return false") {
              expect(channel.shouldShowWorkingTimes).to(beFalse())
            }
          }
          
          context(" workingTime count is not 0") {
            beforeEach {
              var range: TimeRange = TimeRange()
              range.from = 60
              range.to = 100
              channel.workingTime = ["mon": range]
            }
            context("workingType is not custom") {
              it("return false") {
                channel.workingType = .always
                expect(channel.shouldShowWorkingTimes).to(beFalse())
              }
            }
            
            context("workingType is custom and channel is not working") {
              it("return true") {
                channel.workingType = .custom
                channel.working = false
                expect(channel.shouldShowWorkingTimes).to(beTrue())
              }
            }
            
            context("workingType is custom but channel is working") {
              it("return false") {
                channel.workingType = .custom
                channel.working = true
                expect(channel.shouldShowWorkingTimes).to(beFalse())
              }
            }
          }
        }
      }
      
      describe("isDiff") {
        beforeEach {
          channel.working = true
          channel.workingType = .custom
          channel.expectedResponseDelay = ""
        }
        
        context("if diffrent with other channel") {
          it("return true") {
            var otherChannel = CHChannel()
            otherChannel.working = false
            otherChannel.workingType = .never
            otherChannel.expectedResponseDelay = ""
            expect(channel.isDiff(from: otherChannel)).to(beTrue())
          }
        }
        
        context("if same with other channel") {
          it("return false") {
            var otherChannel = CHChannel()
            otherChannel.working = true
            otherChannel.workingType = .custom
            otherChannel.expectedResponseDelay = ""
            expect(channel.isDiff(from: otherChannel)).to(beFalse())
          }
        }
      }
      
      describe("sortedWorkingTime") {
        it("return proper ordered list") {
          expect(channel.workingTimeString).to(equal("unknown"))
          channel.workingTime = ["sat": TimeRange(from: 60, to: 100), "fri": TimeRange(from: 100, to: 160), "thu": TimeRange(from: 200, to: 260), "sun": TimeRange(from: 500, to: 1000), "tue": TimeRange(from: 1200, to: 1400)]
          expect(channel.sortedWorkingTime?.get(index: 0)?.key).to(equal("sun"))
          expect(channel.sortedWorkingTime?.get(index: 1)?.key).to(equal("tue"))
          expect(channel.sortedWorkingTime?.get(index: 2)?.key).to(equal("thu"))
          expect(channel.sortedWorkingTime?.get(index: 3)?.key).to(equal("fri"))
          expect(channel.sortedWorkingTime?.get(index: 4)?.key).to(equal("sat"))
        }
      }
      
      describe("workingTimeString") {
        context("if workingTime is nil") {
          it("return unknown") {
            expect(channel.workingTimeString).to(equal("unknown"))
          }
        }
        
        context("if workingTime exist") {
          it("retrn sorted proper string") {
            channel.workingTime = ["sat": TimeRange(from: 60, to: 100), "fri": TimeRange(from: 100, to: 160), "thu": TimeRange(from: 200, to: 260), "sun": TimeRange(from: 500, to: 1000), "tue": TimeRange(from: 1200, to: 1400)]
            expect(channel.workingTimeString).to(equal("일 - 8:20AM ~ 4:40PM\n화 - 8:00PM ~ 11:20PM\n목 - 3:20AM ~ 4:20AM\n금 - 1:40AM ~ 2:40AM\n토 - 1:00AM ~ 1:40AM"))
          }
        }
      }
      
      describe("closestWorkingTime") {
        var time: Date!
        beforeEach {
          let date = DateFormatter()
          date.dateFormat = "yyyy-MM-dd HH:mm:ss"
          date.timeZone = TimeZone(abbreviation: "UTC")
          time = date.date(from: "2019-08-05 09:07:27")
        }
        context("if has valid values") {
          it("return next weekday and hour left") {
            channel.workingType = .custom
            channel.timeZone = "UTC"
            channel.workingTime = ["sat": TimeRange(from: 60, to: 100), "fri": TimeRange(from: 100, to: 160), "thu": TimeRange(from: 200, to: 260), "sun": TimeRange(from: 500, to: 1000), "tue": TimeRange(from: 1200, to: 1400)]
            expect(channel.closestWorkingTime(from: time) == nil).to(beFalse())
          }
        }
        
        context("if custom and not working") {
          it("return nil") {
            channel.workingType = .custom
            channel.working = false
            expect(channel.closestWorkingTime(from: time)).to(beNil())
          }
        }
        
        context("if next working hour is only available on same weekday") {
          it("return next coming same weekday") {
            
          }
        }
      }
    }
  }
}
