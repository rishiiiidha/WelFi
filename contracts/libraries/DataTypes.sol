// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library DataTypes {
    struct Program {
        uint id;
        string name;
        uint value;
        string eligibility;
        bool active;
        uint issuedCount;
        uint redeemedCount;
    }
    
    struct NGO {
        address ngoAddress;
        string name;
        bool active;
        uint commissionEarned;
        uint membersRegistered;
        uint vendorsRegistered;
    }
    
    struct Vendor {
        address vendorAddress;
        string shopName;
        string bankHash;
        bool isApproved;
        uint pendingBalance;
        uint totalEarned;
        uint vouchersRedeemed;
    }
    
    struct Member {
        address memberAddress;
        string name;
        string phone;
        string photoHash;
        bool active;
        uint vouchersReceived;
        uint vouchersRedeemed;
    }
    
    struct VoucherNFT {
        uint id;
        address member;
        uint programId;
        bytes32 smsCodeHash;
        bool redeemed;
        address redeemedBy;
        uint redeemedAt;
        uint issuedAt;
        bool revoked;
    }
    
    struct Complaint {
        uint id;
        address raisedBy;
        string description;
        bool resolved;
        string resolutionNote;
        uint raisedAt;
        uint resolvedAt;
    }
    
    struct ProgramStats {
        uint totalIssued;
        uint totalRedeemed;
        uint totalValue;
        uint activeVouchers;
    }
    
    struct SystemStats {
        uint totalPrograms;
        uint totalMembers;
        uint totalVendors;
        uint totalNGOs;
        uint totalVouchers;
        uint totalRedeemed;
        uint totalValueDisbursed;
    }
}