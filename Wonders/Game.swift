import Foundation

public class GameState {
    public let board: Board
    public var player1 = Player()
    public let player2 = Player()
    var currentPlayer: Player
    
    init(board: Board) {
        self.board = board
        currentPlayer = player1
    }
    
    var opponent: Player {
        if currentPlayer === player1 {
            return player2
        } else {
            return player1
        }
    }
}

public class Game {
    let state: GameState
    let player1Interactor: PlayerInteractor
    let player2Interactor: PlayerInteractor
    
    let resourceCalculator: ResourceCalculator
    let boardFactory: BoardFactory
    let shop: Shop
    
    init(player1: PlayerInteractor, player2: PlayerInteractor, boardFactory: BoardFactory,
         resourceCalculator: ResourceCalculator = DefaultResourceCalculator(),
         shop: Shop = DefaultShop()) {
        self.player1Interactor = player1
        self.player2Interactor = player2
        self.boardFactory = boardFactory
        self.resourceCalculator = resourceCalculator
        self.shop = shop
        self.state = GameState(board: boardFactory.firstEpohBoard)
        
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
            let currentPlayer = self.state.currentPlayer
            switch action {
            case .takeCard(let card):
                let requiredResources = self.resourceCalculator.requiredResources(for: card, player: currentPlayer)
                let player2Resources = self.resourceCalculator.concreteResources(in: self.opponent.cards)
                let requiredGold = self.shop.resourceCost(requiredResources, oponentResource: player2Resources)
                if currentPlayer.gold >= requiredGold {
                    if self.board.claimCard(card) {
                        currentPlayer.cards.append(card)
                        currentPlayer.gold -= requiredGold
                        self.state.currentPlayer = self.opponent
                    }
                }
            case .sellCard(let card):
                if self.board.claimCard(card) {
                    currentPlayer.gold += 2
                    self.state.currentPlayer = self.opponent
                }
            case .buildWonder(let wonder, let card):
                let requiredResources = self.resourceCalculator.requiredResources(for: card, player: currentPlayer)
                let player2Resources = self.resourceCalculator.concreteResources(in: self.opponent.cards)
                let requiredGold = self.shop.resourceCost(requiredResources, oponentResource: player2Resources)
                if currentPlayer.gold >= requiredGold {
                    if self.board.claimCard(card) {
                        currentPlayer.gold -= requiredGold
                        wonder.built = true
                    }
                }
            }
            
            self.currentInteractor.requestAction(game: self, action: self.actionHey())
        }
    }
    
    private var currentInteractor: PlayerInteractor {
        if state.currentPlayer === state.player1 {
            return player1Interactor
        } else {
            return player2Interactor
        }
    }
    
    private var opponent: Player {
        return state.opponent
    }
}

extension Game {
    var board: Board {
        return state.board
    }
    
    var player1: Player {
        return state.player1
    }
    
    var player2: Player {
        return state.player2
    }
}
