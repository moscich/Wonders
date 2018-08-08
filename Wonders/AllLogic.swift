import Foundation

class Shop {
    func resourceCost(_ resource: Resource, oponentResource: Resource) -> Int {
        return resource.wood * (2 + oponentResource.wood) +
            resource.clay * (2 + oponentResource.clay) +
            resource.papyrus * (2 + oponentResource.papyrus) +
            resource.glass * (2 + oponentResource.glass) +
            resource.stones * (2 + oponentResource.stones)
    }
    
    func resourceCost(_ resource: Resource, player: Player, oponentResource: Resource) -> Int {
        let features = player.cards.reduce(into: []) { (res, card) in
            res.append(contentsOf: card.features)
        }
        
        var woodCost = 2 + oponentResource.wood
        var stoneCost = 2 + oponentResource.stones
        var clayCost = 2 + oponentResource.stones
        
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
            resource.glass * (2 + oponentResource.glass)
    }
}

public protocol Card: class {
    var features: [CardFeature] { get }
    var cost: Resource { get }
    var name: String { get }
}

public enum CardFeature: Decodable {
    enum CodingKeys: String, CodingKey {
        case wood
        case stones
        case clay
        case glass
        case papyrus
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let wood = (try? values.decode(Int.self, forKey: .wood)) ?? 0
        let stones = (try? values.decode(Int.self, forKey: .stones)) ?? 0
        let clay = (try? values.decode(Int.self, forKey: .clay)) ?? 0
        let glass = (try? values.decode(Int.self, forKey: .glass)) ?? 0
        let papyrus = (try? values.decode(Int.self, forKey: .papyrus)) ?? 0
        
        self = CardFeature.provideResource(resource: Resource(wood: wood, stones: stones, clay: clay, glass: glass, papyrus: papyrus))
    }
    
    case provideResource(resource: Resource)
    case woodWerehouse
    case stoneWerehouse
    case clayWerehouse
}

public class DefaultCard: Card, Decodable {
    
    public var name: String
    public let features: [CardFeature]
    public let cost: Resource
    public var providedResource: Resource {
        if let feature = features.first {
            if case let CardFeature.provideResource(resource: res) = feature {
                return res
            }
        }
        return Resource()
    }
    
    enum CodingKeys: String, CodingKey {
        case cost
        case name
        case provide
        case features
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        cost = (try? values.decode(Resource.self, forKey: .cost)) ?? Resource()
        name = try values.decode(String.self, forKey: .name)
        features = (try? values.decode([CardFeature].self, forKey: .features)) ?? []
    }
}

public struct Resource: Equatable, Decodable {
    let wood: Int
    let stones: Int
    let clay: Int
    let glass: Int
    let papyrus: Int
    let gold: Int
    
    public init(wood: Int = 0,
         stones: Int = 0,
         clay: Int = 0,
         glass: Int = 0,
         papyrus: Int = 0,
         gold: Int = 0
        ) {
        self.wood = wood
        self.stones = stones
        self.clay = clay
        self.glass = glass
        self.papyrus = papyrus
        self.gold = gold
    }
    
    var withoutNegative: Resource {
        return Resource(wood: wood > 0 ? wood : 0,
                        stones: stones > 0 ? stones : 0,
                        clay: clay > 0 ? clay : 0,
                        glass: glass > 0 ? glass : 0,
                        papyrus: papyrus > 0 ? papyrus : 0,
                        gold: gold > 0 ? gold : 0)
    }
    
    enum CodingKeys: String, CodingKey {
        case wood
        case stones
        case clay
        case glass
        case papyrus
        case gold
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        wood = (try? values.decode(Int.self, forKey: .wood)) ?? 0
        stones = (try? values.decode(Int.self, forKey: .stones)) ?? 0
        clay = (try? values.decode(Int.self, forKey: .clay)) ?? 0
        glass = (try? values.decode(Int.self, forKey: .glass)) ?? 0
        papyrus = (try? values.decode(Int.self, forKey: .papyrus)) ?? 0
        gold = (try? values.decode(Int.self, forKey: .gold)) ?? 0
    }
}

func +(left: Resource, rigth: Resource) -> Resource {
    return Resource(wood: left.wood + rigth.wood,
                    stones: left.stones + rigth.stones,
                    clay: left.clay + rigth.clay,
                    glass: left.glass + rigth.glass,
                    papyrus: left.papyrus + rigth.papyrus,
                    gold: left.gold + rigth.gold)
}

func -(left: Resource, rigth: Resource) -> Resource {
    return Resource(wood: left.wood - rigth.wood,
                    stones: left.stones - rigth.stones,
                    clay: left.clay - rigth.clay,
                    glass: left.glass - rigth.glass,
                    papyrus: left.papyrus - rigth.papyrus,
                    gold: left.gold - rigth.gold)
}

class Player {
    var cards: [Card] = []
    var gold: Int = 6
}

public protocol Action {
    
}

public protocol PlayerInteractor {
    func requestAction(game: Game, action: @escaping (Action) -> ())
}

class TestPlayerInteractor: PlayerInteractor {
    var wasAskedForAction = false
    var action: ((Action) -> ())?
    
    func requestAction(game: Game, action: @escaping (Action) -> ()) {
        wasAskedForAction = true
        self.action = action
    }
    
    func receivedSomePlayerInteraction(interaction: Action) {
        action?(interaction)
    }
}

public class Game {
    public let board: Board
    let player1Interactor: PlayerInteractor
    let player2Interactor: PlayerInteractor
    var player1 = Player()
    let player2 = Player()
    var currentPlayer: Player
    let resourceCalculator = ResourceCalculator()
    let shop = Shop()
    let boardFactory: BoardFactory
    
