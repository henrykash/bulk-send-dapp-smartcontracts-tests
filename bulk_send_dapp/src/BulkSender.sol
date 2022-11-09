// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract BulkSender is
    Initializable,
    AccessControlEnumerableUpgradeable,
    ReentrancyGuardUpgradeable
{
    //events emitted to keep track of logs
    event LogTokenBulkSent(IERC20Upgradeable token, uint256 total);

    using SafeERC20Upgradeable for IERC20Upgradeable;

    /*///////////////////////////////////////////////////////////////
                           Modifiers
    //////////////////////////////////////////////////////////////*/
    
    /// @dev Checks whether the caller is a module admin.
    modifier onlyModuleAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "403");
        _;
    }

    /// @dev Initiliazes the contract, like a constructor.
    function initialize(address _defaultAdmin) external initializer {
        // Initialize inherited contracts, most base-like -> most derived.
        __ReentrancyGuard_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
    }

    function batchTransferTokens(
        IERC20Upgradeable _tokenAddress,
        address[] memory _to,
        uint256[] memory _value
    ) internal {
        require(_to.length == _value.length);
        require(_to.length <= 30);

        uint256 sendAmount = _value[0];

        for (uint8 i = 0; i < _to.length; i++) {
            _tokenAddress.transferFrom(msg.sender, _to[i], _value[i]);
        }
        emit LogTokenBulkSent(_tokenAddress, sendAmount);
    }

    /*
        Send coin with the different value by a implicit call method, this method can save some fee.
    */
    function batchTransfer(
        IERC20Upgradeable _tokenAddress,
        address[] memory _to,
        uint256[] memory _value
    ) public payable onlyModuleAdmin nonReentrant {
        batchTransferTokens(_tokenAddress, _to, _value);
    }

    //this function allows withdrawal of funds
    function widthrawToken(IERC20Upgradeable _token, uint256 _amount)
        external
        onlyModuleAdmin
        nonReentrant
    {
        _token.safeTransfer(msg.sender, _amount);
    }

    /// @dev Lets the contract receive native tokens from `nativeTokenWrapper` withdraw.
    receive() external payable {}
}
