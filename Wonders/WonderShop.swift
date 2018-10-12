class WonderShop {
    let state: GameState
    let shop: Shop
    let featureResolver: FeatureResolver
    
    init(state: GameState, shop: Shop, featureResolver: FeatureResolver) {
        self.state = state
        self.shop = shop
        self.featureResolver = featureResolver
    }
    
    func buyWonder(_ wonder: Wonder, with card: Card) {
        let cost = shop.wonderCost(wonder, for: state.currentPlayer)
        if state.player1.gold > cost {
            if state.board.claimCard(card) {
                featureResolver.execute(features: wonder.features)
                state.player1.gold -= cost
                state.currentPlayer = state.opponent
                wonder.built = true
            }
        }
    }
}
