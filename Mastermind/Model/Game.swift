//
//  Game.swift
//  Mastermind
//
//  Created by Sébastien Gaya on 20/03/2018.
//  Copyright © 2018 Sébastien Gaya. All rights reserved.
//

import Foundation
import GameplayKit

class Game {
    var secretCombination: [Int]
    var rounds: [Round]
    
    init() {
        self.secretCombination = [Int]()
        self.rounds = [Round]()
        
        self.secretCombination = self.getRandomSecretCombination()
        self.rounds.append(Round())
    }
    
    func endRound() {
        if let lastRound = rounds.last, let lastUserCombination = lastRound.userCombination as? [Int] {
            let counts = self.checkCombination(lastUserCombination)
            self.updateCounts(lastRound, with: counts)
            if counts["placed"] == 4 {
                let endNotification = Notification(name: Notification.Name(rawValue: "endGame"))
                NotificationCenter.default.post(endNotification)
            } else {
                rounds.append(Round())
            }
        } else {
            let notFilledNotification = Notification(name: Notification.Name(rawValue: "combinationNotFilled"))
            NotificationCenter.default.post(notFilledNotification)
        }
    }
    
    private func getRandomSecretCombination() -> [Int] {
        var secretCombination = [Int]()
        for _ in 0..<4 {
            secretCombination.append(GKRandomSource.sharedRandom().nextInt(upperBound: 5))
        }
        print("======================")
        print("SECRET COMBINATION : \(secretCombination)")
        print("======================")
        return secretCombination
    }
    
    private func checkCombination(_ userCombination: [Int]) -> [String: Int] {
        var placedCount = 0
        var misplacedCount = 0
        var secretCopy = secretCombination
        var userCopy = userCombination
        
        for i in 0..<secretCopy.count where secretCopy[i] == userCopy[i] {
            placedCount += 1
            secretCopy[i] = -1
            userCopy[i] = -1
        }
        
        for i in 0..<secretCopy.count {
            for j in 0..<userCopy.count where secretCopy[i] == userCopy[j] && secretCopy[i] != -1 {
                misplacedCount += 1
                secretCopy[i] = -1
                userCopy[j] = -1
            }
        }
        
        return ["placed": placedCount, "misplaced": misplacedCount]
    }
    
    private func updateCounts(_ round: Round, with counts: [String: Int]) {
        round.placedCount = counts["placed"]
        round.misplacedCount = counts["misplaced"]
        
        
    }
}
