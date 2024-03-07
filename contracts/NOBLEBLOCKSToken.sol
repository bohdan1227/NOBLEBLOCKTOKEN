// SPDX-License-Identifier: MIT

/**
 * @title NOBLEBLOCKS Token
 * @dev Upgradeable ERC20 Token for NOBLEBLOCKS
 * Website: www.nobleblocks.com
 * Email: info@nobleblocks.com
 */

pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract NOBLEBLOCKSToken_ is Initializable, ERC20Upgradeable, OwnableUpgradeable {
    
    address public developmentWallet;
    address public fundWallet;

    uint256 public constant TOTAL_FEE_LIMIT = 3000; // 30%

    uint16 public liquidityFee;
    uint16 public adminFee;
    uint16 public fundFee;

    mapping (address => bool) public isExcluded;
    mapping (address => bool) public isLimitExcluded;

    function initialize() public initializer {
        __ERC20_init("NOBLEBLOCKS", "NOBL");

        __Ownable_init(_msgSender());

        developmentWallet = 0xeE9B6aa7196C1d9a3Bb0dE858E1E0aB81D0cd0e0;
        fundWallet = 0xA21bb38c1c760F221D56f2e3226a27c9cdbe8061;

        liquidityFee = 167; // Approximately 1.67%
        adminFee = 167;     // Approximately 1.67%
        fundFee = 166;      // Approximately 1.66%

        isExcluded[owner()] = true;
        isExcluded[address(this)] = true;
        isExcluded[developmentWallet] = true;
        isExcluded[fundWallet] = true;

        isLimitExcluded[owner()] = true;
        isLimitExcluded[address(this)] = true;
        isLimitExcluded[developmentWallet] = true;
        isLimitExcluded[fundWallet] = true;

        _mint(owner(), 1e9 * (10 ** 18)); // Minting 1 billion NOBL tokens
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: Transfer amount must be greater than zero");

        uint256 transferAmount = amount;
        uint256 fee = 0;

        if(!isExcluded[from] && !isExcluded[to]){
            fee = amount * (liquidityFee + adminFee + fundFee) / 10000;
            transferAmount = amount - fee;
        }

        if(fee > 0) {
            super._transfer(from, fundWallet, fee);
        }

        super._transfer(from, to, transferAmount);
    }

    function setFees(uint16 _liquidityFee, uint16 _adminFee, uint16 _fundFee) external onlyOwner {
        require(_liquidityFee + _adminFee + _fundFee <= TOTAL_FEE_LIMIT, "Total fee exceeds max limit");

        liquidityFee = _liquidityFee;
        adminFee = _adminFee;
        fundFee = _fundFee;
    }

    function excludeFromFees(address account, bool excluded) external onlyOwner {
        isExcluded[account] = excluded;
    }

    function excludeFromLimit(address account, bool excluded) external onlyOwner {
        isLimitExcluded[account] = excluded;
    }

    function setDevelopmentWallet(address _developmentWallet) external onlyOwner {
        developmentWallet = _developmentWallet;
    }

    function setFundWallet(address _fundWallet) external onlyOwner {
        fundWallet = _fundWallet;
    }
}
