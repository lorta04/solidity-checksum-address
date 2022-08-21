// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title ChecksumAddress
 * @dev This library provides a function for computing the EIP-55 checksummed hexadecimal representation without
 * 0x prefix of an address.
 * This library uses toHexString implementation from Strings library of OpenZeppelin Contracts v4.7.0 to compute
 * hexadecimal string of an address.
 */
library ChecksumAddress {
    function toChecksumAddress(address src_) internal pure returns (string memory) {
        bytes32 srcBytes = bytes32(bytes20(src_));
        bytes32 hash = keccak256(abi.encodePacked(_toHexString(src_)));

        // string of length 40 bytes (address without 0x prefix)
        string memory res = new string(40);

        assembly {
            // skip length word
            let resPtr := add(res, 32)

            // initialize shift right amount
            let shiftRightAmount := 256

            for {
                let hexIndex := 0
            } lt(hexIndex, 40) {
                hexIndex := add(hexIndex, 1)
            } {
                // shift right by 252 - (4 * hexIndex) bits
                shiftRightAmount := sub(shiftRightAmount, 4)

                // shift right then extract only the 4 last bits
                let selectedAddressHex := and(shr(shiftRightAmount, srcBytes), 0xf)

                // if selectedAddressHex is a character
                switch gt(selectedAddressHex, 9)
                // if
                case 1 {
                    // shift right then extract only the 4 last bits
                    let selectedHashHex := and(shr(shiftRightAmount, hash), 0xf)

                    // if first bit of selectedHashHex is 1 (1XXX)
                    switch gt(selectedHashHex, 7)
                    // if
                    case 1 {
                        // append upper case character to res string
                        // offset 55

                        // store 8 bits (selectedAddressHex + 55) at res + 32 + hexIndex
                        mstore8(add(resPtr, hexIndex), add(selectedAddressHex, 55))
                    }
                    case 0 {
                        // append lower case character to res string
                        // offset 87

                        // store 8 bits (selectedAddressHex + 87) at res + 32 + hexIndex
                        mstore8(add(resPtr, hexIndex), add(selectedAddressHex, 87))
                    }
                }
                // else
                case 0 {
                    // append number to res string
                    // offset 48

                    // store 8 bits (selectedAddressHex + 48) at res + 32 + hexIndex
                    mstore8(add(resPtr, hexIndex), add(selectedAddressHex, 48))
                }
            }
        }

        return res;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)
    // Source file is from OpenZeppelin Contracts v4.7.0 MIT License. (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.7/contracts/utils/Strings.sol)
    // 0x prefix and unused functions are removed.

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     *
     * Edit: remove 0x prefix from buffer string.
     */
    function _toHexString(address addr) private pure returns (string memory) {
        uint256 value = uint256(uint160(addr));
        bytes memory buffer = new bytes(2 * _ADDRESS_LENGTH);
        for (int256 i = 2 * int256(uint256(_ADDRESS_LENGTH)) - 1; i > -1; --i) {
            buffer[uint256(i)] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        return string(buffer);
    }
}
