//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import {IAggregatorModule} from "./interfaces/IAggregatorModule.sol";
import {IOracleModule} from "./interfaces/IOracleModule.sol";
import {IRandomnessModule} from "./interfaces/IRandomnessModule.sol";
import {ISwitchboardModule} from "./interfaces/ISwitchboardModule.sol";
import {IQueueModule} from "./interfaces/IQueueModule.sol";

interface ISwitchboard is
    IAggregatorModule,
    IOracleModule,
    IRandomnessModule,
    ISwitchboardModule,
    IQueueModule
{}
