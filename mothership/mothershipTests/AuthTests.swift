//
//  AuthTests.swift
//  mothershipTests
//
//  Tests for authentication system - Swift Testing version
//

import Testing
@testable import mothership

@MainActor
struct AuthTests {
    
    // MARK: - User Model Tests
    
    @Test("User type has correct display names")
    func userType_DisplayNames() async throws {
        #expect(UserType.captain.displayName == "Captain")
        #expect(UserType.crew.displayName == "Crew")
        #expect(UserType.traveler.displayName == "Traveler")
    }
    
    @Test("User type has correct icons")
    func userType_Icons() async throws {
        #expect(UserType.captain.icon == "person.fill.checkmark")
        #expect(UserType.crew.icon == "person.2.fill")
        #expect(UserType.traveler.icon == "suitcase.fill")
    }
    
    @Test("User type is codable")
    func userType_Codable() async throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        for userType in UserType.allCases {
            let data = try encoder.encode(userType)
            let decoded = try decoder.decode(UserType.self, from: data)
            #expect(decoded == userType)
        }
    }
    
    @Test("Community initialization")
    func community_Initialization() async throws {
        let community = Community(
            name: "test_community",
            displayName: "Test Community",
            description: "Test description",
            icon: "test.icon"
        )
        
        #expect(community.name == "test_community")
        #expect(community.displayName == "Test Community")
        #expect(community.description == "Test description")
        #expect(community.icon == "test.icon")
    }
    
    @Test("Community predefined communities exist")
    func community_PredefinedCommunities() async throws {
        #expect(Community.silaVetra.name == "sila_vetra")
        #expect(Community.silaVetra.displayName == "Sila Vetra")
        #expect(Community.sailingVirgins.name == "sailing_virgins")
        #expect(Community.sailingVirgins.displayName == "Sailing Virgins")
    }
    
    @Test("Community is hashable")
    func community_Hashable() async throws {
        let community1 = Community(name: "test", displayName: "Test")
        let community2 = Community(name: "test", displayName: "Test")
        let community3 = Community(name: "other", displayName: "Other")
        
        var set = Set<Community>()
        set.insert(community1)
        set.insert(community2)
        set.insert(community3)
        
        // community1 and community2 have different IDs, so both should be in set
        #expect(set.count == 3)
    }
    
    @Test("User initialization with required fields")
    func user_Initialization() async throws {
        let user = User(
            appleUserID: "test123",
            displayName: "Test User",
            userType: .traveler
        )
        
        #expect(user.appleUserID == "test123")
        #expect(user.displayName == "Test User")
        #expect(user.userType == .traveler)
        #expect(user.communities.isEmpty)
        #expect(user.certifications.isEmpty)
        #expect(user.sailingHistory.isEmpty)
        #expect(user.reputation == 0)
        #expect(user.contributionsCount == 0)
    }
    
    @Test("User initialization with all fields")
    func user_InitializationWithAllFields() async throws {
        let community = Community.silaVetra
        let certification = Certification(
            name: "RYA Day Skipper",
            issuingOrganization: "RYA"
        )
        
        let user = User(
            appleUserID: "test123",
            email: "test@example.com",
            displayName: "Test User",
            userType: .captain,
            communities: [community],
            bio: "Test bio",
            experienceLevel: .advanced,
            certifications: [certification],
            reputation: 10,
            contributionsCount: 5
        )
        
        #expect(user.email == "test@example.com")
        #expect(user.userType == .captain)
        #expect(user.communities.count == 1)
        #expect(user.communities.first?.id == community.id)
        #expect(user.bio == "Test bio")
        #expect(user.experienceLevel == .advanced)
        #expect(user.certifications.count == 1)
        #expect(user.reputation == 10)
        #expect(user.contributionsCount == 5)
    }
    
    @Test("User is codable")
    func user_Codable() async throws {
        let originalUser = User(
            appleUserID: "test123",
            email: "test@example.com",
            displayName: "Test User",
            userType: .captain,
            communities: [Community.silaVetra],
            bio: "Test bio",
            experienceLevel: .advanced
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalUser)
        let decoder = JSONDecoder()
        let decodedUser = try decoder.decode(User.self, from: data)
        
        #expect(decodedUser.id == originalUser.id)
        #expect(decodedUser.appleUserID == originalUser.appleUserID)
        #expect(decodedUser.displayName == originalUser.displayName)
        #expect(decodedUser.userType == originalUser.userType)
        #expect(decodedUser.communities.count == originalUser.communities.count)
    }
    
    // MARK: - Experience Level Tests
    
    @Test("Experience level has correct display names")
    func experienceLevel_DisplayNames() async throws {
        #expect(ExperienceLevel.beginner.displayName == "Beginner")
        #expect(ExperienceLevel.intermediate.displayName == "Intermediate")
        #expect(ExperienceLevel.advanced.displayName == "Advanced")
        #expect(ExperienceLevel.expert.displayName == "Expert")
    }
    
    // MARK: - Certification Tests
    
    @Test("Certification initialization")
    func certification_Initialization() async throws {
        let issueDate = Date()
        let expiryDate = Calendar.current.date(byAdding: .year, value: 1, to: issueDate)
        
        let cert = Certification(
            name: "RYA Day Skipper",
            issuingOrganization: "RYA",
            issueDate: issueDate,
            expiryDate: expiryDate,
            certificateNumber: "12345"
        )
        
        #expect(cert.name == "RYA Day Skipper")
        #expect(cert.issuingOrganization == "RYA")
        #expect(cert.issueDate == issueDate)
        #expect(cert.expiryDate == expiryDate)
        #expect(cert.certificateNumber == "12345")
    }
    
    // MARK: - TokenManager Tests
    
    @Test("TokenManager saves and loads user data")
    func tokenManager_SaveAndLoadUser() async throws {
        let tokenManager = TokenManager.shared
        let testUser = User(
            appleUserID: "test_user_123",
            displayName: "Test User",
            userType: .traveler
        )
        
        // Save user
        try tokenManager.saveUser(testUser)
        
        // Load user
        let loadedUser = tokenManager.loadUser()
        #expect(loadedUser != nil)
        #expect(loadedUser?.id == testUser.id)
        #expect(loadedUser?.appleUserID == testUser.appleUserID)
        #expect(loadedUser?.displayName == testUser.displayName)
        
        // Cleanup
        tokenManager.deleteUser()
    }
    
    @Test("TokenManager deletes user data")
    func tokenManager_DeleteUser() async throws {
        let tokenManager = TokenManager.shared
        let testUser = User(
            appleUserID: "test_user_456",
            displayName: "Test User",
            userType: .traveler
        )
        
        // Save user
        try tokenManager.saveUser(testUser)
        #expect(tokenManager.loadUser() != nil)
        
        // Delete user
        tokenManager.deleteUser()
        #expect(tokenManager.loadUser() == nil)
    }
    
    @Test("TokenManager saves and loads Apple token")
    func tokenManager_SaveAndLoadAppleToken() async throws {
        let tokenManager = TokenManager.shared
        let testToken = "test_apple_token_123"
        
        // Save token
        try tokenManager.saveAppleToken(testToken)
        
        // Load token
        let loadedToken = tokenManager.loadAppleToken()
        #expect(loadedToken == testToken)
        
        // Cleanup
        tokenManager.deleteAppleToken()
    }
    
    @Test("TokenManager deletes Apple token")
    func tokenManager_DeleteAppleToken() async throws {
        let tokenManager = TokenManager.shared
        let testToken = "test_apple_token_456"
        
        // Save token
        try tokenManager.saveAppleToken(testToken)
        #expect(tokenManager.loadAppleToken() != nil)
        
        // Delete token
        tokenManager.deleteAppleToken()
        #expect(tokenManager.loadAppleToken() == nil)
    }
    
    // MARK: - UserStore Tests
    
    @Test("UserStore initializes without user")
    func userStore_Initialization() async throws {
        let store = UserStore()
        #expect(store.currentUser == nil)
        #expect(!store.isAuthenticated)
    }
    
    @Test("UserStore loads stored user")
    func userStore_LoadsStoredUser() async throws {
        // Setup: Save a user to TokenManager
        let tokenManager = TokenManager.shared
        let testUser = User(
            appleUserID: "test_user_load",
            displayName: "Test User",
            userType: .captain
        )
        try tokenManager.saveUser(testUser)
        
        // Create new store (should load user)
        let store = UserStore()
        #expect(store.currentUser != nil)
        #expect(store.currentUser?.appleUserID == testUser.appleUserID)
        #expect(store.isAuthenticated)
        
        // Cleanup
        tokenManager.deleteUser()
    }
    
    @Test("UserStore sign out clears user")
    func userStore_SignOut() async throws {
        // Setup: Save a user
        let tokenManager = TokenManager.shared
        let testUser = User(
            appleUserID: "test_user_signout",
            displayName: "Test User",
            userType: .traveler
        )
        try tokenManager.saveUser(testUser)
        
        let store = UserStore()
        #expect(store.isAuthenticated)
        
        // Sign out
        store.signOut()
        #expect(!store.isAuthenticated)
        #expect(store.currentUser == nil)
        #expect(tokenManager.loadUser() == nil)
    }
    
    @Test("UserStore update user type")
    func userStore_UpdateUserType() async throws {
        // Setup: Create and save user
        let tokenManager = TokenManager.shared
        let testUser = User(
            appleUserID: "test_user_type",
            displayName: "Test User",
            userType: .traveler
        )
        try tokenManager.saveUser(testUser)
        
        let store = UserStore()
        #expect(store.currentUser?.userType == .traveler)
        
        // Update user type
        try store.updateUserType(.captain)
        #expect(store.currentUser?.userType == .captain)
        
        // Verify persistence
        let reloadedStore = UserStore()
        #expect(reloadedStore.currentUser?.userType == .captain)
        
        // Cleanup
        tokenManager.deleteUser()
    }
    
    @Test("UserStore add community")
    func userStore_AddCommunity() async throws {
        // Setup: Create and save user
        let tokenManager = TokenManager.shared
        let testUser = User(
            appleUserID: "test_user_community",
            displayName: "Test User",
            userType: .traveler,
            communities: []
        )
        try tokenManager.saveUser(testUser)
        
        let store = UserStore()
        #expect(store.currentUser?.communities.isEmpty == true)
        
        // Add community
        try store.addCommunity(.silaVetra)
        #expect(store.currentUser?.communities.count == 1)
        #expect(store.currentUser?.communities.first?.id == Community.silaVetra.id)
        
        // Cleanup
        tokenManager.deleteUser()
    }
    
    @Test("UserStore remove community")
    func userStore_RemoveCommunity() async throws {
        // Setup: Create and save user with community
        let tokenManager = TokenManager.shared
        let testUser = User(
            appleUserID: "test_user_remove_community",
            displayName: "Test User",
            userType: .traveler,
            communities: [.silaVetra]
        )
        try tokenManager.saveUser(testUser)
        
        let store = UserStore()
        #expect(store.currentUser?.communities.count == 1)
        
        // Remove community
        try store.removeCommunity(.silaVetra)
        #expect(store.currentUser?.communities.isEmpty == true)
        
        // Cleanup
        tokenManager.deleteUser()
    }
    
    @Test("UserStore update experience level")
    func userStore_UpdateExperienceLevel() async throws {
        // Setup: Create and save user
        let tokenManager = TokenManager.shared
        let testUser = User(
            appleUserID: "test_user_experience",
            displayName: "Test User",
            userType: .traveler
        )
        try tokenManager.saveUser(testUser)
        
        let store = UserStore()
        #expect(store.currentUser?.experienceLevel == nil)
        
        // Update experience level
        try store.updateExperienceLevel(.intermediate)
        #expect(store.currentUser?.experienceLevel == .intermediate)
        
        // Cleanup
        tokenManager.deleteUser()
    }
    
    @Test("UserStore add certification")
    func userStore_AddCertification() async throws {
        // Setup: Create and save user
        let tokenManager = TokenManager.shared
        let testUser = User(
            appleUserID: "test_user_cert",
            displayName: "Test User",
            userType: .captain,
            certifications: []
        )
        try tokenManager.saveUser(testUser)
        
        let store = UserStore()
        #expect(store.currentUser?.certifications.isEmpty == true)
        
        // Add certification
        let cert = Certification(
            name: "RYA Day Skipper",
            issuingOrganization: "RYA"
        )
        try store.addCertification(cert)
        #expect(store.currentUser?.certifications.count == 1)
        #expect(store.currentUser?.certifications.first?.name == "RYA Day Skipper")
        
        // Cleanup
        tokenManager.deleteUser()
    }
    
    @Test("UserStore remove certification")
    func userStore_RemoveCertification() async throws {
        // Setup: Create and save user with certification
        let tokenManager = TokenManager.shared
        let cert = Certification(
            name: "RYA Day Skipper",
            issuingOrganization: "RYA"
        )
        let testUser = User(
            appleUserID: "test_user_remove_cert",
            displayName: "Test User",
            userType: .captain,
            certifications: [cert]
        )
        try tokenManager.saveUser(testUser)
        
        let store = UserStore()
        #expect(store.currentUser?.certifications.count == 1)
        
        // Remove certification
        try store.removeCertification(cert)
        #expect(store.currentUser?.certifications.isEmpty == true)
        
        // Cleanup
        tokenManager.deleteUser()
    }
    
    @Test("UserStore does not add duplicate community")
    func userStore_NoDuplicateCommunity() async throws {
        // Setup: Create and save user with community
        let tokenManager = TokenManager.shared
        let testUser = User(
            appleUserID: "test_user_duplicate",
            displayName: "Test User",
            userType: .traveler,
            communities: [.silaVetra]
        )
        try tokenManager.saveUser(testUser)
        
        let store = UserStore()
        #expect(store.currentUser?.communities.count == 1)
        
        // Try to add same community again
        try store.addCommunity(.silaVetra)
        #expect(store.currentUser?.communities.count == 1, "Should not add duplicate community")
        
        // Cleanup
        tokenManager.deleteUser()
    }
}

