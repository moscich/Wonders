import XCTest
@testable import Wonders

class WonderCardTests: XCTestCase {
    func testBuyWonder() {
        let card = TestCard()
        let state = GameState(board: Board(cards: [CardOnBoard(card: card)]))
        let shop = MockShop(cost: 3)
        let wonderShop = WonderShop(state: state, shop: shop)
        let wonder = Wonder(cost: Resource(wood: 1))
        wonderShop.buyWonder(wonder, with: card)
        XCTAssertTrue(state.board.availableCards.isEmpty)
        XCTAssertTrue(state.currentPlayer === state.player2)
        XCTAssertEqual(state.player1.gold, 3)
        XCTAssertTrue(shop.wonder === wonder)
        XCTAssertTrue(shop.player === state.player1)
        XCTAssertTrue(wonder.built)
    }
    
    func testInvalidCard() {
        let state = GameState(board: Board(cards: [CardOnBoard(name: "whatever")]))
        let resolver = MockFeatureResolver()
        let wonderShop = WonderShop(state: state, shop: MockShop(cost: 3), featureResolver: resolver)
        let wonder = Wonder()
        wonderShop.buyWonder(wonder, with: TestCard())
        XCTAssertEqual(state.player1.gold, 6)
        XCTAssertTrue(state.currentPlayer === state.player1)
        XCTAssertFalse(wonder.built)
        XCTAssertNil(resolver.features)
    }
    
    func testInsifitientFounds() {
        let card = TestCard()
        let state = GameState(board: Board(cards: [CardOnBoard(card: card)]))
        let resolver = MockFeatureResolver()
        let wonderShop = WonderShop(state: state, shop: MockShop(cost: 7), featureResolver: resolver)
        let wonder = Wonder()
        wonderShop.buyWonder(wonder, with: card)
        XCTAssertEqual(state.player1.gold, 6)
        XCTAssertTrue(state.currentPlayer === state.player1)
        XCTAssertFalse(wonder.built)
        XCTAssertNil(resolver.features)
    }
    
    func testResolveFeatures() {
        let card = TestCard()
        let state = GameState(board: Board(cards: [CardOnBoard(card: card)]))
        let shop = MockShop(cost: 0)
        let resolver = MockFeatureResolver()
        let wonderShop = WonderShop(state: state, shop: shop, featureResolver: resolver)
        let wonder = Wonder(features: [.gainGold(gold: 3)])
        wonderShop.buyWonder(wonder, with: card)
        XCTAssertEqual(resolver.features, [CardFeature.gainGold(gold: 3)])
    }
}

class MockFeatureResolver: FeatureResolver {
    var features: [CardFeature]?
    func execute(features: [CardFeature]) {
        self.features = features
    }
}

class FeatureResolverTests: XCTestCase {
    func testGainGold() {
        let state = GameState(board: Board(cards: []))
        let resolver = DefaultFeatureResolver(state: state)
        resolver.execute(features: [.gainGold(gold: 3)])
        XCTAssertEqual(state.player1.gold , 9)
    }
}

class DefaultFeatureResolver: FeatureResolver {
    let state: GameState
    init(state: GameState) {
        self.state = state
    }
    
    func execute(features: [CardFeature]) {
        guard let feature = features.first else { return }
        switch feature {
        case .gainGold(gold: let gold):
            state.currentPlayer.gold += gold
        default:
            break
        }
    }
}

extension WonderShop {
    convenience init(state: GameState, shop: Shop) {
        self.init(state: state, shop: shop, featureResolver: DefaultFeatureResolver(state: state))
    }
}
