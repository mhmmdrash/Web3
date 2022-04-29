// SPDX-License-Identifier: MIT
pragma solidity ^0.6;

import "https://github.com/Uniswap/v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";
import "https://github.com/Uniswap/v2-periphery/blob/master/contracts/libraries/UniswapV2Library.sol";
import "https://github.com/Uniswap/v2-periphery/blob/master/contracts/interfaces/IERC20.sol";

contract DashxDaiSwap {

    address public immutable dash;
    address public immutable dai;

    address public immutable factory;
    address public immutable router;

    event log(string message, uint val);

    constructor(
        address _dash, 
        address _dai, 
        address _factory, 
        address _router
    ) public {
        dash = _dash;
        dai = _dai;
        factory = _factory;
        router = _router;
    }
    
    // add liquidity to Dash Dai pool
    function addLiquidity(
        uint _amountA,
        uint _amountB
    ) public {
        IERC20(dash).transferFrom(msg.sender, address(this), _amountA);
        IERC20(dai).transferFrom(msg.sender, address(this), _amountB);

        IERC20(dash).approve(router, _amountA);
        IERC20(dash).approve(router, _amountB);

        (uint amountA, uint amountB, uint liquidity) = IUniswapV2Router02(router).addLiquidity(
            dash,
            dai,
            _amountA,
            _amountB,
            1,
            1,
            msg.sender,
            block.timestamp + 2000
        );

        emit log("Amount A", amountA);
        emit log("Amount B", amountB);
        emit log("Liquidity", liquidity);
    }

    function removeLiqudity() public {
        address pair = UniswapV2Library.pairFor(factory, dash, dai);
        uint liquidity = IERC20(pair).balanceOf(msg.sender);
        (uint amountA, uint amountB) = IUniswapV2Router02(router).removeLiquidity(
            dash,
            dai,
            liquidity,
            1,
            1,
            msg.sender,
            block.timestamp + 2000
        );

        emit log("Amount A", amountA);
        emit log("Amount B", amountB);
    }

    function getReserves() public view returns (uint reserveA, uint reserveB) {
        (reserveA, reserveB) = UniswapV2Library.getReserves(factory, dash, dai);
    }
}
