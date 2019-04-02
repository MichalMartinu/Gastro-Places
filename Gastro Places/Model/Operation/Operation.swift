//
//  OperationState.swift
//  Gastro Places
//
//  Created by Michal Martinů on 02/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import Foundation

enum OperationState {
    case Ready, Executing, Finished, Failed, Canceled
}

class Operation {
    var state = OperationState.Ready
}
