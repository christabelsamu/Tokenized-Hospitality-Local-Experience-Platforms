# Tokenized Hospitality Local Experience Platform

A decentralized platform for managing authentic local tourism experiences using blockchain technology and smart contracts written in Clarity.

## Overview

This platform connects tourists with verified local experience providers and certified guides, ensuring authentic cultural experiences while maintaining quality standards through community-driven verification and satisfaction tracking.

## Smart Contracts

### 1. Experience Provider Verification (`experience-provider-verification.clar`)
- **Purpose**: Validates and verifies local experience providers
- **Key Features**:
    - Provider registration with business details
    - Document-based verification process
    - Admin approval system
    - Verification status tracking

### 2. Booking Coordination (`booking-coordination.clar`)
- **Purpose**: Manages experience bookings between tourists and providers
- **Key Features**:
    - Experience listing creation
    - Booking management with status tracking
    - Payment coordination
    - Multi-party confirmation system

### 3. Guide Certification (`guide-certification.clar`)
- **Purpose**: Certifies local experience guides through testing and evaluation
- **Key Features**:
    - Guide profile registration
    - Comprehensive certification testing
    - Multi-level certification system
    - Rating and review system

### 4. Cultural Authenticity (`cultural-authenticity.clar`)
- **Purpose**: Ensures authentic cultural experiences through expert assessment
- **Key Features**:
    - Cultural expert registry
    - Multi-criteria authenticity assessment
    - Community feedback integration
    - Authenticity scoring system

### 5. Tourist Satisfaction (`tourist-satisfaction.clar`)
- **Purpose**: Tracks and measures tourist experience satisfaction
- **Key Features**:
    - Comprehensive review system
    - Multi-dimensional rating system
    - Provider and experience analytics
    - Satisfaction metrics tracking

## Key Features

### For Experience Providers
- **Verification Process**: Submit business documents for verification
- **Experience Management**: Create and manage experience listings
- **Booking Coordination**: Receive and manage booking requests
- **Performance Tracking**: Monitor ratings and reviews

### For Guides
- **Certification Program**: Complete comprehensive testing
- **Profile Management**: Maintain professional guide profile
- **Rating System**: Build reputation through tourist reviews
- **Specialization Tracking**: Showcase expertise areas

### For Tourists
- **Verified Experiences**: Book only verified, authentic experiences
- **Quality Assurance**: Access certified guides and providers
- **Review System**: Share experiences and rate services
- **Cultural Authenticity**: Enjoy verified authentic experiences

### For Cultural Experts
- **Expert Registry**: Register as cultural authenticity assessor
- **Assessment Tools**: Evaluate experience authenticity
- **Community Impact**: Ensure cultural respect and community benefit

## Contract Architecture

\`\`\`
┌─────────────────────┐    ┌─────────────────────┐
│ Experience Provider │    │ Guide Certification │
│    Verification     │    │                     │
└─────────────────────┘    └─────────────────────┘
│                           │
└─────────┬─────────────────┘
│
┌─────────────────────┐
│ Booking Coordination│
│                     │
└─────────────────────┘
│
┌─────────┬─────────────────┐
│         │                 │
┌─────────────────────┐    ┌─────────────────────┐
│ Cultural Authenticity│    │ Tourist Satisfaction│
│                     │    │                     │
└─────────────────────┘    └─────────────────────┘
\`\`\`

## Getting Started

### Prerequisites
- Stacks blockchain development environment
- Clarity CLI tools
- Node.js for testing

### Installation

1. Clone the repository:
   \`\`\`bash
   git clone <repository-url>
   cd tokenized-hospitality-platform
   \`\`\`

2. Install dependencies:
   \`\`\`bash
   npm install
   \`\`\`

3. Run tests:
   \`\`\`bash
   npm test
   \`\`\`

### Deployment

Deploy contracts to Stacks blockchain:

\`\`\`bash
# Deploy provider verification contract
clarinet deploy contracts/experience-provider-verification.clar

# Deploy booking coordination contract
clarinet deploy contracts/booking-coordination.clar

# Deploy guide certification contract
clarinet deploy contracts/guide-certification.clar

# Deploy cultural authenticity contract
clarinet deploy contracts/cultural-authenticity.clar

# Deploy tourist satisfaction contract
clarinet deploy contracts/tourist-satisfaction.clar
\`\`\`

## Usage Examples

### Register as Experience Provider
\`\`\`clarity
(contract-call? .experience-provider-verification register-provider
"Local Heritage Tours"
"San Francisco"
"Cultural Tours")
\`\`\`

### Create Experience Listing
\`\`\`clarity
(contract-call? .booking-coordination create-experience
"Historic Chinatown Walking Tour"
"Explore authentic Chinatown with local stories"
u50
u120
u8
"San Francisco Chinatown")
\`\`\`

### Book Experience
\`\`\`clarity
(contract-call? .booking-coordination book-experience
u1
u1640995200
u2)
\`\`\`

## Testing

The platform includes comprehensive tests using Vitest:

- **Provider Verification Tests**: Registration, verification process, admin controls
- **Booking Coordination Tests**: Experience creation, booking flow, status management
- **Guide Certification Tests**: Registration, testing, certification, ratings

Run tests:
\`\`\`bash
npm test
\`\`\`

## Security Considerations

- **Access Control**: Admin-only functions for verification and certification
- **Input Validation**: Comprehensive validation of all user inputs
- **State Management**: Proper state transitions and status checking
- **Payment Security**: Escrow-style payment holding during booking process

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions and support, please open an issue in the GitHub repository.
