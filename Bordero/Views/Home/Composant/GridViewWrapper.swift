//
//  GridViewWrapper.swift
//  Bordero
//
//  Created by Grande Variable on 28/05/2024.
//

import SwiftUI
import MijickGridView

struct GridViewWrapper<Content: View>: View {
    @Binding var config: GridView.Config
    @Binding var numberOfColumns : Int
    var articles: [ArticleData]
    var content: (ArticleData) -> Content
    @State private var viewID = UUID() // Needed for refresh number of column
    
    
    init(articles: [ArticleData], config: Binding<GridView.Config>, numberOfColumns : Binding<Int> ,@ViewBuilder content: @escaping (ArticleData) -> Content) {
        self.articles = articles
        self._config = config
        self._numberOfColumns = numberOfColumns
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            GridView(articles, id: \.id, content: content, configBuilder: {_ in
                configBuilder(for: width)
            })
            .id(viewID)
            .onAppear {
                updateConfig(for: width)
            }
            .onChange(of: geometry.size.width) { oldValue, newValue in
                updateConfig(for: newValue)
            }
        }
    }
    
    private func getNumberOfColumns(for width: CGFloat) -> Int {
        if width >= 800 {
            return 3
        } else if width > 400 {
            return 2
        } else {
            return 1
        }
    }

    private func updateConfig(for width: CGFloat) {
        let columns = getNumberOfColumns(for: width)
        numberOfColumns = columns
        config = GridView.Config().columns(columns)
        viewID = UUID()
    }

    private func configBuilder(for width: CGFloat) -> GridView.Config {
        let columns = getNumberOfColumns(for: width)
        return GridView.Config()
            .columns(columns)
            .horizontalSpacing(30)
            .verticalSpacing(10)
            .insertionPolicy(.fill)
    }
}
