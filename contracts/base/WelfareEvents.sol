// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract WelfareEvents {
    event ProgramCreated(uint indexed programId, string name, uint value);
    event ProgramUpdated(uint indexed programId, string name, uint value);
    event NGORegistered(address indexed ngo, string name);
    event NGOUpdated(address indexed ngo, string name);
    event VendorRegistered(address indexed vendor, string shopName);
    event VendorApproved(address indexed vendor);
    event VendorUpdated(address indexed vendor, string shopName);
    event MemberRegistered(address indexed member, string name);
    event MemberUpdated(address indexed member, string name);
    event VoucherIssued(uint indexed voucherId, address indexed to, uint programId);
    event VoucherRedeemed(uint indexed voucherId, address indexed vendor);
    event VoucherRevoked(uint indexed voucherId);
    event VendorSettled(address indexed vendor, uint amount);
    event ComplaintRaised(uint indexed complaintId, address indexed raisedBy);
    event ComplaintResolved(uint indexed complaintId);
    event ContractPaused();
    event ContractUnpaused();
}