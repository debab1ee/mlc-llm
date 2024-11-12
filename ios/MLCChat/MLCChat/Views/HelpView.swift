//
//  HelpView.swift
//  MLCChat
//
//  Created by Debakshi Bhattacharjee on 12/11/24.
//


import SwiftUI

struct HelpView: View {
    
    @Environment(\.dismiss) var dismiss // For handling back navigation
    
    var body: some View {
        NavigationStack {
            ScrollView { // Wrap content in a ScrollView
                VStack(spacing: 0) {
                    // Custom Back Button
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image("Ic_Back") // Replace with your image name
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30) // Adjust size as needed
                        }
                        .padding()
                        
                        Text("Help")
                            .font(.custom("SpaceGrotesk-Medium", size: 22))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .background(Color.black) // Background color for the header
                    
                    Divider()
                        .background(Color.white)
                    
                    // Section 1
                    sectionView(title: "How To Use App", content: loremText)
                    
                    // Section 2
                    sectionView(title: "How To Use App", content: loremText)
                    
                    // Section 3
                    sectionView(title: "How To Use App", content: loremText)
                    
                    Spacer()
                }
            }
            .padding(.bottom, 20) // Optional padding at the bottom
            .background(Color.black.edgesIgnoringSafeArea(.all)) // Background color for the entire view
            .toolbar(.hidden, for: .navigationBar) // Hide the navigation bar
        }
    }
    
    private func sectionView(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.custom("SpaceGrotesk-Bold", size: 20))
                .foregroundColor(.white)
                .padding(.top, 20)
            
            Text(content)
                .font(.custom("SpaceGrotesk-Regular", size: 16))
                .foregroundStyle(Color(.FCFDF_8))
                .padding(.bottom, 20)
        }
        .padding(.horizontal)
        .background(Color.black)
    }
}

let loremText = """
Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.
"""

