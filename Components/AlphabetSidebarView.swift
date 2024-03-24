//
//  AlphabetSidebarView.swift
//  Bordero
//
//  Created by Grande Variable on 24/03/2024.
//

import SwiftUI

struct AlphabetSidebarView: View {
    
    var listView: AnyView
    var lookup: (String) -> (any Hashable)?
    let alphabet: [String] = {
        (65...90).map { String(UnicodeScalar($0)!) }
    }()
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ZStack {
                listView
                HStack(alignment: .center) {
                    Spacer()
                    VStack(alignment: .center) {
                        ForEach(alphabet, id: \.self) { letter in
                            Button(action: {
                                if let found = lookup(letter) {
                                    withAnimation {
                                        scrollProxy.scrollTo(found, anchor: .top)
                                    }
                                }
                            }, label: {
                                Text(letter)
                                    .foregroundColor(.accentColor)
                                    .minimumScaleFactor(0.5)
                                    .font(.subheadline)
                                    .padding(.trailing, 4)
                            })
                        }
                    }
                }
            }
        }
    }
}
