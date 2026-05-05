//
//  ContentView.swift
//  Nubi
//
//  Created by Jimena Rodriguez on 04/05/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var selectedTab = 0

    var body: some View {
        if !vm.isOnboardingComplete {
            OnboardingView()
                .environmentObject(vm)
        } else {
            mainTabView
        }
    }

    var mainTabView: some View {
        ZStack(alignment: .bottom) {
            // Content
            TabView(selection: $selectedTab) {
                
                // 1. AQUÍ ESTÁ EL CAMBIO: Conectamos el HomeView con el Tab seleccionado
                HomeView(selectedTab: $selectedTab)
                    .environmentObject(vm)
                    .tag(0)

                ReportView()
                    .environmentObject(vm)
                    .tag(1)

                GuidesView()
                    .environmentObject(vm)
                    .tag(2)

                GamesView()
                    .environmentObject(vm)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Custom Tab Bar
            customTabBar
        }
        .ignoresSafeArea(edges: .bottom)
    }

    var customTabBar: some View {
        HStack(spacing: 0) {
            tabItem(icon: "house.fill", label: "Inicio", tag: 0)
            tabItem(icon: "doc.text.fill", label: "Reporte", tag: 1)
            tabItem(icon: "book.fill", label: "Guías", tag: 2)
            tabItem(icon: "gamecontroller.fill", label: "Juegos", tag: 3)
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(
            Color.nubiParchment
                .shadow(color: Color.nubiGlaucous.opacity(0.15), radius: 16, x: 0, y: -4)
        )
        .overlay(
            Rectangle()
                .fill(Color.nubiGlaucous.opacity(0.08))
                .frame(height: 1),
            alignment: .top
        )
    }

    private func tabItem(icon: String, label: String, tag: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.35)) {
                selectedTab = tag
            }
        } label: {
            VStack(spacing: 5) {
                ZStack {
                    if selectedTab == tag {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.nubiGlaucous.opacity(0.15))
                            .frame(width: 48, height: 32)
                    }
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: selectedTab == tag ? .bold : .regular))
                        .foregroundColor(selectedTab == tag ? .nubiGlaucous : .nubiDark.opacity(0.4))
                        .scaleEffect(selectedTab == tag ? 1.1 : 1)
                }
                .animation(.spring(response: 0.3), value: selectedTab)

                Text(label)
                    .font(.system(size: 11, weight: selectedTab == tag ? .semibold : .regular, design: .rounded))
                    .foregroundColor(selectedTab == tag ? .nubiGlaucous : .nubiDark.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppViewModel())
    }
}
