// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../libraries/DataTypes.sol";

contract WelfareStorage {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant NGO_ROLE = keccak256("NGO_ROLE");
    
    uint internal _programIdCounter;
    uint internal _voucherIdCounter;
    uint internal _complaintIdCounter;
    
    mapping(uint => DataTypes.Program) public programs;
    mapping(address => DataTypes.NGO) public ngos;
    mapping(address => DataTypes.Vendor) public vendors;
    mapping(address => DataTypes.Member) public members;
    mapping(uint => DataTypes.VoucherNFT) public vouchers;
    mapping(uint => DataTypes.Complaint) public complaints;
    mapping(bytes32 => uint) internal smsCodeToVoucher;
    mapping(address => uint[]) internal memberVouchers;
    mapping(address => uint[]) internal vendorRedeemedVouchers;
    mapping(address => uint[]) internal userComplaints;
    
    uint[] internal allProgramIds;
    address[] internal allNGOAddresses;
    address[] internal allVendorAddresses;
    address[] internal allMemberAddresses;
    uint[] internal allVoucherIds;
    uint[] internal allComplaintIds;
}