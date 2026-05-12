//
//  ContentView.swift
//  Nubi
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var selectedTab = 0

    var body: some View {
        if !vm.isOnboardingComplete {
            OnboardingView().environmentObject(vm)
        } else {
            mainTabView
        }
    }

    /// Color dinámico de la barra de navegación según emoción registrada
    private var tabActiveColor: Color {
        if vm.todayEmotion != nil { return vm.nubiColor }
        return Color.coppelButton
    }

    var mainTabView: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab).environmentObject(vm).tag(0)
                ReportView().environmentObject(vm).tag(1)
                GuidesView().environmentObject(vm).tag(2)
                GamesView().environmentObject(vm).tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            customTabBar
        }
        .ignoresSafeArea(edges: .bottom)
    }

    var customTabBar: some View {
        HStack(spacing: 0) {
            tabItem(icon: "house.fill",          label: "Inicio",  tag: 0)
            tabItem(icon: "doc.text.fill",       label: "Reporte", tag: 1)
            tabItem(icon: "book.fill",           label: "Guías",   tag: 2)
            tabItem(icon: "gamecontroller.fill", label: "Juegos",  tag: 3)
        }
        .padding(.horizontal, 8).padding(.top, 12).padding(.bottom, 24)
        .background(Color.coppelYellow.shadow(color: Color.coppelDeepBlue.opacity(0.10), radius: 16, x: 0, y: -4))
        .overlay(Rectangle().fill(Color.coppelDeepBlue.opacity(0.08)).frame(height: 1), alignment: .top)
    }

    private func tabItem(icon: String, label: String, tag: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.35)) { selectedTab = tag }
        } label: {
            VStack(spacing: 5) {
                ZStack {
                    if selectedTab == tag {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(tabActiveColor.opacity(0.20))
                            .frame(width: 48, height: 32)
                    }
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: selectedTab == tag ? .bold : .regular))
                        .foregroundColor(selectedTab == tag ? tabActiveColor : .coppelDeepBlue.opacity(0.4))
                        .scaleEffect(selectedTab == tag ? 1.1 : 1)
                }
                .animation(.spring(response: 0.3), value: selectedTab)
                .animation(.spring(response: 0.4), value: tabActiveColor)

                Text(label)
                    .font(.system(size: 11, weight: selectedTab == tag ? .semibold : .regular, design: .rounded))
                    .foregroundColor(selectedTab == tag ? tabActiveColor : .coppelDeepBlue.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
        }
    }
}
