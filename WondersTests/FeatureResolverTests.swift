import XCTest
@testable import Wonders

class FeatureResolverTests: XCTestCase {
    var state: GameState!
    var resolver: FeatureResolver!
    var military: Military!
    
    override func setUp() {
        super.setUp()
        state = GameState(board: Board(cards: []))
        military = Military(player1: state.player1, player2: state.player2)
        resolver = DefaultFeatureResolver(state: state, military: military)
    }
    
    func testGainGold() {
        resolver.execute(features: [.gainGold(gold: 3)])
        XCTAssertEqual(state.player1.gold , 9)
    }
    
    func testRemoveGold() {
        resolver.execute(features: [.removeGold(gold: 3)])
        XCTAssertEqual(state.player1.gold , 6)
        XCTAssertEqual(state.player2.gold , 3)
    }
    
    func testRemoveGoldNotNegative() {
        resolver.execute(features: [.removeGold(gold: 8)])
        XCTAssertEqual(state.player2.gold , 0)
    }
    
    func testTakeExtraTurn() {
        resolver.execute(features: [.takeExtraTurn])
        XCTAssertTrue(state.currentPlayer === state.player2)
    }
    
    func testMultiple() {
        resolver.execute(features: [.takeExtraTurn, .removeGold(gold: 3), .gainGold(gold: 3)])
        XCTAssertTrue(state.currentPlayer === state.player2)
        XCTAssertEqual(state.player1.gold , 9)
        XCTAssertEqual(state.player2.gold , 3)
    }
    
    func testMilitary() {
        resolver.execute(features: [.addMilitary(shield: 2)])
        XCTAssertEqual(military.position, 2)
    }
    
    func testRemoveCard() {
        let wond = Wonder(features: [CardFeature.removeCard], cost: Resource())
        let w = Action.buildWonder(wond, TestCard())
        resolver.execute(features: [.removeCard])
    }
}

class DefaultFeatureResolver: FeatureResolver {
    let state: GameState
    let military: Military
    init(state: GameState, military: Military) {
        self.state = state
        self.military = military
    }
    
    func execute(features: [CardFeature]) {
        let sortedFeatures = features.sorted { left, right -> Bool in
            right == .takeExtraTurn
        }
        for case let feature in sortedFeatures {
            switch feature {
            case .gainGold(gold: let gold):
                state.currentPlayer.gold += gold
            case .removeGold(gold: let gold):
                state.opponent.gold = max(0, state.opponent.gold - gold)
            case .takeExtraTurn:
                state.currentPlayer = state.opponent
            case .addMilitary(shield: let shields):
                military.move(player: state.currentPlayer, fields: shields)
            default:
                break
            }
        }
        
    }
}
