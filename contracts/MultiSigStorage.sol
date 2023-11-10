// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Hasher.sol";

contract MultiSigStorage {
    struct Transaction {
        address owner;
        bytes32 signature;
        string createdBy;
        address to;
        uint value;
        bytes data;
        bool executed;
    }

    uint256 public approveLimit;
    uint256 public counter;

    address[] public owners;
    mapping(address => bool) public isOwner;
    mapping(uint => mapping(address => bool)) public approved;

    Transaction[] public transactions;

    event Deposit(address indexed _sender, uint _amount);
    event Submit(uint indexed transactionId);
    event Approved(address indexed owner, uint _transactionId);
    event Revoke(address indexed owner, uint _transactionId);
    event Execute(uint indexed transactionId);

    constructor(address[] memory _owners, uint256 _approveLimit) {
        require(_owners.length > 0, "owners are required");
        require(
            _approveLimit > 0 && _approveLimit <= _owners.length,
            "ApproveLimit cannot be greater than the number of owners"
        );
        approveLimit = _approveLimit;

        address owner;
        for (uint i; i < _owners.length; i++) {
            owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "owner already exists");

            isOwner[owner] = true;
            owners.push(owner);
        }
    }
}
