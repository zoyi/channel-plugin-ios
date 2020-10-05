//
//  ScheduledItemType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 11/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

protocol _RXSwift_ScheduledItemType
    : _RXSwift_Cancelable
    , _RXSwift_InvocableType {
    func invoke()
}
