# Health Rewards System

A blockchain-based health rewards system that encourages users to achieve their wellness goals through tokenized incentives and achievements.

## Overview

The Health Rewards System is a smart contract built on the Stacks blockchain that allows users to:
- Create personalized health quests with specific activity targets
- Log activities and track progress toward goals
- Earn wellness points that determine member tiers
- Collect achievements for completed quests
- Receive token rewards for meeting health goals

## Features

### For Members
- **Profile Registration**: Create a personal health profile to track wellness metrics
- **Custom Health Quests**: Set personalized activity goals with deadlines
- **Activity Tracking**: Log progress toward quest completion
- **Rewards**: Earn tokens when successfully completing health quests
- **Achievements**: Collect digital badges that showcase wellness accomplishments
- **Tier System**: Progress through member tiers based on activity and accomplishments

### For Administrators
- **Token Management**: Add tokens to the reward pool
- **System Metrics**: View platform statistics including member count and available rewards
- **Administrative Controls**: Transfer system management to other accounts

## Smart Contract Functions

### Public Functions
- `register-member`: Create a new member profile
- `start-health-quest`: Begin a new health quest with a specific target
- `log-activity`: Record progress toward a quest goal
- `claim-quest-reward`: Collect tokens for completing a quest

### Read-Only Functions
- `get-member-profile`: View a member's health metrics and status
- `get-quest-details`: Examine the details of a specific health quest
- `get-member-achievements`: List all achievements earned by a member
- `get-system-metrics`: View platform-wide statistics

### Administrative Functions
- `add-reward-tokens`: Increase the token reward pool
- `transfer-system-control`: Change the system administrator

## Error Codes
- `ERR-UNAUTHORIZED-ACCESS (u100)`: Access attempt by unauthorized user
- `ERR-DUPLICATE-MEMBER-REGISTRATION (u101)`: Member already registered
- `ERR-MEMBER-PROFILE-NOT-FOUND (u102)`: Referenced member profile does not exist
- `ERR-INVALID-HEALTH-GOAL (u103)`: Health quest parameters are invalid
- `ERR-INSUFFICIENT-REWARD-BALANCE (u104)`: Not enough tokens in reward pool
- `ERR-INVALID-REWARD-AMOUNT (u105)`: Invalid token amount provided
- `ERR-INVALID-ACTIVITY-UNITS (u106)`: Activity units must be greater than zero
- `ERR-INVALID-QUEST-ID (u107)`: Referenced quest does not exist

## Getting Started

### Prerequisites
- Stacks wallet
- Clarity development environment

### Deployment
1. Clone this repository
2. Deploy the contract using Clarity CLI or Stacks Explorer
3. Initialize the reward pool by calling `add-reward-tokens`

### Usage Example
```clarity
;; Register as a member
(contract-call? .health-rewards register-member)

;; Start a new health quest (10,000 steps in 7 days)
(contract-call? .health-rewards start-health-quest u10000 (+ block-height u1008) "steps")

;; Log activity progress (5,000 steps)
(contract-call? .health-rewards log-activity u1 u5000)

;; Complete the quest by logging remaining activity
(contract-call? .health-rewards log-activity u1 u5000)

;; Claim reward tokens
(contract-call? .health-rewards claim-quest-reward u1)
```

## Contributors
- Chineye Precious - Initial work