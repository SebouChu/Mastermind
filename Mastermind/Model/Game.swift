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
    enum Color: Int {
        case red = 0, green = 1, blue = 2, yellow = 3, black = 4, white = 5
        
        func image() -> UIImage {
            switch self {
            case .red:
                return UIImage(named: "red")!
            case .green:
                return UIImage(named: "green")!
            case .blue:
                return UIImage(named: "blue")!
            case .yellow:
                return UIImage(named: "yellow")!
            case .black:
                return UIImage(named: "black")!
            case .white:
                return UIImage(named: "white")!
            }
        }
        
        static func allValues() -> [Color] {
            var colors = [Color]()
            for i in 0...5 {
                colors.append(Color(rawValue: i)!)
            }
            return colors
        }
    }
    
    var secretCombination: [Int]
    var rounds: [Round]
    var aiRounds: [Round]
    var timestamp = 0
    
    var userCombinations: [[Int]] {
        get {
            var combinations = [[Int]]()
            for round in rounds {
                if let combination = round.userCombination as? [Int] {
                    combinations.append(combination)
                }
            }
            return combinations
        }
    }
    
    init() {
        self.secretCombination = [Int]()
        self.rounds = [Round]()
        self.aiRounds = [Round]()
        
        self.secretCombination = self.getRandomSecretCombination()
        self.rounds.append(Round())
        self.aiRounds.append(Round())
        
        getAISolve()
    }
    
    init(secret secretCombination: [Int], combinations userCombinations: [[Int]], timestamp: Int) {
        self.secretCombination = secretCombination
        self.timestamp = timestamp
        
        self.rounds = [Round]()
        
        self.aiRounds = [Round]()
        self.aiRounds.append(Round())
        
        for userCombination in userCombinations {
            let round = Round(combination: userCombination)
            let result = self.checkCombination(userCombination)
            round.placedCount = result["placed"]
            round.misplacedCount = result["misplaced"]
            rounds.append(round)
        }
    }
    
    func endRound() {
        if let lastRound = rounds.last, let lastUserCombination = lastRound.userCombination as? [Int] {
            let counts = self.checkCombination(lastUserCombination)
            self.updateCounts(lastRound, with: counts)
            if counts["placed"] == 4 {
                self.timestamp = Int(Date().timeIntervalSince1970)
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
            secretCombination.append(GKRandomSource.sharedRandom().nextInt(upperBound: 6))
        }
        print("======================")
        print("SECRET COMBINATION : \(secretCombination)")
        print("======================")
        return secretCombination
    }
    
    private func checkCombination(_ userCombination: [Int], asAI: Bool = false) -> [String: Int] {
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
    
        if asAI {
            //print("Avec \(userCombination) | Good : \(placedCount) / Almost Good : \(misplacedCount)")
            aiRounds.last!.userCombination = userCombination
            aiRounds.last!.placedCount = placedCount
            aiRounds.last!.misplacedCount = misplacedCount
            
            if placedCount != 4 {
                aiRounds.append(Round())
            }
        }
        
        return ["placed": placedCount, "misplaced": misplacedCount]
    }
    
    func getAISolve(verbose: Bool = false) {
        let mastermindColors = Game.Color.allValues()
        
        var secretComposition = [Int]()
        var secretHisto = [Int: Int]()
        var testCombination = [Int]()
        var lastCompoElements = [Int]()
        
        var unusedColor : Int = -1
        
        // En cas de deux fois même couleur
        var twiceColor: Int = -1
        var doubleTwice: Bool = false
        
        // En cas de trois fois même couleur
        var threeTimesColor: Int = -1
        
        // On teste chaque couleur. On détermine la composition et une couleur non utilisée
        if verbose { print("## DEBUT DES TESTS DE CHAQUE COULEUR ##") }
        for i in 0..<mastermindColors.count {
            let color = mastermindColors[i]
            let fullColorCombination = [color.rawValue, color.rawValue, color.rawValue, color.rawValue]
            let fullColorResponse = checkCombination(fullColorCombination, asAI: true)
            if fullColorResponse["placed"] == 4 {
                return
            } else if fullColorResponse["placed"] == 0 {
                if unusedColor == -1 {
                    unusedColor = color.rawValue
                }
            } else {
                secretHisto[color.rawValue] = fullColorResponse["placed"]
                if fullColorResponse["placed"]! == 2 {
                    if twiceColor == -1 {
                        twiceColor = color.rawValue
                    } else {
                        doubleTwice = true
                    }
                }
                if fullColorResponse["placed"]! == 3 {
                    threeTimesColor = color.rawValue
                }
                for _ in 1...fullColorResponse["placed"]! {
                    secretComposition.append(color.rawValue)
                }
            }
            if secretComposition.count == 4 {
                break
            } else if secretComposition.count <= 3 && i == mastermindColors.count - 2 {
                let lastColorCount = 4 - secretComposition.count
                secretHisto[mastermindColors.last!.rawValue] = lastColorCount
                
                if lastColorCount == 2 {
                    if twiceColor == -1 {
                        twiceColor = mastermindColors.last!.rawValue
                    } else {
                        doubleTwice = true
                    }
                }
                if lastColorCount == 3 {
                    threeTimesColor = mastermindColors.last!.rawValue
                }
                
                while secretComposition.count < 4 {
                    secretComposition.append(mastermindColors.last!.rawValue)
                }
                break
            }
        }
        
        if verbose {
            print("> Composition is : \(secretComposition) <")
            print("## FIN DES TESTS DE CHAQUE COULEUR ##")
            print("")
            print("")
        }
        
        if threeTimesColor != -1 {
            // Une couleur apparaît trois fois
            if verbose { print("## DEBUT DE RESOLUTION (3 TIMES COLOR) ##") }
            var uniqueColor = -1
            for number in secretComposition {
                if number != threeTimesColor {
                    uniqueColor = number
                    break
                }
            }
            testCombination = [uniqueColor, threeTimesColor, threeTimesColor, threeTimesColor]
            var currentUniqueIndex = 0
            var goodCombination = false
            while (!goodCombination) {
                let testResults = checkCombination(testCombination, asAI: true)
                if testResults["placed"]! == 4 {
                    goodCombination = true
                } else {
                    testCombination.swapAt(currentUniqueIndex, currentUniqueIndex+1)
                    currentUniqueIndex += 1
                }
            }
            if verbose { print("## FIN DE RESOLUTION (3 TIMES COLOR) ##") }
        } else {
            var oldTestCombination = [Int]()
            
            var hasTwoGoodColors = false // Signale deux bonnes couleurs
            var hadOneGood = false // Signale une bonne couleur sur le tour précédent
            var didInvertedColors = false // Signale une inversion des couleurs sur le tour précédent
            var didReversedCombination = false // Signale une inversion deux par deux sur le tour précédent
            var firstGoodColor = -1 // Valeur de la première bonne couleur
            
            if doubleTwice {
                // Deux couleurs en double
                if verbose { print("## DEBUT DE RESOLUTION AVEC 2 COULEURS 2X ##") }
                testCombination = [secretComposition[0], secretComposition[2]]
                lastCompoElements = [secretComposition[1], secretComposition[3]]
            } else if twiceColor != -1 {
                // Une couleur en double
                if verbose { print("## DEBUT DE RESOLUTION AVEC COULEUR 2X ##") }
                var uniqueIndexes = [Int]()
                for i in 0..<secretComposition.count where secretComposition[i] != twiceColor {
                    uniqueIndexes.append(i)
                }
                testCombination = [secretComposition[uniqueIndexes[0]], secretComposition[uniqueIndexes[1]]]
                lastCompoElements = [twiceColor, twiceColor]
            } else {
                // Résolution de base
                if verbose { print("## DEBUT DE RESOLUTION DE BASE ##") }
                testCombination = [secretComposition[0], secretComposition[1]]
                lastCompoElements = [secretComposition[2], secretComposition[3]]
            }
            
            for _ in 0...1 {
                testCombination.append(unusedColor)
            }
            
            // On cherche à avoir deux bonnes couleurs
            while (!hasTwoGoodColors) {
                let testResults = checkCombination(testCombination, asAI: true)
                if testResults["placed"]! == 2 {
                    // Deux bonnes couleurs
                    hasTwoGoodColors = true
                } else if testResults["placed"]! == 1 {
                    // Une bonne couleur, on teste si deuxième pas bonne
                    oldTestCombination = testCombination
                    if !hadOneGood {
                        // Pas de bonne couleur avant
                        hadOneGood = true
                        testCombination.swapAt(1, 2)
                    } else {
                        // Une bonne couleur avant
                        if firstGoodColor == -1 {
                            // Bonne couleur à l'index 0
                            firstGoodColor = testCombination[0]
                        }
                        testCombination.swapAt(2, 3)
                    }
                    
                } else {
                    // Pas de bonne couleur
                    if !hadOneGood {
                        // Aucune bonne couleur avant
                        oldTestCombination = testCombination
                        
                        if !didInvertedColors {
                            // Tentative d'inversion des couleurs
                            if didReversedCombination {
                                testCombination.swapAt(2, 3)
                            } else {
                                testCombination.swapAt(0, 1)
                            }
                            didInvertedColors = true
                        } else {
                            var unusedIndexes = [Int]()
                            for i in 0..<testCombination.count where testCombination[i] == unusedColor {
                                unusedIndexes.append(i)
                            }
                            testCombination.swapAt(0, unusedIndexes[0])
                            testCombination.swapAt(1, unusedIndexes[1])
                            didInvertedColors = false
                            didReversedCombination = true
                        }
                    } else {
                        // Une bonne couleur avant donc à l'index 1
                        testCombination = oldTestCombination
                        firstGoodColor = testCombination[1]
                        testCombination.swapAt(0, 2)
                    }
                }
            }
            
            // On teste les deux dernières couleurs
            var lastUnusedIndexes = [Int]()
            for i in 0..<testCombination.count where testCombination[i] == unusedColor {
                lastUnusedIndexes.append(i)
            }
            
            for i in 0...1 {
                testCombination[lastUnusedIndexes[i]] = lastCompoElements[i]
            }
            if twiceColor == -1 || doubleTwice {
                let testResults = checkCombination(testCombination, asAI: true)
                if testResults["placed"] != 4 {
                    // Bonne combinaison si on inverse les dernières couleurs entrées
                    testCombination.swapAt(lastUnusedIndexes[0], lastUnusedIndexes[1])
                }
            }
            
            if verbose { print("## FIN DE RESOLUTION DE BASE ##") }
        }
    }

    
    private func updateCounts(_ round: Round, with counts: [String: Int]) {
        round.placedCount = counts["placed"]
        round.misplacedCount = counts["misplaced"]
        
        
    }
}
