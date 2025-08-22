//
//  ContentView.swift
//  Frond
//
//  Created by Sebastian Bradford on 7/19/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            
            ZStack {
                Color(red:0.0, green: 0.25, blue: 0.05, opacity: 0.8)
                    .ignoresSafeArea()
                
                NavigationStack {
                    VStack{
                        Text("Frond")
                            .font(.system(size: 100))
                            .fontWeight(.black)
                            .foregroundStyle(.white)
                        
                        Text("The art and science of binary trees")
                            .italic()
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        NavigationLink(destination: learnTrees()) {
                            Text("Learn about trees")
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                                .padding(15)
                                .background(Color(red:0.0, green: 0.25, blue: 0.05, opacity: 0.8))

                                .cornerRadius(40)
                        }.padding(.bottom, 20)
                            
                        NavigationLink(destination: makeTrees()) {
                            Text("Make a tree")
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                                .padding(15)
                                .background(Color(red:0.0, green: 0.25, blue: 0.05, opacity: 0.8))
                                .cornerRadius(40)
                        }.padding(.bottom, 20)

                        Spacer()
                    }
                }
            }
        }
        
    }
}

#Preview {
    ContentView()
}
