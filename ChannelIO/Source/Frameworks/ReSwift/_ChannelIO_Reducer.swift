//
//  Reducer.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/14/15.
//  Copyright © 2015 ReSwift Community. All rights reserved.
//

typealias ReSwift_Reducer<ReducerStateType> =
    (_ action: ReSwift_Action, _ state: ReducerStateType?) -> ReducerStateType
