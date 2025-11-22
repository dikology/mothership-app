//
//  User.swift
//  mothership
//
//  User model with types and community affiliations
//

import Foundation

// MARK: - User Type

enum UserType: String, Codable, CaseIterable {
    case captain = "captain"
    case crew = "crew"
    case traveler = "traveler"
    
    var displayName: String {
        switch self {
        case .captain: return "Captain"
        case .crew: return "Crew"
        case .traveler: return "Traveler"
        }
    }
    
    var icon: String {
        switch self {
        case .captain: return "person.fill.checkmark"
        case .crew: return "person.2.fill"
        case .traveler: return "suitcase.fill"
        }
    }
}

// MARK: - Community

struct Community: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let displayName: String
    let description: String?
    let icon: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        displayName: String,
        description: String? = nil,
        icon: String? = nil
    ) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.description = description
        self.icon = icon
    }
}

extension Community {
    static let silaVetra = Community(
        name: "sila_vetra",
        displayName: "Sila Vetra",
        description: "Sailing community",
        icon: "wind"
    )
    
    static let sailingVirgins = Community(
        name: "sailing_virgins",
        displayName: "Sailing Virgins",
        description: "Community for new sailors",
        icon: "sailboat"
    )
}

// MARK: - User Model

struct User: Identifiable, Codable {
    let id: UUID
    let appleUserID: String // From Apple Sign In
    var email: String?
    var displayName: String
    var userType: UserType
    var communities: [Community]
    var createdAt: Date
    var lastUpdated: Date
    
    // Profile information
    var bio: String?
    var experienceLevel: ExperienceLevel?
    var certifications: [Certification]
    var sailingHistory: [SailingExperience]
    
    // UGC and reputation
    var reputation: Int = 0
    var contributionsCount: Int = 0
    
    // Optional GitHub username for power users
    var githubUsername: String?
    
    init(
        id: UUID = UUID(),
        appleUserID: String,
        email: String? = nil,
        displayName: String,
        userType: UserType = .traveler,
        communities: [Community] = [],
        createdAt: Date = Date(),
        lastUpdated: Date = Date(),
        bio: String? = nil,
        experienceLevel: ExperienceLevel? = nil,
        certifications: [Certification] = [],
        sailingHistory: [SailingExperience] = [],
        reputation: Int = 0,
        contributionsCount: Int = 0,
        githubUsername: String? = nil
    ) {
        self.id = id
        self.appleUserID = appleUserID
        self.email = email
        self.displayName = displayName
        self.userType = userType
        self.communities = communities
        self.createdAt = createdAt
        self.lastUpdated = lastUpdated
        self.bio = bio
        self.experienceLevel = experienceLevel
        self.certifications = certifications
        self.sailingHistory = sailingHistory
        self.reputation = reputation
        self.contributionsCount = contributionsCount
        self.githubUsername = githubUsername
    }
}

// MARK: - Experience Level

enum ExperienceLevel: String, Codable, CaseIterable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    case expert = "expert"
    
    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .expert: return "Expert"
        }
    }
}

// MARK: - Certification

struct Certification: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let issuingOrganization: String
    let issueDate: Date?
    let expiryDate: Date?
    let certificateNumber: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        issuingOrganization: String,
        issueDate: Date? = nil,
        expiryDate: Date? = nil,
        certificateNumber: String? = nil
    ) {
        self.id = id
        self.name = name
        self.issuingOrganization = issuingOrganization
        self.issueDate = issueDate
        self.expiryDate = expiryDate
        self.certificateNumber = certificateNumber
    }
}

// MARK: - Sailing Experience

struct SailingExperience: Identifiable, Codable {
    let id: UUID
    let role: String // "Captain", "Crew", "Passenger"
    let vesselType: String?
    let location: String?
    let startDate: Date
    let endDate: Date?
    let description: String?
    
    init(
        id: UUID = UUID(),
        role: String,
        vesselType: String? = nil,
        location: String? = nil,
        startDate: Date,
        endDate: Date? = nil,
        description: String? = nil
    ) {
        self.id = id
        self.role = role
        self.vesselType = vesselType
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.description = description
    }
}

