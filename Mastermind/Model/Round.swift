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
    
    init(combination userCombination: [Int]) {
        self.userCombination = userCombination
    }
    
    func updateSelectedIndex() {
        if self.selectedIndex == 4 { return }
        
        var emptyIndexes = [Int]()
        for i in 0..<userCombination.count {
            if userCombination[i] == nil {
                emptyIndexes.append(i)
            }
        }
        
        let nextEmptyIndexes = emptyIndexes.filter({ (x) -> Bool in
            return x > selectedIndex
        })
        
        if emptyIndexes.isEmpty && selectedIndex < 4 {
            selectedIndex += 1
        } else {
            if nextEmptyIndexes.isEmpty {
                selectedIndex = emptyIndexes[0]
            } else {
                selectedIndex = nextEmptyIndexes[0]
            }
        }
    }
}
