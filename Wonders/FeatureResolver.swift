protocol FeatureResolver {
    func execute(features: [CardFeature])
    func execute(features: [CardFeature], targetCard: Card) -> Bool
}
