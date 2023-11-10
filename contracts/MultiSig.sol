// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./Hasher.sol";
import {MultiSigStorage} from "./MultiSigStorage.sol";

/**
 * @author 3illBaby
 * @title A MultiSig Wallet
 * @dev This is an Aya Week 5 assignment
 *
 */

contract MultiSig is MultiSigStorage {
    constructor(
        address[] memory _owners,
        uint256 _approvalLimit
    ) MultiSigStorage(_owners, _approvalLimit) {}

    /**
     * @dev //! Contract Modifiers
     */
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Only owner can call this function");
        _;
    }

    modifier txExists(uint _id) {
        require(_id < counter, "Transaction does not exist");
        _;
    }

    modifier notApproved(uint _id) {
        require(
            !approved[_id][msg.sender],
            "This transaction has already been approved by you "
        );
        _;
    }

    modifier notExecuted(uint _id) {
        require(
            !transactions[_id].executed,
            "Transaction has already been executed"
        );
        _;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @param _name this is the name of the owner
     * @param _to this is the receiver of the transaction
     * @param _amount this is the amount being transferred to the receiver
     * @param _data this is additional data
     */
    function submitTransaction(
        string memory _name,
        address _to,
        uint _amount,
        bytes calldata _data
    ) external onlyOwner {
        uint id = counter++;
        transactions.push(
            Transaction({
                owner: msg.sender,
                signature: Hasher.hash(_name, id, msg.sender),
                createdBy: _name,
                to: _to,
                value: _amount,
                data: _data,
                executed: false
            })
        );

        emit Submit(id);
    }

    /**
     * @param _transactionId this is the identifier of the transaction
     */
    function getApprovalCount(
        uint _transactionId
    ) internal view returns (uint count) {
        for (uint i; i < owners.length; i++) {
            if (approved[_transactionId][owners[i]]) {
                count += 1;
            }
        }
    }

    function approve(
        uint _id
    ) external onlyOwner txExists(_id) notApproved(_id) notExecuted(_id) {
        Transaction memory txs = transactions[_id];
        require(
            txs.signature == Hasher.hash(txs.createdBy, _id, txs.owner),
            "This transaction was not signed by an owner "
        );

        approved[_id][msg.sender] = true;

        emit Approved(msg.sender, _id);
    }

    function execute(uint _id) external txExists(_id) notExecuted(_id) {
        require(
            getApprovalCount(_id) >= approveLimit,
            "not enough approvals to excute this transaction"
        );

        Transaction storage transaction = transactions[_id];
        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "This transaction failed");

        emit Execute(_id);
    }

    function revoke(
        uint _id
    ) external onlyOwner txExists(_id) notExecuted(_id) {
        require(approved[_id][msg.sender], "transaction has not been approved");
        approved[_id][msg.sender] = false;
        emit Revoke(msg.sender, _id);
    }
}
