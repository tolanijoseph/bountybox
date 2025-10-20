# BountyBox Smart Contract

A decentralized bug bounty and reward payment system built on the Stacks blockchain using Clarity. BountyBox ensures secure, trustless payments for completed work through verified escrow.

## Overview

BountyBox allows organizations and individuals to create bug bounties or task rewards with funds held in escrow until work is verified and completed. This eliminates trust issues in freelance and bounty hunting scenarios.

## Features

- ✅ **Escrow System**: Funds are locked in the contract until work is verified
- ✅ **Verified Completion**: Two-step verification (submission + approval) before payment
- ✅ **Secure Payments**: STX tokens held safely until all conditions are met
- ✅ **Cancellation Protection**: Creators can cancel and refund before work starts
- ✅ **Transparent Workflow**: All bounty states are visible on-chain
- ✅ **Prevention of Double-claiming**: Built-in safeguards against duplicate payments

## How It Works

### Workflow

```
1. Creator creates bounty → Funds locked in contract
2. Creator assigns bounty to hunter
3. Hunter completes work and submits
4. Creator verifies the completion
5. Hunter claims the reward
```

## Smart Contract Functions

### Public Functions

#### `create-bounty`
Creates a new bounty with STX payment held in escrow.

**Parameters:**
- `description` (string-ascii 256): Description of the bounty/task
- `amount` (uint): Amount of STX to be paid (in microSTX)

**Returns:** Bounty ID

**Example:**
```clarity
(contract-call? .bountybox create-bounty "Fix authentication bug in login module" u1000000)
```

---

#### `assign-bounty`
Assigns a bounty to a specific hunter.

**Parameters:**
- `bounty-id` (uint): The ID of the bounty
- `hunter` (principal): The Stacks address of the hunter

**Authorization:** Only bounty creator

**Example:**
```clarity
(contract-call? .bountybox assign-bounty u0 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

---

#### `submit-completion`
Hunter marks their work as complete and ready for verification.

**Parameters:**
- `bounty-id` (uint): The ID of the bounty

**Authorization:** Only assigned hunter

**Example:**
```clarity
(contract-call? .bountybox submit-completion u0)
```

---

#### `verify-completion`
Creator verifies that the work meets requirements.

**Parameters:**
- `bounty-id` (uint): The ID of the bounty

**Authorization:** Only bounty creator

**Example:**
```clarity
(contract-call? .bountybox verify-completion u0)
```

---

#### `claim-bounty`
Hunter claims the payment after verification.

**Parameters:**
- `bounty-id` (uint): The ID of the bounty

**Authorization:** Only assigned hunter (after verification)

**Example:**
```clarity
(contract-call? .bountybox claim-bounty u0)
```

---

#### `cancel-bounty`
Creator cancels the bounty and receives a refund.

**Parameters:**
- `bounty-id` (uint): The ID of the bounty

**Authorization:** Only bounty creator (before completion)

**Example:**
```clarity
(contract-call? .bountybox cancel-bounty u0)
```

---

### Read-Only Functions

#### `get-bounty`
Retrieves bounty details.

**Parameters:**
- `bounty-id` (uint): The ID of the bounty

**Returns:** Bounty details or none

**Example:**
```clarity
(contract-call? .bountybox get-bounty u0)
```

---

#### `get-bounty-nonce`
Gets the current bounty counter (total bounties created).

**Returns:** Current nonce value

**Example:**
```clarity
(contract-call? .bountybox get-bounty-nonce)
```

---

## Data Structure

### Bounty Object

```clarity
{
  creator: principal,        // Address of bounty creator
  hunter: (optional principal), // Address of assigned hunter
  amount: uint,              // Payment amount in microSTX
  description: string-ascii, // Task description
  completed: bool,           // Hunter marked as complete
  verified: bool,            // Creator verified completion
  claimed: bool              // Payment has been claimed
}
```

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u100 | `err-owner-only` | Operation requires contract owner |
| u101 | `err-not-found` | Bounty does not exist |
| u102 | `err-already-exists` | Resource already exists |
| u103 | `err-unauthorized` | Caller not authorized for this action |
| u104 | `err-invalid-amount` | Amount must be greater than 0 |
| u105 | `err-already-completed` | Bounty already completed |
| u106 | `err-already-claimed` | Bounty already claimed |

## Use Cases

### Bug Bounty Programs
Organizations can create bounties for security vulnerabilities with guaranteed payment upon verification.

### Freelance Tasks
Clients can escrow payment for development work, ensuring freelancers get paid for completed work.

### Open Source Contributions
Projects can incentivize specific features or fixes with verifiable on-chain payments.

### Community Rewards
DAOs and communities can reward members for completing specific tasks.

## Security Considerations

- ✅ Funds are held in contract escrow and cannot be accessed by creator after bounty creation
- ✅ Only assigned hunters can submit completion
- ✅ Only creators can verify completion
- ✅ Double-claim protection prevents duplicate payments
- ✅ Cancellation only possible before work is submitted
- ✅ All state transitions are protected by assertions

## Deployment

### Prerequisites
- Stacks blockchain node or access to testnet/mainnet
- Clarinet CLI for local testing
- STX tokens for contract deployment

### Testing Locally

```bash
# Install Clarinet
curl -L https://github.com/hirosystems/clarinet/releases/download/v1.0.0/clarinet-linux-x64.tar.gz | tar xz

# Test the contract
clarinet test

# Deploy to testnet
clarinet deploy --testnet
```

## Example Usage

```clarity
;; 1. Create a bounty for 1 STX (1000000 microSTX)
(contract-call? .bountybox create-bounty "Fix API rate limiting bug" u1000000)
;; Returns: (ok u0) - Bounty ID is 0

;; 2. Assign to hunter
(contract-call? .bountybox assign-bounty u0 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
;; Returns: (ok true)

;; 3. Hunter submits completion
(contract-call? .bountybox submit-completion u0)
;; Returns: (ok true)

;; 4. Creator verifies
(contract-call? .bountybox verify-completion u0)
;; Returns: (ok true)

;; 5. Hunter claims payment
(contract-call? .bountybox claim-bounty u0)
;; Returns: (ok true) - STX transferred to hunter
```

## Future Enhancements

- Multi-signature verification for larger bounties
- Partial payment milestones
- Dispute resolution mechanism
- Bounty expiration dates
- Hunter reputation system
- Support for SIP-010 fungible tokens

## Contributing

Contributions are welcome! Please submit pull requests or open issues for bugs and feature requests.

## Support

For questions or issues, please open a GitHub issue.

---

**Built with ❤️ on Stacks Blockchain**