//
//  Models.swift
//  TennisChartingApp
//

import Foundation

// MARK: - User

struct User: Codable, Identifiable {
    let id: UUID
    var email: String
    var passwordHash: String

    init(id: UUID = UUID(), email: String, passwordHash: String) {
        self.id = id
        self.email = email
        self.passwordHash = passwordHash
    }
}

// MARK: - Match

struct Match: Codable, Identifiable {
    let id: UUID
    var playerAName: String
    var playerBName: String
    var sets: [MatchSet]
    var date: Date
    var isCompleted: Bool
    var matchFormat: MatchFormat
    var startingPlayer: PlayerSide
    var firstServer: PlayerSide

    init(
        id: UUID = UUID(),
        playerAName: String,
        playerBName: String,
        matchFormat: MatchFormat,
        startingPlayer: PlayerSide,
        firstServer: PlayerSide
    ) {
        self.id = id
        self.playerAName = playerAName
        self.playerBName = playerBName
        self.sets = []
        self.date = Date()
        self.isCompleted = false
        self.matchFormat = matchFormat
        self.startingPlayer = startingPlayer
        self.firstServer = firstServer
    }

    var playerASetsWon: Int {
        sets.filter { $0.winner == .playerA }.count
    }

    var playerBSetsWon: Int {
        sets.filter { $0.winner == .playerB }.count
    }

    var winner: PlayerSide? {
        let setsToWin = matchFormat.setsToWin
        if playerASetsWon >= setsToWin { return .playerA }
        if playerBSetsWon >= setsToWin { return .playerB }
        return nil
    }
}

enum MatchFormat: Int, Codable, CaseIterable {
    case bestOf1 = 1
    case bestOf3 = 3
    case bestOf5 = 5

    var setsToWin: Int {
        switch self {
        case .bestOf1: return 1
        case .bestOf3: return 2
        case .bestOf5: return 3
        }
    }

    var displayName: String {
        switch self {
        case .bestOf1: return "Best of 1"
        case .bestOf3: return "Best of 3"
        case .bestOf5: return "Best of 5"
        }
    }
}

enum PlayerSide: String, Codable {
    case playerA
    case playerB
}

// MARK: - Set

struct MatchSet: Codable, Identifiable {
    let id: UUID
    var games: [Game]
    var isTiebreak: Bool
    var tiebreakScore: TiebreakScore?

    init(id: UUID = UUID()) {
        self.id = id
        self.games = []
        self.isTiebreak = false
        self.tiebreakScore = nil
    }

    var playerAGames: Int {
        games.filter { $0.winner == .playerA }.count + (tiebreakScore?.winner == .playerA ? 1 : 0)
    }

    var playerBGames: Int {
        games.filter { $0.winner == .playerB }.count + (tiebreakScore?.winner == .playerB ? 1 : 0)
    }

    var winner: PlayerSide? {
        // Regular set win: 6 games with 2+ game lead, or 7-5, or tiebreak
        if let tiebreakWinner = tiebreakScore?.winner {
            return tiebreakWinner
        }

        let aGames = games.filter { $0.winner == .playerA }.count
        let bGames = games.filter { $0.winner == .playerB }.count

        if aGames >= 6 && aGames - bGames >= 2 { return .playerA }
        if bGames >= 6 && bGames - aGames >= 2 { return .playerB }

        return nil
    }

    var isAtTiebreak: Bool {
        let aGames = games.filter { $0.winner == .playerA }.count
        let bGames = games.filter { $0.winner == .playerB }.count
        return aGames == 6 && bGames == 6
    }
}

struct TiebreakScore: Codable {
    var playerAPoints: Int
    var playerBPoints: Int

    var winner: PlayerSide? {
        if playerAPoints >= 7 && playerAPoints - playerBPoints >= 2 { return .playerA }
        if playerBPoints >= 7 && playerBPoints - playerAPoints >= 2 { return .playerB }
        return nil
    }
}

// MARK: - Game

struct Game: Codable, Identifiable {
    let id: UUID
    var points: [Point]
    var server: PlayerSide

    init(id: UUID = UUID(), server: PlayerSide) {
        self.id = id
        self.points = []
        self.server = server
    }

    var playerAPoints: Int {
        points.filter { $0.winner == .playerA }.count
    }

    var playerBPoints: Int {
        points.filter { $0.winner == .playerB }.count
    }

    var playerAGameScore: GameScore {
        GameScore.from(points: playerAPoints, opponentPoints: playerBPoints)
    }

    var playerBGameScore: GameScore {
        GameScore.from(points: playerBPoints, opponentPoints: playerAPoints)
    }

    var winner: PlayerSide? {
        let a = playerAPoints
        let b = playerBPoints

        // Need at least 4 points and 2 point lead to win
        if a >= 4 && a - b >= 2 { return .playerA }
        if b >= 4 && b - a >= 2 { return .playerB }

        return nil
    }
}

enum GameScore: String {
    case love = "0"
    case fifteen = "15"
    case thirty = "30"
    case forty = "40"
    case advantage = "Ad"

    static func from(points: Int, opponentPoints: Int) -> GameScore {
        if points < 3 {
            switch points {
            case 0: return .love
            case 1: return .fifteen
            case 2: return .thirty
            default: return .love
            }
        }

        // Both at 3+ points
        if points >= 3 && opponentPoints >= 3 {
            if points == opponentPoints {
                return .forty // Deuce
            } else if points > opponentPoints {
                return .advantage
            } else {
                return .forty
            }
        }

        return .forty
    }
}

// MARK: - Point

struct Point: Codable, Identifiable {
    let id: UUID
    var winner: PlayerSide
    var note: PointNote?
    var timestamp: Date

    init(id: UUID = UUID(), winner: PlayerSide, note: PointNote? = nil) {
        self.id = id
        self.winner = winner
        self.note = note
        self.timestamp = Date()
    }
}

struct PointNote: Codable {
    var howWon: HowPointWon?
    var attitude: Attitude?
    var additionalNotes: String?
}

enum HowPointWon: String, Codable, CaseIterable {
    case ace = "Ace"
    case forehandWinner = "FH Winner"
    case backhandWinner = "BH Winner"
    case netWinner = "Net Winner"
    case forcedError = "Forced Error"
}

enum Attitude: String, Codable, CaseIterable {
    case tactical = "Tactical"
    case energised = "Energised"
    case confident = "Confident"
    case calm = "Calm"
    case assertive = "Assertive"
    case rushed = "Rushed"
    case angry = "Angry"
    case dejected = "Dejected"
}
