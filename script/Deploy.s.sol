// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {OPERAPAY} from "../src/token/OPERAPAY.sol";
import {SchoolManagementSystem} from "../src/school/SchoolManagementSystem.sol";

contract Deploy is Script {
    function run()
        external
        returns (OPERAPAY token, SchoolManagementSystem school)
    {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);

        // token = new MySchoolToken("SchoolToken", "SCH", 1_000_000 * 1e18);

        // school = new SchoolManagementSystem(address(token));

        token = new OPERAPAY();
        school = new SchoolManagementSystem(address(token));

        school.setLevelFee(100, 100 * 1e18);
        school.setLevelFee(200, 200 * 1e18);
        school.setLevelFee(300, 300 * 1e18);
        school.setLevelFee(400, 400 * 1e18);

        vm.stopBroadcast();
    }
}
