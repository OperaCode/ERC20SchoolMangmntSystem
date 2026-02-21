// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "../token/IERC20.sol";

contract SchoolManagementSystem {
    IERC20 public immutable paymentToken;
    address public admin;

    constructor(address tokenAddress) {
        require(tokenAddress != address(0), "Token address zero");
        paymentToken = IERC20(tokenAddress);
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    
    // Levels allowed: 100, 200, 300, 400
    mapping(uint16 => uint256) public feeByLevel;

    event LevelFeeUpdated(uint16 indexed level, uint256 feeAmount);

    function setLevelFee(uint16 level, uint256 feeAmount) external onlyAdmin {
        require(_isValidLevel(level), "Invalid level");
        require(feeAmount > 0, "Fee must be > 0");

        feeByLevel[level] = feeAmount;
        emit LevelFeeUpdated(level, feeAmount);
    }

    function _isValidLevel(uint16 level) internal pure returns (bool) {
        return (level == 100 || level == 200 || level == 300 || level == 400);
    }

    //  Students 
    struct Student {
        uint256 id;
        string name;
        uint16 level;
        address wallet;

        bool isActive;

        bool feesPaid;
        uint256 feesPaidAt;
        uint256 totalFeesPaid;
    }

    uint256 public studentCount;
    mapping(uint256 => Student) private students;
    uint256[] private studentIds;

    // to prevent duplicate registration by wallet
    mapping(address => uint256) public studentIdByWallet;

    event StudentRegistered(
        uint256 indexed studentId,
        address indexed wallet,
        uint16 level,
        uint256 feePaid,
        uint256 timestamp
    );

    event StudentRemoved(uint256 indexed studentId, address indexed wallet, uint256 timestamp);

    function registerStudent(string calldata name, uint16 level) external {
        require(bytes(name).length > 0, "Name required");
        require(_isValidLevel(level), "Invalid level");
        require(studentIdByWallet[msg.sender] == 0, "Already registered");

        uint256 fee = feeByLevel[level];
        require(fee > 0, "Fee not set");

        // Student MUST approve this contract first
        require(paymentToken.allowance(msg.sender, address(this)) >= fee, "Approve fee first");

        bool ok = paymentToken.transferFrom(msg.sender, address(this), fee);
        require(ok, "Fee transfer failed");

        studentCount++;
        uint256 id = studentCount;

        students[id] = Student({
            id: id,
            name: name,
            level: level,
            wallet: msg.sender,
            isActive: true,
            feesPaid: true,
            feesPaidAt: block.timestamp,
            totalFeesPaid: fee
        });

        studentIds.push(id);
        studentIdByWallet[msg.sender] = id;

        emit StudentRegistered(id, msg.sender, level, fee, block.timestamp);
    }

    function removeStudent(uint256 studentId) external onlyAdmin {
        Student storage s = students[studentId];
        require(s.id != 0, "Student not found");
        require(s.isActive, "Already removed");

        s.isActive = false;
        studentIdByWallet[s.wallet] = 0;

        emit StudentRemoved(studentId, s.wallet, block.timestamp);
    }

    function getStudent(uint256 studentId) external view returns (Student memory) {
        Student memory s = students[studentId];
        require(s.id != 0, "Student not found");
        return s;
    }

    function getAllStudentIds() external view returns (uint256[] memory) {
        return studentIds;
    }

    // Staff
    struct Staff {
        uint256 id;
        string name;
        string role;
        address wallet;

        bool isActive;
        bool isSuspended;

        uint256 salary;
        bool salaryPaid;
        uint256 salaryPaidAt;
        uint256 totalSalaryPaid;
    }

    uint256 public staffCount;
    mapping(uint256 => Staff) private staffs;
    uint256[] private staffIds;

    event StaffEmployed(uint256 indexed staffId, address indexed wallet, string role, uint256 salary, uint256 timestamp);
    event StaffSuspended(uint256 indexed staffId, bool suspended, uint256 timestamp);
    event StaffRemoved(uint256 indexed staffId, uint256 timestamp);
    event StaffPaid(uint256 indexed staffId, address indexed wallet, uint256 amount, uint256 timestamp);

    function employStaff(
        string calldata name,
        string calldata role,
        address wallet,
        uint256 salary
    ) external onlyAdmin {
        require(bytes(name).length > 0, "Name required");
        require(bytes(role).length > 0, "Role required");
        require(wallet != address(0), "Wallet zero");
        require(salary > 0, "Salary must be > 0");

        staffCount++;
        uint256 id = staffCount;

        staffs[id] = Staff({
            id: id,
            name: name,
            role: role,
            wallet: wallet,
            isActive: true,
            isSuspended: false,
            salary: salary,
            salaryPaid: false,
            salaryPaidAt: 0,
            totalSalaryPaid: 0
        });

        staffIds.push(id);

        emit StaffEmployed(id, wallet, role, salary, block.timestamp);
    }

    function suspendStaff(uint256 staffId, bool suspended) external onlyAdmin {
        Staff storage st = staffs[staffId];
        require(st.id != 0, "Staff not found");
        require(st.isActive, "Staff inactive");

        st.isSuspended = suspended;
        emit StaffSuspended(staffId, suspended, block.timestamp);
    }

    function removeStaff(uint256 staffId) external onlyAdmin {
        Staff storage st = staffs[staffId];
        require(st.id != 0, "Staff not found");
        require(st.isActive, "Already removed");

        st.isActive = false;
        st.isSuspended = true;

        emit StaffRemoved(staffId, block.timestamp);
    }

    function payStaff(uint256 staffId) external onlyAdmin {
        Staff storage st = staffs[staffId];
        require(st.id != 0, "Staff not found");
        require(st.isActive, "Staff inactive");
        require(!st.isSuspended, "Staff suspended");

        uint256 amount = st.salary;
        require(amount > 0, "Salary not set");

        // contract pays from its own token balance (fees collected or admin funded)
        require(paymentToken.balanceOf(address(this)) >= amount, "Contract balance low");

        bool ok = paymentToken.transfer(st.wallet, amount);
        require(ok, "Salary transfer failed");

        st.salaryPaid = true;
        st.salaryPaidAt = block.timestamp;
        st.totalSalaryPaid += amount;

        emit StaffPaid(staffId, st.wallet, amount, block.timestamp);
    }

    function getStaff(uint256 staffId) external view returns (Staff memory) {
        Staff memory st = staffs[staffId];
        require(st.id != 0, "Staff not found");
        return st;
    }

    function getAllStaffIds() external view returns (uint256[] memory) {
        return staffIds;
    }

    //  Admin Treasury 
    function withdrawTokens(address to, uint256 amount) external onlyAdmin {
        require(to != address(0), "To zero");
        require(amount > 0, "Amount zero");
        require(paymentToken.balanceOf(address(this)) >= amount, "Insufficient");

        bool ok = paymentToken.transfer(to, amount);
        require(ok, "Withdraw failed");
    }

    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Admin zero");
        admin = newAdmin;
    }
}