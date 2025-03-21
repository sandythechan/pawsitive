//
//  FocusModeView.swift
//  App
//
//  Created by Chan Ka Yu on 21/2/2025.
//

import SwiftUI

struct FocusModeView: View {
    @State private var userTarget: String = ""
    var body: some View {
        ZStack{
            Color(red: 75/255, green: 78/255, blue: 61/255).ignoresSafeArea(.all)
            
            VStack{
                Text("Focus Mode")
                    .font(.custom("Jersey25-Regular", size: 80))
                    .foregroundColor(Color(red: 246/255, green: 249/255, blue: 220/255))
                Text("time to put down your phone \nand play with your dog !")
                    .font(.custom("Jersey25-Regular", size: 25))
                    .foregroundColor(Color(red: 246/255, green: 249/255, blue: 220/255))
                    .multilineTextAlignment(.center)
                
                Spacer()
                    .frame(height: 50)
                
                Circle()
                    .foregroundStyle(Color(red: 42/255, green: 139/255, blue: 201/255))
                    .padding(.horizontal, 30)
                
                TextField("enter your target...", text: $userTarget)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(Color(red: 75/255, green: 78/255, blue: 61/255))
                    .font(.custom("Jersey25-Regular", size: 25))
                
                
            }
        }
    }
}

#Preview {
    FocusModeView()
}
