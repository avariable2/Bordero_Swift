//
//  GroupBoxStyleData.swift
//  Bordero
//
//  Created by Grande Variable on 30/04/2024.
//

import SwiftUI

struct GroupBoxStyleData<V: View>: GroupBoxStyle {
    @Environment(\.colorScheme) var colorScheme
    
    var color: Color
    var destination: V
    var date: Date?

    @ScaledMetric var size: CGFloat = 1
    
    func makeBody(configuration: Configuration) -> some View {
        NavigationLink(destination: destination) {
            GroupBox(
                label: HStack {
                    
                    configuration.label.foregroundColor(color)
                    
                    Spacer()
                    
                    if date != nil {
                        Text(date!, style: .date)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.trailing, 4)
                    }
                }
                
            ) {
                configuration.content.padding(1)
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5))
            .backgroundStyle(Color.clear)
        }
    }
}

struct GroupBoxStyleDataWithoutDestination: GroupBoxStyle {
    @Environment(\.colorScheme) var colorScheme
    
    var color: Color
    var date: Date?

    @ScaledMetric var size: CGFloat = 1
    
    func makeBody(configuration: Configuration) -> some View {
        GroupBox(
            label: HStack {
                
                configuration.label.foregroundColor(color)
                
                Spacer()
                
                if date != nil {
                    Text(date!, style: .date)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 4)
                }
            }
            
        ) {
            configuration.content.padding(1)
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5))
        .backgroundStyle(Color.clear)
    }
}

#Preview {
    NavigationStack {
        Form {
            GroupBox {
                Text("Test pour voir ce que ça donne.")
                    .multilineTextAlignment(.leading)
            } label: {
                Label("Women", systemImage: "cup.and.saucer.fill")
            }
            .groupBoxStyle(GroupBoxStyleData(color: .red, destination: Text("oui")))
        }
    }
}
