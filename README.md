# ChainForge 

**Decentralized Supply Chain and Logistics Management System**

ChainForge is a comprehensive smart contract solution built on the Stacks blockchain that revolutionizes supply chain management through decentralized, transparent, and immutable logistics tracking.

## Overview

ChainForge enables businesses to create, manage, and track complex supply chain operations with complete transparency and accountability. From shipment manifests to supplier networks, routing chains to warehouse restrictions, ChainForge provides a complete toolkit for modern logistics management.

## Key Features

### Shipment Management
- **Shipment Manifests**: Create detailed shipment records with cargo descriptions, origin facilities, and delivery deadlines
- **Priority Systems**: Assign logistics priorities (1-10) for efficient resource allocation
- **Transfer Controls**: Toggle transferability and track dispatch information
- **Deadline Tracking**: Automatic overdue detection and management

### Supplier Network
- **Multi-Tier Suppliers**: Establish suppliers with hierarchical chain tiers (1-5)
- **Capacity Management**: Set and monitor supplier capacity limits and current loads
- **Authorization Systems**: Grant and manage shipment authorizations per supplier
- **Upstream Relationships**: Link suppliers in complex network structures

### Logistics Operations
- **Carrier Contracts**: Contract carriers to suppliers with flexible terms and expiry dates
- **Routing Chains**: Establish delivery routes with conditions and deadlines
- **Service Tiers**: Manage different levels of logistics services
- **Contract Lifecycle**: Full contract creation, management, and termination

### Warehouse Management
- **Access Restrictions**: Implement facility-specific access controls
- **Compliance Requirements**: Set and enforce clearance requirements
- **Time-Based Controls**: Configure restriction periods and authorities
- **Operational Status**: Track and manage warehouse operational states

### Governance & Directives
- **Logistics Directives**: Issue system-wide or targeted operational instructions
- **Voting Mechanisms**: Track compliance and resistance votes
- **Implementation Status**: Monitor directive execution and compliance
- **Authority Management**: Role-based directive issuance and management

## Security Features

### Input Validation
- Comprehensive parameter validation for all public functions
- Range checks for numeric inputs (priorities, capacities, time periods)
- String length and content validation
- Entity existence verification for references

### Access Controls
- **Contract Coordinator**: System-wide administrative privileges
- **Supply Managers**: Supplier-specific management rights
- **Authorization Checks**: Multi-level permission verification
- **Role-Based Access**: Function-specific access controls

### Data Integrity
- Immutable audit trails for all operations
- Cryptographic proof of all transactions
- Tamper-proof record keeping
- Blockchain-verified timestamps

## Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks development environment
- [Stacks CLI](https://docs.stacks.co/docs/command-line-interface) - Command line interface
- Basic understanding of Clarity smart contracts

### Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/nonsodominic/supply-chain-and-logistics-management.git
   cd chainforge
   ```

2. **Initialize Clarinet Project**
   ```bash
   clarinet new chainforge
   cd chainforge
   ```

3. **Add the Contract**
   ```bash
   # Copy the contract file to contracts/supply.clar
   cp /path/to/chainforge-contract.clar contracts/supply.clar
   ```

4. **Verify Contract**
   ```bash
   clarinet check
   ```

### Quick Start Example

```clarity
;; Deploy a new shipment
(contract-call? .supply forge-shipment-manifest
  "Electronics Components"     ;; cargo-description
  "Factory Alpha - Building 1" ;; origin-facility
  u5                          ;; logistics-priority
  true                        ;; is-transferable
  (some u1000)               ;; delivery-deadline
  "Fragile items, handle with care" ;; manifest-notes
)

;; Establish a new supplier
(contract-call? .supply establish-supplier
  "Regional Distribution Hub"  ;; supplier-designation
  u3                          ;; chain-tier
  none                        ;; upstream-supplier
  u100                        ;; max-capacity
  true                        ;; routing-enabled
)

;; Contract a logistics carrier
(contract-call? .supply contract-logistics-carrier
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 ;; carrier
  u1                          ;; supplier-id
  (some u2000)               ;; contract-expiry
  "Standard delivery terms"   ;; contract-terms
)
```

## API Reference

### Public Functions

#### Shipment Management
- `forge-shipment-manifest` - Create new shipment records
- `grant-supplier-shipment-authorization` - Authorize suppliers for shipments

#### Supplier Operations
- `establish-supplier` - Register new suppliers in the network
- `contract-logistics-carrier` - Contract carriers to suppliers
- `terminate-carrier-contract` - End carrier contracts

#### Routing & Logistics
- `establish-routing-chain` - Create delivery routes
- `cancel-routing-chain` - Cancel active routes
- `engage-warehouse-restriction` - Implement facility restrictions

#### Governance
- `issue-logistics-directive` - Create operational directives
- `configure-transit-window` - Update system-wide transit settings

### Read-Only Functions

#### Data Retrieval
- `get-shipment-details` - Retrieve shipment information
- `get-supplier-details` - Get supplier network data
- `get-assignment-details` - View carrier assignments
- `get-routing-status` - Check routing chain status
- `get-restriction-status` - View warehouse restrictions
- `get-directive-details` - Access logistics directives

#### Validation & Status
- `verify-shipping-clearance` - Check carrier permissions
- `validate-tier-access` - Verify chain tier requirements
- `check-supply-manager` - Confirm management privileges
- `check-shipment-overdue` - Detect overdue shipments

#### System Information
- `get-transit-window` - Current transit window setting
- `get-total-shipments` - System shipment count
- `get-total-suppliers` - Network supplier count
- `get-total-directives` - Active directives count

## Configuration

### System Parameters

| Parameter | Default | Range | Description |
|-----------|---------|-------|-------------|
| Transit Window | 144 blocks | 6-1440 blocks | Standard delivery timeframe |
| Priority Levels | 1-10 | 1-10 | Logistics priority scale |
| Chain Tiers | 1-5 | 1-5 | Supplier hierarchy levels |
| Max Capacity | Variable | 1-1000 | Supplier capacity limits |

### Error Codes

| Code | Error | Description |
|------|-------|-------------|
| 500 | `err-coordinator-only` | Function restricted to contract coordinator |
| 501 | `err-insufficient-clearance` | Insufficient permissions for operation |
| 502 | `err-shipment-not-found` | Referenced shipment does not exist |
| 503 | `err-supplier-not-exists` | Referenced supplier not found |
| 504 | `err-logistics-conflict` | Capacity or scheduling conflict |
| 505 | `err-routing-forbidden` | Route establishment not permitted |
| 506 | `err-chain-protocol-violation` | Chain hierarchy rules violated |
| 507 | `err-warehouse-locked` | Facility access restricted |
| 508 | `err-invalid-input` | Input validation failed |

## 🧪 Testing

### Running Tests
```bash
# Run all tests
clarinet test

# Run specific test file
clarinet test tests/supply_test.ts

# Check contract syntax
clarinet check
```

### Test Coverage
- Unit tests for all public functions
- Integration tests for complex workflows
- Edge case validation
- Security and access control testing
- Gas optimization verification

## Use Cases

### Supply Chain Transparency
- **End-to-End Tracking**: Complete visibility from origin to destination
- **Audit Trails**: Immutable records for compliance and verification
- **Quality Control**: Track handling conditions and requirements

### Logistics Optimization
- **Route Planning**: Optimal path selection and carrier assignment
- **Capacity Management**: Efficient resource allocation and load balancing
- **Performance Metrics**: Delivery time tracking and supplier evaluation

### Compliance & Governance
- **Regulatory Compliance**: Automated compliance checking and reporting
- **Policy Enforcement**: Consistent application of logistics policies
- **Risk Management**: Proactive identification and mitigation of supply risks

### Business Intelligence
- **Analytics**: Data-driven insights for operational improvement
- **Forecasting**: Predictive analysis for demand and capacity planning
- **Cost Optimization**: Identify cost-saving opportunities and inefficiencies

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Submit a pull request

### Code Standards
- Follow Clarity best practices
- Include comprehensive tests
- Document all public functions
- Validate all inputs