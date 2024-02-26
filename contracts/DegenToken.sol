// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DegenToken is ERC20, Ownable {
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor() ERC20("Degen", "DGN") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _chargeTransferFee(_msgSender(), amount);
        _transfer(_msgSender(), to, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _chargeTransferFee(sender, amount);
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

   function redeem(uint256 playerAmount) public returns (bool) {
    require(playerAmount > 0, "Amount must be greater than 0");
    
    uint256 totalTokensRequired = playerAmount * 10; // 10% of the playerAmount

    require(balanceOf(msg.sender) >= totalTokensRequired, "You do not have enough Degen Tokens");

    // Transfer tokens from user to owner
    approve(owner(), totalTokensRequired);
    transferFrom(msg.sender, owner(), totalTokensRequired);

    return true;
}


    function checkBalance(address account) public view returns (uint256) {
        return balanceOf(account);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function _chargeTransferFee(address sender, uint256 amount) internal {
        uint256 fee = (amount * 2) / 100; // 2% fee
        _burn(sender, fee);
    }
}