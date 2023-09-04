// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import { NTUFCBlindBox11201 } from "../src/NTUFCBlindBox11201.sol";

contract NTUFCBlindBox11201Test is PRBTest, StdCheats {
    NTUFCBlindBox11201 blindBox;
    address owner;

    function setUp() public {
        blindBox = new NTUFCBlindBox11201("https://example/base.com/", "https://example/not/revealed.com/");
        owner = vm.addr(1);
    }

    function test_freeMint() public {
        vm.prank(owner);
        blindBox.freeMint(1);

        assertEq(blindBox.totalSupply(), 1);
        assertEq(blindBox.balanceOf(address(owner)), 1);
        assertEq(blindBox.ownerOf(0), address(owner));

        // before reveal
        assertEq(blindBox.tokenURI(0), "https://example/not/revealed.com/");

        // after reveal
        blindBox.setRevealed(true);
        assertEq(blindBox.tokenURI(0), "https://example/base.com/0.json");
    }
}
