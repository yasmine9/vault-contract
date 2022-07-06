// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vault {
    mapping(address => uint256) private userToShares;
    mapping(address => bool) private hasDeposited;
    address[] public users;
    uint256 public totalShares;
    uint256 public totalEth;
    uint256 rate;
    address public owner;
    address payable public treasury;
    IERC20 vaultToken;

    constructor(uint256 _rate, address _treasury) {
        owner = msg.sender;
        rate = _rate;
        treasury = payable(_treasury);
    }

    function setVaultToken(IERC20 token) external {
        require(msg.sender == owner, "Only owner can set the vault token");
        require(address(vaultToken) != address(0), "vaultToken already set");
        require(
            address(token) != address(0),
            "Token address cannot be zero address"
        );

        vaultToken = token;
    }

    function deposit() external payable {
        require(msg.value > 0, "Should send some ether");
        totalEth += msg.value;
        totalShares += msg.value * rate;
        userToShares[msg.sender] += msg.value * rate;

        if (!hasDeposited[msg.sender]) {
            hasDeposited[msg.sender] = true;
            users.push(msg.sender);
        }

        (bool success, bytes memory data) = treasury.call{value: msg.value}("");
        require(success, "ETH transfer failed");
    }

    function redeem() external {
        uint256 amount = (userToShares[msg.sender] *
            vaultToken.balanceOf(address(this))) / totalShares;
        totalShares -= userToShares[msg.sender];
        userToShares[msg.sender] = 0;

        bool success = vaultToken.transfer(msg.sender, amount);
        require(success, "VaultToken tranfer failed: redeem reverted");
    }

    function sharesToTokens() external view returns (uint256 tokensAmount) {
        tokensAmount =
            (userToShares[msg.sender] * vaultToken.balanceOf(address(this))) /
            totalShares;
    }

    function getUserShares() external view returns (uint256 shares) {
        return userToShares[msg.sender];
    }

    function getUsersNb() external view returns (uint256 usersNumber) {
        return users.length;
    }

    function getTopTen() external view returns (address[] memory topUsers) {
        address[] memory temp;
        uint256 currentMin;
        uint256 minIndex;

        if (users.length >= 10) {
            // first 10 elements
            for (uint256 i = 0; i < 10; i++) {
                temp[i] = users[i];
            }
            (currentMin, minIndex) = _getMin(temp);

            for (uint256 i = 10; i < users.length; i++) {
                if (userToShares[users[i]] > currentMin) {
                    temp[minIndex] = users[i];
                    (currentMin, minIndex) = _getMin(temp);
                }
            }
            return _sortArray(temp);
        } else {
            return _sortArray(users);
        }
    }

    function _getMin(address[] memory _users)
        internal
        view
        returns (uint256 min, uint256 index)
    {
        require(_users.length > 0);
        uint256 currentMin = 2**256 - 1;
        for (uint256 i = 0; i < _users.length; i++) {
            if (userToShares[users[i]] < currentMin) {
                currentMin = userToShares[users[i]];
                index = i;
            }
        }
        return (currentMin, index);
    }

    function _sortArray(address[] memory _users)
        internal
        view
        returns (address[] memory sorted)
    {
        sorted = _users;
        quickSort(sorted, 0, int256(sorted.length - 1));
    }

    // @dev: quickSort adapted
    function quickSort(
        address[] memory arr,
        int256 left,
        int256 right
    ) internal view {
        int256 i = left;
        int256 j = right;
        if (i == j) return;
        address pivot = arr[uint256(left + (right - left) / 2)];
        while (i <= j) {
            while (userToShares[arr[uint256(i)]] > userToShares[pivot]) i++;
            while (userToShares[pivot] > userToShares[arr[uint256(j)]]) j--;
            if (i <= j) {
                (arr[uint256(i)], arr[uint256(j)]) = (
                    arr[uint256(j)],
                    arr[uint256(i)]
                );
                i++;
                j--;
            }
        }
        if (left < j) quickSort(arr, left, j);
        if (i < right) quickSort(arr, i, right);
    }

    function testingSort(address[] memory _users, uint256[] memory shares)
        external
    {
        for (uint256 i = 0; i < _users.length; i++) {
            users[i] = _users[i];
            userToShares[_users[i]] = shares[i];
            hasDeposited[_users[i]] = true;
        }
    }
}