    init(player1: PlayerInteractor, player2: PlayerInteractor, boardFactory: BoardFactory) {
        self.player1Interactor = player1
        self.player2Interactor = player2
        self.boardFactory = boardFactory
        self.board = boardFactory.firstEpohBoard
        currentPlayer = self.player1
        player1.requestAction(game: self, action: actionHey())
    }
    
    convenience public init(player1: PlayerInteractor, player2: PlayerInteractor, cardProvider: CardProvider) {
        self.init(player1: player1, player2: player2, boardFactory: DefaultBoardFactory(cardProvider: cardProvider))
    }
    
    convenience public init(player1: PlayerInteractor, player2: PlayerInteractor) {
        let url = Bundle(for: type(of: self)).url(forResource: "cards", withExtension: "json")!
        self.init(player1: player1, player2: player2, boardFactory: DefaultBoardFactory(cardProvider: RandomCardProvider(file: url)))
    }
    
    private func actionHey() -> ((Action) -> ()) {
        return { [weak self] action in
            guard let `self` = self else { return }
            
            if let cardAction = action as? CardTakeAction {
                let card = cardAction.requestedCard
                let requiredResources = self.resourceCalculator.requiredResources(for: card, player: self.currentPlayer)
                let player2Resources = self.resourceCalculator.concreteResources(in: self.opponent.cards)
                let requiredGold = self.shop.resourceCost(requiredResources, oponentResource: player2Resources)
                if self.currentPlayer.gold >= requiredGold {
                    if self.board.claimCard(cardAction.requestedCard) {
                        self.currentPlayer.cards.append(card)
                        self.currentPlayer.gold -= requiredGold
                        self.currentPlayer = self.opponent
                    }
                }
            } else if let sellAction = action as? CardSellAction {
                if self.board.claimCard(sellAction.requestedCard) {
                    self.currentPlayer.gold += 2
                    self.currentPlayer = self.opponent
                }
            } else if action is TestAction {
                self.currentPlayer = self.opponent
            }
            
            self.currentInteractor.requestAction(game: self, action: self.actionHey())
        }
    }
    
    private var currentInteractor: PlayerInteractor {
        if currentPlayer === player1 {
            return player1Interactor
        } else {
            return player2Interactor
        }
    }
    
    private var opponent: Player {
        if currentPlayer === player1 {
            return player2
        } else {
            return player1
        }
    }
}

public struct CardTakeAction: Action {
    public let requestedCard: Card
    public init(requestedCard: Card) {
        self.requestedCard = requestedCard
    }
}

public struct CardSellAction: Action {
    public let requestedCard: Card
    public init(requestedCard: Card) {
        self.requestedCard = requestedCard
    }
}

struct TestAction: Action {
    
}

public class Board {
    var cards: [CardOnBoard?]
    init(cards: [CardOnBoard?]) {
        self.cards = cards
    }
    
    public var availableCards: [Card] {
        return cards.filter({ cardOnBoard -> Bool in
            cardOnBoard != nil
        }).filter({ cardOnBoard -> Bool in
            cardOnBoard!.descendants.isEmpty
        }).map({ cardOnBoard -> Card in
            return cardOnBoard!.card
        })
    }
    
    func claimCard(_ card: Card) -> Bool {
        guard (availableCards.contains { availableCard -> Bool in
            availableCard === card
        }) else { return false }
        for cardOnBoard in cards {
            guard let cardOnBoard = cardOnBoard else { continue }
            cardOnBoard.descendants = cardOnBoard.descendants.filter({ descendant -> Bool in
                descendant.card !== card
            })
        }
        cards.remove(card: card)
        return true
    }
}

extension Array where Element == CardOnBoard? {
    mutating func remove(card: Card) {
        guard let index = (index { (cardOnBoard: CardOnBoard?) -> Bool in
            card === cardOnBoard?.card
        }) else { return }
        remove(at: index)
    }
}

public protocol CardProvider {
    var firstEpohRandomisedCards: [Card] { get }
}

protocol BoardFactory {
    var firstEpohBoard: Board { get }
}

class DefaultBoardFactory: BoardFactory {
    let cardProvider: CardProvider
    init(cardProvider: CardProvider) {
        self.cardProvider = cardProvider
    }
    var firstEpohBoard: Board {
        let cards = cardProvider.firstEpohRandomisedCards
        
        var rows = [[CardOnBoard]]()
        
        for row in 0...4 {
            let rowCards = cards[startingCardIndex(for: row)...startingCardIndex(for: row) + 1 + row].map { card -> CardOnBoard in
                CardOnBoard(card: card, hidden: row % 2 == 1, descendants: [])
            }
            rows.append(rowCards)
        }
        
        var cardsOnBoard = [CardOnBoard]()
        for (index, row) in rows.enumerated() {
            cardsOnBoard.append(contentsOf: row)
            guard let previousRow = index > 0 ? rows[index - 1] : nil else { continue }
            for (index, card) in previousRow.enumerated() {
                card.descendants = [row[index], row[index + 1]]
            }
        }
      
        return Board(cards: cardsOnBoard)
    }
    
    private func startingCardIndex(for row: Int) -> Int {
        if row == 0 {
            return 0
        } else if row == 1 {
            return 2
        } else {
            return startingCardIndex(for:row - 1) + row + 1
        }
    }
}

public class CardOnBoard {
    public var hidden: Bool
    public var card: Card
    public var descendants: [CardOnBoard]
    
    public init(card: Card, hidden: Bool, descendants: [CardOnBoard]) {
        self.hidden = hidden
        self.descendants = descendants
        self.card = card
    }
}
