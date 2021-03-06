//
//  ContentView.swift
//  TicTacToe
//
//  Created by Akshay Kalucha on 19/02/22.
//

import SwiftUI


var hSide: String = ""
var cSide: String = ""


struct ContentView: View {
    
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible()),]
    
    @State private var moves: [Move?] = Array(repeating:nil, count:9)
    @State private var isGameBoardDisabled = false
    @State private var alertItem: AlertItem?
    @State var humanSide: String = ""
    @State var computerSide: String = ""
    @State private var bgColorOne: Color = Color.black
    @State private var bgColorTwo: Color = Color.black
    @State private var fColor: Color = Color.white
    @State private var sideChosen: Bool = false
    
    func changeGameSetting() {
        print(humanSide)
        if humanSide == "xmark" {
            hSide = "xmark"
            cSide = "circle"
            bgColorTwo = Color.green
            bgColorOne = Color.red
        }else{
            hSide = "circle"
            cSide = "xmark"
            bgColorTwo = Color.red
            bgColorOne = Color.green
        }
        sideChosen = true
    }
    
    
    var body: some View {
        HStack {
            GeometryReader{ geometry in
                VStack{
                    Text("choose your side")
                        .font(.largeTitle)
                    HStack{
                        Image(systemName: "circle")
                            .resizable()
                            .frame(width:40, height:40)
                            .foregroundColor(fColor)
                            .padding()
                            .background(bgColorOne)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16).stroke(Color.orange, lineWidth: 7)
                                    .frame(width:78, height: 80)
                            )
                            .onTapGesture {
                                humanSide = "circle"
                                computerSide = "xmark"
                                changeGameSetting()
                            }
                        Spacer()
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width:40, height:40)
                            .foregroundColor(fColor)
                            .padding()
                            .background(bgColorTwo)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16).stroke(Color.orange, lineWidth: 7)
                                    .frame(width:75, height: 75)
                            )
                            .onTapGesture {
                                humanSide = "xmark"
                                computerSide = "circle"
                                changeGameSetting()
                                print("tapped", humanSide, computerSide)
                                
                            }
                    }
                    Spacer()
                    LazyVGrid(columns: columns, spacing:5){
                        ForEach(0..<9) { i in
                            ZStack {
                                Circle()
                                    .foregroundColor(.red).opacity(0.5)
                                    .frame(width:geometry.size.width/3 - 15, height:geometry.size.width/3 - 15)
                                
                                Image(systemName: moves[i]?.indicator ?? "")
                                    .resizable()
                                    .frame(width:40, height:40)
                                    .foregroundColor(.white)
                            }
                            .onTapGesture {
                                if isSquareOccupied(in: moves, forIndex: i) {
                                    return
                                }
                                moves[i] = Move(player: .human, boardIndex: i)
                                
                                
                                if checkWinCondition(for: .human, in: moves) {
                                    alertItem = AlertContext.humanWin
                                    return
                                }
                                
                                if checkForDraw(in: moves) {
                                    alertItem = AlertContext.draw
                                    return
                                }
                                isGameBoardDisabled = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                                    let compuetrPosition = determineComputerMovePosition(in: moves)
                                    moves[compuetrPosition] = Move(player: .computer, boardIndex: compuetrPosition)
                                    isGameBoardDisabled = false
                                    
                                    if checkWinCondition(for: .computer, in: moves) {
                                        alertItem = AlertContext.computerWin
                                        return
                                    }
                                    
                                    if checkForDraw(in: moves){
                                        alertItem = AlertContext.draw
                                        return
                                    }
                                }
                            }
                        }
                    }.disabled(!sideChosen)
                    Spacer()
                }
                .disabled(isGameBoardDisabled)
                .padding()
                .alert(item: $alertItem) { alertItem in
                    Alert(title: alertItem.title, message: alertItem.message, dismissButton: .default(alertItem.buttonTitle, action: { resetGame() }))
                }
            }.background(.gray.opacity(0.4))
        }
    }
    
    func isSquareOccupied(in moves: [Move?], forIndex index: Int) -> Bool {
        return moves.contains(where: {$0?.boardIndex == index})
    }
    
    
    func determineComputerMovePosition(in moves: [Move?]) -> Int {
        
        let winPatterns: Set<Set<Int>> = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
        let computerMoves = moves.compactMap { $0 }.filter { $0.player == .computer }
        let computerPositions = Set(computerMoves.map { $0.boardIndex })
        
        for pattern in winPatterns {
            let winPositions = pattern.subtracting(computerPositions)
            
            if winPositions.count == 1 {
                let isAvailable = !isSquareOccupied(in: moves, forIndex: winPositions.first!)
                if isAvailable { return winPositions.first!}
            }
        }
        
        let humanMoves = moves.compactMap { $0 }.filter { $0.player == .human }
        let humanPositions = Set(humanMoves.map { $0.boardIndex })
        
        for pattern in winPatterns {
            let winPositions = pattern.subtracting(humanPositions)
            
            if winPositions.count == 1 {
                let isAvailable = !isSquareOccupied(in: moves, forIndex: winPositions.first!)
                if isAvailable { return winPositions.first!}
            }
        }
        
        
        let centerSquare = 4
        if !isSquareOccupied(in: moves, forIndex: centerSquare) {
            return centerSquare
        }
        
        var movePosition = Int.random(in: 0..<9)
        
        while isSquareOccupied(in: moves, forIndex: movePosition) {
            movePosition = Int.random(in: 0..<9)
        }
        
        return movePosition
    }
    
    func checkWinCondition(for player: Player, in moves: [Move?]) -> Bool {
        
        let winPatterns: Set<Set<Int>> = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
        
        let playerMoves = moves.compactMap { $0 }.filter { $0.player == player }
        let playerPositions = Set(playerMoves.map { $0.boardIndex })
        
        for pattern in winPatterns where pattern.isSubset(of:playerPositions) { return true }
        
        return false
    }
    
    func checkForDraw(in moves: [Move?]) -> Bool {
        return moves.compactMap { $0 }.count == 9
    }
    
    func resetGame () {
        moves = Array(repeating:nil, count:9)
        humanSide = ""
        computerSide = ""
        bgColorOne = Color.black
        bgColorTwo = Color.black
        fColor = Color.white
        sideChosen = false
    }
}


enum Player {
    case human, computer
}


struct Move {
    let player: Player
    let boardIndex: Int
    
    var indicator: String {
        return player == .human ? hSide : cSide
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
