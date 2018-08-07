import Foundation

class ResourceCalculator {
    func concreteResources(in cards: [Card]) -> Resource {
        return cards.reduce(Resource(), { (result: Resource, card) -> Resource in
            result + card.providedResource
        })
    }
    
    func requiredResources(for card: Card, player: Player) -> Resource {
        let resources = concreteResources(in: player.cards)
        return (card.cost - resources).withoutNegative
    }
    
    // draft
    //    func possibleResources(in cards: [Card]) -> Resource {
    //
    //    }
}

extension Card {
    var providedResource: Resource {
        for case let CardFeature.provideResource(resource: res) in features {
            return res
        }
        return Resource()
    }
}
