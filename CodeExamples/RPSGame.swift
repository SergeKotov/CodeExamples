//
//  RSPGame.swift
//  CodeExamples
//
//  Created by Serge Kotov on 22.04.2022.
//

import Foundation

// Rock Scissors Paper Game in the form of a terminal app

// MARK: Types

protocol TextRepresentable {
    var description: String { get }
}

protocol RPSModel: TextRepresentable {
    var name: String { get }
    
    var vsTurns: [RPSShape] { get set }
    
    mutating func getShape() -> RPSShape
}

extension RPSModel {
    func greeting() {
        print("\nHey human, \(name) greeting you!")
    }
    
    func byeMessage(for humanWon: Bool) {
        let first = "\n\(name): "
        let last = humanWon ? "congratulations human, you won."
                            : "he he, you can't beat me!"
        print(first + last)
    }
    
    mutating func recordTurn(_ turn: RPSShape) {
        vsTurns.append(turn)
    }
}

enum RPSShape: Int, CaseIterable, TextRepresentable {
    case rock, scissors, paper
    
    var description: String {
        switch self {
        case .rock:     return "Rock"
        case .paper:    return "Paper"
        case .scissors: return "Scissors"
        }
    }
        
    func versus(_ vs: Self) -> RPSOutcome {
        let vs = vs.rawValue - self.rawValue
        switch vs {
        case 0:     return .draw
        case 1, -2: return .win
        default:    return .loss
        }
    }
    
    func beatedBy() -> Self {
        switch self {
        case .rock:     return .paper
        case .paper:    return .scissors
        case .scissors: return .rock
        }
    }
    
    static func random() -> Self {
        Self.allCases.randomElement()!
    }
}

enum RPSOutcome: Int, TextRepresentable {
    case draw = 0
    case win = 1
    case loss = -1
    
    var description: String {
        switch self {
        case .draw:     return "draw"
        case .win:    return "won!"
        case .loss: return "lost"
        }
    }
}

// MARK: - Game AI models

struct Aresus: RPSModel {
    let name = "ARESUS"
    let description = "Selects the next shape in a steady collection of 4 elements"
    
    var shapePool = [RPSShape]()
    var curInd = 0
    
    var vsTurns = [RPSShape]()
    
    init() {
        for _ in 1...4 {
            let randomShape = RPSShape.random()
            shapePool.append(randomShape)
        }
    }
    
    mutating func getShape() -> RPSShape {
        curInd = curInd < (shapePool.count - 1) ? curInd + 1 : 0
        return shapePool[curInd]
    }
}

struct Appolos: RPSModel {
    let name = "HERMUS"
    let description = "Mostly addressed to the last of human's turn"
    
    var vsTurns = [RPSShape]()
    
    func getShape() -> RPSShape {
        guard !vsTurns.isEmpty, chance(0.8) else {
            return RPSShape.random()
        }
        let lastTurn = vsTurns.last!
        return lastTurn.beatedBy()
    }
}

struct Hestis: RPSModel {
    let name = "HESTIS"
    let description = "Addressed against least common human move"
    
    var vsTurns = [RPSShape]()
    
    func getShape() -> RPSShape {
        guard !vsTurns.isEmpty else {
            return RPSShape.random()
        }
        let rocks = vsTurns.filter { $0 == .rock}.count
        let papers = vsTurns.filter { $0 == .paper}.count
        let scissors = vsTurns.filter { $0 == .scissors}.count
        
        let shape: RPSShape
        if rocks < papers, rocks < scissors {
            shape = .rock
        } else if papers < rocks, papers < scissors {
            shape = .paper
        } else {
            shape = chance(0.8) ? .scissors : .paper
        }
        return shape.beatedBy()
    }
}

struct Zeusus: RPSModel {
    let name = "ZEUSUS"
    let description = "Every turn selects a random shape"
    
    var vsTurns = [RPSShape]()
    
    func getShape() -> RPSShape {
        return RPSShape.random()
    }
}

let rspModelList: [Int: RPSModel] = [
    1: Aresus(),
    2: Appolos(),
    3: Hestis(),
    4: Zeusus()
]

// MARK: - RSP Game

class RPSGame {
    var aiModel: RPSModel?
    
    let maxTurns: Int
    var curTurn = 0
    var curAdvance = 0
    
    var isGaming: Bool {
        let moveRest = maxTurns - curTurn
        guard moveRest > 0 else { return false }
        
        let gameRest = moveRest - abs(curAdvance)
        return gameRest >= 0
    }
    
    init(maxTurns: Int) {
        self.maxTurns = maxTurns
    }
    
    func run() {
        print("* Rock, Scissors, Paper Game *")

        aiModel = choiceCompetitor()
        aiModel?.greeting()
        
        while isGaming {
            if let humanShape = nextTurn() {
                aiModel?.recordTurn(humanShape)
            } else {
                endGame()
            }
        }
        
        endGame(success: curAdvance > 0)
    }
    
    func endGame(success: Bool? = nil) {
        if let success = success {
            aiModel?.byeMessage(for: success)
        }
        print("Goodbye.\n")
        exit(0)
    }
    
    // MARK: Private section
    
    private func choiceCompetitor() -> RPSModel {
        // print overall list of competitor models
        print("\nMighty competitors are waiting for you:")
        let sortedList = rspModelList.sorted( by: { $0.0 < $1.0 })
        for model in sortedList {
            print("\(model.key). \(model.value.name)")
        }
        
        // enter player choice
        let count = rspModelList.count
        print("\nPlease enter your choice:")
        let readyRange = Range(1...count)
        var ind: Int? = nil
        while ind == nil {
            if let str = readLine() {
                if let num = Int(str), readyRange.contains(num) {
                    ind = num
                } else {
                    print("Please enter a number from 1 to \(count):")
                }
            } else {
                // just pressed Cntrl + D
                endGame()
            }
        }
        // it's safe to use force unwrapping on optional values here
        return rspModelList[ind!]!
    }
    
    private func nextTurn() -> RPSShape? {
        guard aiModel != nil else { return nil }
        
        curTurn += 1
        print("\nTurn # \(curTurn)")
        
        // run a battle round ai vs human
        let aiShape = aiModel!.getShape()
        let humanShape = readHumanTurn()
        let resultForHuman = humanShape.versus(aiShape)
        
        // print turn result
        print("\n   You throw \(humanShape.description)")
        print("   \(aiModel!.name) throw \(aiShape.description)")
        print("   You \(resultForHuman.description)")
        
        // end with:
        curAdvance += resultForHuman.rawValue
        print("   Game score: \(curAdvance)")
        return humanShape
    }
    
    private func readHumanTurn() -> RPSShape {
        print("Your shape: R[ock], P[aper] or S[cissors]")
        while true {
            if let str = readLine()?.uppercased() {
                let symbol = str.prefix(1)
                switch symbol {
                case "R": return .rock
                case "P": return .paper
                case "S": return .scissors
                default:
                    print("Please enter a letter: 'r', 'p' or 's'...")
                }
            } else {
                // just pressed Cntrl + D
                endGame()
            }
        }
    }
}

