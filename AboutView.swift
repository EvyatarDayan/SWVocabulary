//
//  AboutView.swift
//  SWVocabulary
//
//  Created by EVYATAR DAYAN on 2026-01-26.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // App Version
                    VStack(alignment: .center, spacing: 8) {
                        Text(appVersion)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // About SWVocabulary Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About SWVocabulary")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("SWVocabulary is a comprehensive Swedish vocabulary learning app designed to help you master Swedish words with ease. Practice vocabulary with multiple-choice questions, test your knowledge with translation exercises, and track your progress. Learn Swedish words with accurate English translations and example sentences. Build your vocabulary systematically with word states (new, learning, review, weak, mastered) and never miss a learning opportunity again.")
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // About ABASHELARI Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About ABASHELARI")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("At ABASHELARI, we believe in creating software that makes everyday life simpler, smarter, and more enjoyable. Our mission is to develop innovative digital solutions that blend creativity with technology, offering users tools that are intuitive, reliable, and engaging.")
                            .font(.body)
                            .multilineTextAlignment(.leading)
                        
                        Text("Whether it's educational apps, lifestyle tools, or entertainment experiences, ABASHELARI is dedicated to delivering high-quality products that inspire learning, spark curiosity, and bring value to people around the world.")
                            .font(.body)
                            .multilineTextAlignment(.leading)
                        
                        Text("Driven by passion and guided by innovation, ABASHELARI is committed to continuous improvement and to building software that connects people with what matters most.")
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("About")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AboutView()
}
