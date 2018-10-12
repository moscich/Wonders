import XCTest
@testable import Wonders

class WonderShopTests: XCTestCase {
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

extension WonderShop {
    convenience init(state: GameState, shop: Shop) {
        let featureResolver = DefaultFeatureResolver(state: state, military: Military(player1: state.player1, player2: state.player2))
        self.init(state: state, shop: shop, featureResolver: featureResolver)
    }
}
