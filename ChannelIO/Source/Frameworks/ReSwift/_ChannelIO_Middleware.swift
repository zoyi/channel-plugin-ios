//
//  Middleware.swift
//  ReSwift
//
//  Created by Benji Encz on 12/24/15.
//  Copyright © 2015 ReSwift Community. All rights reserved.
//

typealias ReSwift_DispatchFunction = (ReSwift_Action) -> Void
typealias ReSwift_Middleware<State> = (@escaping ReSwift_DispatchFunction, @escaping () -> State?)
    -> (@escaping ReSwift_DispatchFunction) -> ReSwift_DispatchFunction
