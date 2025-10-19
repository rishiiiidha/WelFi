// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./libraries/DataTypes.sol";
import "./base/WelfareStorage.sol";
import "./base/WelfareEvents.sol";

contract WelfareVoucherSystem is 
    ERC721, 
    AccessControl, 
    Pausable, 
    ReentrancyGuard, 
    WelfareStorage, 
    WelfareEvents 
{
    
    constructor() ERC721("WelfareVoucher", "WVCH") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }
    
    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Not admin");
        _;
    }
    
    modifier onlyNGO() {
        require(hasRole(NGO_ROLE, msg.sender), "Not NGO");
        _;
    }
    
    modifier onlyAdminOrNGO() {
        require(hasRole(ADMIN_ROLE, msg.sender) || hasRole(NGO_ROLE, msg.sender), "Not authorized");
        _;
    }
    
    function createProgram(string memory name, uint value, string memory eligibility) 
        external onlyAdmin whenNotPaused returns (uint) {
        _programIdCounter++;
        uint id = _programIdCounter;
        programs[id] = DataTypes.Program(id, name, value, eligibility, true, 0, 0);
        allProgramIds.push(id);
        emit ProgramCreated(id, name, value);
        return id;
    }
    
    function updateProgram(uint id, string memory name, uint value, string memory eligibility) 
        external onlyAdmin whenNotPaused {
        require(programs[id].id != 0, "Not found");
        programs[id].name = name;
        programs[id].value = value;
        programs[id].eligibility = eligibility;
        emit ProgramUpdated(id, name, value);
    }
    
    function getProgram(uint id) external view returns (DataTypes.Program memory) {
        require(programs[id].id != 0, "Not found");
        return programs[id];
    }
    
    function getAllPrograms() external view returns (DataTypes.Program[] memory) {
        DataTypes.Program[] memory result = new DataTypes.Program[](allProgramIds.length);
        for (uint i = 0; i < allProgramIds.length; i++) {
            result[i] = programs[allProgramIds[i]];
        }
        return result;
    }
    
    function registerNGO(address ngo, string memory name) external onlyAdmin whenNotPaused {
        require(ngos[ngo].ngoAddress == address(0), "Exists");
        ngos[ngo] = DataTypes.NGO(ngo, name, true, 0, 0, 0);
        _grantRole(NGO_ROLE, ngo);
        allNGOAddresses.push(ngo);
        emit NGORegistered(ngo, name);
    }
    
    function updateNGO(address ngo, string memory name) external onlyAdmin whenNotPaused {
        require(ngos[ngo].ngoAddress != address(0), "Not found");
        ngos[ngo].name = name;
        emit NGOUpdated(ngo, name);
    }
    
    function getNGO(address ngo) external view returns (DataTypes.NGO memory) {
        require(ngos[ngo].ngoAddress != address(0), "Not found");
        return ngos[ngo];
    }
    
    function getAllNGOs() external view returns (DataTypes.NGO[] memory) {
        DataTypes.NGO[] memory result = new DataTypes.NGO[](allNGOAddresses.length);
        for (uint i = 0; i < allNGOAddresses.length; i++) {
            result[i] = ngos[allNGOAddresses[i]];
        }
        return result;
    }
    
    function registerVendor(address vendor, string memory shopName, string memory bankHash) 
        external onlyAdminOrNGO whenNotPaused {
        require(vendors[vendor].vendorAddress == address(0), "Exists");
        vendors[vendor] = DataTypes.Vendor(vendor, shopName, bankHash, false, 0, 0, 0);
        if (hasRole(NGO_ROLE, msg.sender)) ngos[msg.sender].vendorsRegistered++;
        allVendorAddresses.push(vendor);
        emit VendorRegistered(vendor, shopName);
    }
    
    function approveVendor(address vendor) external onlyAdmin whenNotPaused {
        require(vendors[vendor].vendorAddress != address(0), "Not found");
        vendors[vendor].isApproved = true;
        emit VendorApproved(vendor);
    }
    
    function updateVendor(address vendor, string memory shopName, string memory bankHash) 
        external onlyAdminOrNGO whenNotPaused {
        require(vendors[vendor].vendorAddress != address(0), "Not found");
        vendors[vendor].shopName = shopName;
        vendors[vendor].bankHash = bankHash;
        emit VendorUpdated(vendor, shopName);
    }
    
    function getVendor(address vendor) external view returns (DataTypes.Vendor memory) {
        require(vendors[vendor].vendorAddress != address(0), "Not found");
        return vendors[vendor];
    }
    
    function getAllVendors() external view returns (DataTypes.Vendor[] memory) {
        DataTypes.Vendor[] memory result = new DataTypes.Vendor[](allVendorAddresses.length);
        for (uint i = 0; i < allVendorAddresses.length; i++) {
            result[i] = vendors[allVendorAddresses[i]];
        }
        return result;
    }
    
    function registerMember(address member, string memory name, string memory phone, string memory photoHash) 
        external onlyAdminOrNGO whenNotPaused {
        require(members[member].memberAddress == address(0), "Exists");
        members[member] = DataTypes.Member(member, name, phone, photoHash, true, 0, 0);
        if (hasRole(NGO_ROLE, msg.sender)) ngos[msg.sender].membersRegistered++;
        allMemberAddresses.push(member);
        emit MemberRegistered(member, name);
    }
    
    function updateMember(address member, string memory name, string memory phone, string memory photoHash) 
        external onlyAdminOrNGO whenNotPaused {
        require(members[member].memberAddress != address(0), "Not found");
        members[member].name = name;
        members[member].phone = phone;
        members[member].photoHash = photoHash;
        emit MemberUpdated(member, name);
    }
    
    function getMember(address member) external view returns (DataTypes.Member memory) {
        require(members[member].memberAddress != address(0), "Not found");
        return members[member];
    }
    
    function getAllMembers() external view returns (DataTypes.Member[] memory) {
        DataTypes.Member[] memory result = new DataTypes.Member[](allMemberAddresses.length);
        for (uint i = 0; i < allMemberAddresses.length; i++) {
            result[i] = members[allMemberAddresses[i]];
        }
        return result;
    }
    
    function issueVoucherNFT(address member, uint programId, string memory smsCode) 
        external onlyAdmin whenNotPaused returns (uint) {
        require(members[member].memberAddress != address(0), "Member not found");
        require(programs[programId].id != 0 && programs[programId].active, "Invalid program");
        
        _voucherIdCounter++;
        uint id = _voucherIdCounter;
        bytes32 hash = keccak256(abi.encodePacked(smsCode));
        require(smsCodeToVoucher[hash] == 0, "Code used");
        
        vouchers[id] = DataTypes.VoucherNFT(id, member, programId, hash, false, address(0), 0, block.timestamp, false);
        smsCodeToVoucher[hash] = id;
        memberVouchers[member].push(id);
        allVoucherIds.push(id);
        _safeMint(member, id);
        
        members[member].vouchersReceived++;
        programs[programId].issuedCount++;
        emit VoucherIssued(id, member, programId);
        return id;
    }
    
    function revokeVoucher(uint id) external onlyAdmin whenNotPaused {
        require(vouchers[id].id != 0 && !vouchers[id].redeemed && !vouchers[id].revoked, "Invalid");
        vouchers[id].revoked = true;
        emit VoucherRevoked(id);
    }
    
    function getVoucher(uint id) external view returns (DataTypes.VoucherNFT memory) {
        require(vouchers[id].id != 0, "Not found");
        return vouchers[id];
    }
    
    function getVouchers(address member) external view returns (uint[] memory) {
        return memberVouchers[member];
    }
    
    function getAllVouchers() external view returns (DataTypes.VoucherNFT[] memory) {
        DataTypes.VoucherNFT[] memory result = new DataTypes.VoucherNFT[](allVoucherIds.length);
        for (uint i = 0; i < allVoucherIds.length; i++) {
            result[i] = vouchers[allVoucherIds[i]];
        }
        return result;
    }
    
    function redeemVoucher(string memory smsCode) external whenNotPaused nonReentrant {
        require(vendors[msg.sender].isApproved, "Not approved");
        bytes32 hash = keccak256(abi.encodePacked(smsCode));
        uint id = smsCodeToVoucher[hash];
        require(id != 0 && !vouchers[id].redeemed && !vouchers[id].revoked, "Invalid voucher");
        
        vouchers[id].redeemed = true;
        vouchers[id].redeemedBy = msg.sender;
        vouchers[id].redeemedAt = block.timestamp;
        
        uint value = programs[vouchers[id].programId].value;
        vendors[msg.sender].pendingBalance += value;
        vendors[msg.sender].totalEarned += value;
        vendors[msg.sender].vouchersRedeemed++;
        vendorRedeemedVouchers[msg.sender].push(id);
        
        members[vouchers[id].member].vouchersRedeemed++;
        programs[vouchers[id].programId].redeemedCount++;
        
        emit VoucherRedeemed(id, msg.sender);
    }
    
    function isVoucherRedeemed(uint id) external view returns (bool) {
        require(vouchers[id].id != 0, "Not found");
        return vouchers[id].redeemed;
    }
    
    function settleVendor(address vendor) external payable onlyAdmin whenNotPaused nonReentrant {
        uint amount = vendors[vendor].pendingBalance;
        require(amount > 0 && msg.value >= amount, "Invalid amount");
        vendors[vendor].pendingBalance = 0;
        (bool ok, ) = vendor.call{value: amount}("");
        require(ok, "Transfer failed");
        emit VendorSettled(vendor, amount);
        if (msg.value > amount) {
            (ok, ) = msg.sender.call{value: msg.value - amount}("");
            require(ok, "Refund failed");
        }
    }
    
    function getVendorPendingBalance(address vendor) external view returns (uint) {
        return vendors[vendor].pendingBalance;
    }
    
    function claimSettlement(address vendor) external whenNotPaused nonReentrant {
        require(msg.sender == vendor, "Unauthorized");
        uint amount = vendors[vendor].pendingBalance;
        require(amount > 0 && address(this).balance >= amount, "Invalid");
        vendors[vendor].pendingBalance = 0;
        (bool ok, ) = vendor.call{value: amount}("");
        require(ok, "Transfer failed");
        emit VendorSettled(vendor, amount);
    }
    
    function raiseComplaint(address user, string memory desc) external whenNotPaused {
        _complaintIdCounter++;
        uint id = _complaintIdCounter;
        complaints[id] = DataTypes.Complaint(id, user, desc, false, "", block.timestamp, 0);
        userComplaints[user].push(id);
        allComplaintIds.push(id);
        emit ComplaintRaised(id, user);
    }
    
    function resolveComplaint(uint id, string memory note) external onlyAdminOrNGO whenNotPaused {
        require(complaints[id].id != 0 && !complaints[id].resolved, "Invalid");
        complaints[id].resolved = true;
        complaints[id].resolutionNote = note;
        complaints[id].resolvedAt = block.timestamp;
        emit ComplaintResolved(id);
    }
    
    function getComplaint(uint id) external view returns (DataTypes.Complaint memory) {
        require(complaints[id].id != 0, "Not found");
        return complaints[id];
    }
    
    function getComplaints(address user) external view returns (uint[] memory) {
        return userComplaints[user];
    }
    
    function getAllComplaints() external view returns (DataTypes.Complaint[] memory) {
        DataTypes.Complaint[] memory result = new DataTypes.Complaint[](allComplaintIds.length);
        for (uint i = 0; i < allComplaintIds.length; i++) {
            result[i] = complaints[allComplaintIds[i]];
        }
        return result;
    }
    
    function getProgramStats(uint id) external view returns (DataTypes.ProgramStats memory) {
        require(programs[id].id != 0, "Not found");
        return DataTypes.ProgramStats(
            programs[id].issuedCount,
            programs[id].redeemedCount,
            programs[id].value * programs[id].redeemedCount,
            programs[id].issuedCount - programs[id].redeemedCount
        );
    }
    
    function getVendorHistory(address vendor) external view returns (uint[] memory) {
        return vendorRedeemedVouchers[vendor];
    }
    
    function getMemberHistory(address member) external view returns (uint[] memory) {
        return memberVouchers[member];
    }
    
    function getSystemStats() external view returns (DataTypes.SystemStats memory) {
        uint redeemed = 0;
        uint valueDisbursed = 0;
        for (uint i = 0; i < allVoucherIds.length; i++) {
            if (vouchers[allVoucherIds[i]].redeemed) {
                redeemed++;
                valueDisbursed += programs[vouchers[allVoucherIds[i]].programId].value;
            }
        }
        return DataTypes.SystemStats(
            allProgramIds.length,
            allMemberAddresses.length,
            allVendorAddresses.length,
            allNGOAddresses.length,
            allVoucherIds.length,
            redeemed,
            valueDisbursed
        );
    }
    
    function setAdmin(address admin) external onlyAdmin {
        _grantRole(ADMIN_ROLE, admin);
    }
    
    function pauseContract() external onlyAdmin {
        _pause();
        emit ContractPaused();
    }
    
    function unpauseContract() external onlyAdmin {
        _unpause();
        emit ContractUnpaused();
    }
    
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    
    receive() external payable {}
    
    function withdrawExcess() external onlyAdmin {
        require(address(this).balance > 0, "No balance");
        (bool ok, ) = msg.sender.call{value: address(this).balance}("");
        require(ok, "Failed");
    }
}