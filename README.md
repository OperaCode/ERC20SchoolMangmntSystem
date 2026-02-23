# School Management System (ERC20 Payments) 🎓💸

A Solidity-based **School Management System** that manages students, staff, and payments using a **custom ERC20 token built from scratch**.

The system supports:

- Student registration & fee payments
- Staff employment, suspension & salary payments
- Level-based pricing (100 – 400)
- Payment tracking with timestamps
- Full on-chain record keeping

All payments are executed using **OPERAPAY (OPPY)**.

---

## 🪙 Payment Token — OPERAPAY (OPPY)

A custom ERC20 token built **from scratch (no OpenZeppelin)** and used as the official payment currency of the school.

| Property | Value |
|----------|--------|
| Token Name | OPERAPAY |
| Symbol | OPPY |
| Decimals | 18 |
| Total Supply | 26e18 (26 OPPY) |
| Standard | ERC20 (Custom Implementation) |

The deployer receives the full supply at deployment.

---

## ✨ Features

### 🎓 Students

- Register students with:
  - Name
  - Level (100 / 200 / 300 / 400)
  - Wallet address (msg.sender)
- Fee is paid using OPY during registration
- Tracks:
  - `feesPaid`
  - `feesPaidAt` (timestamp)
  - `totalFeesPaid`
  - `isActive`
- Admin can remove students
- Fetch:
  - Student by ID
  - All student IDs

---

### 👨‍🏫 Staff

- Admin can:
  - Employ new staff
  - Suspend staff
  - Remove staff
  - Pay staff salary using OPPY
- Tracks:
  - `salaryPaid`
  - `salaryPaidAt`
  - `totalSalaryPaid`
  - `isActive`
  - `isSuspended`
- Fetch:
  - Staff by ID
  - All staff IDs

---

### 💰 Fee System

Admin sets school fees based on level:

Supported Levels:
- 100
- 200
- 300
- 400


### Project Structure using Foundry
school-system/
│
├── src/
│   ├── token/
│   │   ├── IERC20.sol
│   │   └── OPERAPAY.sol
│   │
│   └── school/
│       └── SchoolManagementSystem.sol
│
├── script/
│   └── Deploy.s.sol
│
├── foundry.toml
├── .env
└── README.md