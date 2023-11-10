// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library Hasher {
    function hash(
        string memory _name,
        uint256 _id,
        address _address
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_name, _id, _address));
    }
}
