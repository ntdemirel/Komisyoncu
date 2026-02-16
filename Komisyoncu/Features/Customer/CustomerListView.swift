//
//  CustomerView.swift
//  Komisyoncu
//
//  Created by Taha DEMİREL on 16.02.2026.
//

import SwiftUI

struct CustomerListView: View {
    @StateObject private var vm: CustomerListViewModel = CustomerListViewModel()


    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // Segment + küçük durum satırı
                header
                
                // Error banner
                if let msg = vm.errorMessage, !msg.isEmpty {
                    Text(msg)
                        .font(.footnote)
                        .foregroundStyle(.white)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(.red.opacity(0.9))
                }
                
                // Liste
                listView
            }
            .navigationTitle("Customers")
            .task {
                // İlk girişte load
                if vm.activeCustomers.isEmpty && vm.archivedCustomers.isEmpty {
                    await vm.fetchCustomers()
                }
            }
        }
    }
}

// MARK: - UI Pieces
private extension CustomerListView {
    
    var header: some View {
        VStack(spacing: 10) {
            Picker("Segment", selection: $vm.selectedSegment) {
                ForEach(CustomerListViewModel.Segment.allCases, id: \.self) { seg in
                    Text(seg.rawValue).tag(seg)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            HStack(spacing: 12) {
                if vm.isLoading {
                    ProgressView()
                    Text("Loading...")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else if vm.isSearching {
                    ProgressView()
                    Text("Searching...")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(vm.customers.count) item")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if !vm.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button("Clear") { vm.searchText = "" }
                        .font(.footnote)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 6)
        }
        .padding(.top, 6)
    }
    
    var listView: some View {
        List {
            ForEach(vm.customers) { customer in
                CustomerRow(customer: customer)
                    .contentShape(Rectangle())
                    .task {
                        // Pagination tetik
                        await vm.loadMoreIfNeeded(currentItem: customer)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        if vm.selectedSegment == .active {
                            Button(role: .destructive) {
                                Task { await vm.toggleArchive(customer) }
                            } label: {
                                Label("Archive", systemImage: "archivebox")
                            }
                        } else {
                            Button {
                                Task { await vm.toggleArchive(customer) }
                            } label: {
                                Label("Unarchive", systemImage: "arrow.uturn.left")
                            }
                            .tint(.blue)
                        }
                    }
            }
            
            // Footer (load more spinner)
            if vm.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if vm.hasMoreData {
                // İstersen “Load more” manuel buton da bırakabiliriz
                EmptyView()
            }
        }
        .listStyle(.plain)
        .searchable(text: $vm.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search company / contact / email")
        .onChange(of: vm.searchText) { _, _ in
            vm.searchTextChanged()
        }
        .refreshable {
            await vm.refresh()
        }
    }
}

// MARK: - Row
private struct CustomerRow: View {
    let customer: Customer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(customer.companyName)
                .font(.headline)
            
            HStack(spacing: 10) {
                if let name = customer.contactName, !name.isEmpty {
                    Label(name, systemImage: "person")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if let email = customer.email, !email.isEmpty {
                    Label(email, systemImage: "envelope")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            if let phone = customer.phone, !phone.isEmpty {
                Label(phone, systemImage: "phone")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
#Preview {
    CustomerListView()
}
