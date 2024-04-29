//
//  EndingScene.swift
//  DivingGame
//
//  Created by Hans Arthur Cupiterson on 29/04/24.
//

import SwiftUI

struct EndingScene: View {
    @Binding var isGameFinished: Bool
    var body: some View {
        Text("Ending Scene")
            .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    EndingScene(isGameFinished: .constant(false))
}
