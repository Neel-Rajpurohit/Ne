import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(AppColors.emerald)
            
            Text(appState.userProfile?.name ?? "User Name")
                .font(.title)
                .bold()
            
            Text(appState.userProfile?.educationType.rawValue ?? "Education Type")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Profile")
    }
}
