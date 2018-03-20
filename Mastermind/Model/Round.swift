//
//  Round.swift
//  Mastermind
//
//  Created by Sébastien Gaya on 20/03/2018.
//  Copyright © 2018 Sébastien Gaya. All rights reserved.
//

import Foundation

class Round {
    var userCombination: [Int?]
    var placedCount: Int?
    var misplacedCount: Int?
    var selectedIndex: Int = 0
    
    init() {
        self.userCombination = [nil, nil, nil, nil]
    }
}
