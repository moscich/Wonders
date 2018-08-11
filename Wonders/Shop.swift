import Foundation

protocol Shop {
    func resourceCost(_ resource: Resource, player: Player?, oponentResource: Resource) -> Int
    func wonderCost(_ wonder: Wonder, for player: Player) -> Int
}

extension Shop {
    func resourceCost(_ resource: Resource, oponentResource: Resource) -> Int {
        return resourceCost(resource, player: nil, oponentResource: oponentResource)
    }
}

class DefaultShop: Shop {
    func wonderCost(_ wonder: Wonder, for player: Player) -> Int {
        return 0
    }
    
    func resourceCost(_ resource: Resource, player: Player? = nil, oponentResource: Resource) -> Int {
        let features = (player?.cards.reduce(into: []) { (res, card) in
            res.append(contentsOf: card.features)
            }) ?? []
        
        var woodCost = 2 + oponentResource.wood
        var stoneCost = 2 + oponentResource.stones
        var clayCost = 2 + oponentResource.clay
        
        for feature in features {
            switch feature {
            case .woodWerehouse:
                woodCost = 1
            case .stoneWerehouse:
                stoneCost = 1
            case .clayWerehouse:
                clayCost = 1
            default:break
            }
        }
        
        return resource.wood * woodCost +
            resource.stones * stoneCost +
            resource.clay * clayCost +
            resource.papyrus * (2 + oponentResource.papyrus) +
            resource.glass * (2 + oponentResource.glass) +
            resource.gold
    }
}
