# StackSocial

## Decentralized Reputation & Monetization for Creators

A Bitcoin-secured Clarity smart contract for decentralized creator monetization, social engagement rewards, and NFT-based reputation and membership systems built on the Stacks L2.

## Overview

StackSocial empowers creators and users in a trustless, Bitcoin-backed ecosystem by combining a programmable reputation economy, non-fungible membership tiers, and microtransaction-based engagement incentives. The protocol enables creators to monetize engagement while building verifiable social capital.

## Key Features

- **Reputation Decay & Reward Systems**: Dynamic reputation scoring with time-based decay mechanisms
- **Tip-Based Engagement**: Direct creator monetization through STX micropayments
- **NFT Certificates**: Mintable reputation and membership certificates as proof of standing
- **Tiered Membership**: Four-tier system (Bronze, Silver, Gold, Platinum) with increasing benefits
- **Creator-Configurable Parameters**: Customizable earning thresholds and reward structures
- **Treasury Governance**: Administrative controls and emergency functions
- **Bitcoin Security**: Built with Clarity on Stacks, secured by Bitcoin finality

## System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Users       │    │    Creators     │    │     Admin       │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          ▼                      ▼                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                    StackSocial Contract                        │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────┐ │
│  │ Reputation  │  │ Engagement  │  │     NFT     │  │Treasury │ │
│  │   System    │  │   Rewards   │  │   Minting   │  │  Mgmt   │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │  Stacks Network │
                    │ (Bitcoin Layer) │
                    └─────────────────┘
```

## Contract Architecture

### Core Data Structures

- **User Profiles**: Track reputation scores, activity, earnings, and NFT ownership
- **Creator Settings**: Configurable monetization parameters and status
- **Engagement History**: Immutable record of all platform interactions
- **Membership Tiers**: Hierarchical access levels with defined benefits
- **NFT Metadata**: Reputation and membership certificate information

### Smart Contract Components

1. **Reputation Engine**
   - Time-based decay mechanism (24-hour periods)
   - Activity-based scoring system
   - Maximum reputation cap (10,000 points)

2. **Engagement System**
   - Tip functionality with minimum thresholds
   - Social interactions (like, share, comment, follow)
   - Cooldown periods to prevent spam

3. **NFT System**
   - Reputation certificates for verified achievements
   - Membership tokens for tier-based access
   - Metadata tracking and ownership management

4. **Treasury Management**
   - Automated reward distribution
   - Emergency withdrawal capabilities
   - Contract pause/unpause functionality

## Data Flow

### User Engagement Flow

```
User Action → Reputation Update → Engagement Recording → Reward Processing → NFT Eligibility Check
```

### Creator Monetization Flow

```
Creator Setup → Tip Reception → Automatic Reward → Reputation Increase → Tier Advancement
```

### NFT Minting Flow

```
Eligibility Check → Reputation Threshold → NFT Creation → Metadata Storage → Ownership Transfer
```

## Membership Tiers

| Tier | Min Reputation | Benefits | Access Level |
|------|---------------|----------|--------------|
| Bronze | 1,000 | Basic access to creator content | Level 1 |
| Silver | 2,000 | Enhanced access + exclusive content | Level 2 |
| Gold | 5,000 | Premium access + governance rights | Level 3 |
| Platinum | 8,000 | Full access + revenue sharing | Level 4 |

## Getting Started

### For Users

1. **Initialize Profile**: Call `initialize-user-profile` to begin earning reputation
2. **Engage**: Interact with creators through tips and social engagements
3. **Build Reputation**: Accumulate points through consistent platform activity
4. **Mint Certificates**: Create NFT proof of your reputation achievements

### For Creators

1. **Setup Profile**: Use `setup-creator-profile` with your monetization parameters
2. **Configure Rewards**: Set earning thresholds and per-engagement rewards
3. **Receive Tips**: Accept STX payments from supporters
4. **Manage Status**: Toggle active/inactive status as needed

### For Administrators

1. **Tier Management**: Configure membership tiers with `set-membership-tier`
2. **Contract Control**: Pause/unpause contract during maintenance
3. **Emergency Functions**: Access treasury withdrawal capabilities

## Technical Specifications

- **Language**: Clarity (Stacks blockchain)
- **Security**: Bitcoin-backed finality
- **Token Standards**: Non-fungible tokens for certificates
- **Minimum Tip**: 1 STX (1,000,000 microSTX)
- **Reputation Decay**: 144 blocks (~24 hours)
- **Engagement Cooldown**: 6 blocks (~1 hour)

## Error Codes

- `u100`: Unauthorized action
- `u101`: Resource already exists
- `u102`: Resource not found
- `u103`: Insufficient balance
- `u104`: Invalid amount
- `u105`: Invalid threshold
- `u106`: Invalid tier
- `u107`: Cooldown period active
- `u108`: Expired reputation

## Security Features

- **Contract Owner Controls**: Administrative functions restricted to deployer
- **Pause Mechanism**: Emergency contract suspension capability
- **Cooldown Periods**: Spam prevention through time-based restrictions
- **Balance Checks**: Comprehensive validation for all transfers
- **Input Validation**: Strict parameter checking for all public functions

## License

This project is built on the Stacks blockchain using Clarity smart contracts. The code is provided as-is for educational and development purposes.

## Contributing

Contributions are welcome! Please ensure all changes maintain the security and integrity of the reputation and monetization systems.
