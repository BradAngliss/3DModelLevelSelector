//
//  ContentView.swift
//  3D Model Level Selector
//
//  Created by Brad Angliss on 19/04/2024.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    @State var screenSize: CGSize = .zero

    var body: some View {
        ScrollViewReader { reader in
            Group {
                ZStack {
                    SceneView(
                        scene: viewModel.mainScene,
                        options: [.autoenablesDefaultLighting]
                    )
                    .edgesIgnoringSafeArea(.all)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 220) {
                            Spacer()
                            ForEach(0..<4) { i in
                                CardView
                                .id(i)
                                .scrollTransition { content, phase in
                                    content
                                        .scaleEffect(phase.isIdentity ? 1 : 0.8)
                                        .rotationEffect(.degrees(phase.isIdentity ? 0 : -30))
                                        .rotation3DEffect(.degrees(phase.isIdentity ? 0 : 60), axis: (x: -1, y: 1, z: 0))
                                        .blur(radius: phase.isIdentity ? 0 : 10)
                                        .offset(x: phase.isIdentity ? 0 : -200)
                                }
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .scrollTargetLayout()
                    }
                    .scrollDisabled(true)
                    .scrollTargetBehavior(.viewAligned)
                    .overlay(geometryReader)
                    .offset(y: 230)
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.width < 0 {
                            // Left
                            viewModel.swipeLeftGesture()
                        } else if gesture.translation.width > 0 {
                            // Right
                            viewModel.swipeRightGesture()
                        }
                        withAnimation(.easeInOut(duration: 10)) {
                            reader.scrollTo(viewModel.selectedIndex, anchor: .center)
                        }
                    }
            )
        }
    }
    
    private var CardView: some View {
        TimelineView(.animation) { context in
            VStack(alignment: .leading) {
                Text(viewModel.levelTitle)
                    .font(.title)
                Divider()
                HStack(spacing: 30) {
                    Text(viewModel.levelDescription)
                        .font(.subheadline)
                    Spacer()
                    Button {
                    } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.thickMaterial)
                            .frame(width: 40, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(.thickMaterial, lineWidth: 2)
                            )
                    }
                    .padding(.top, 10)
                }
            }
            .padding(20)
            .frame(width: 360, height: 175)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
        }
    }
    
    private var geometryReader: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear {
                    screenSize = proxy.size
                }
                .onChange(of: proxy.size) { oldValue, newValue in
                    screenSize = newValue
                }
        }
    }
}

#Preview {
    ContentView()
}
