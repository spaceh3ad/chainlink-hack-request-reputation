// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract APIConsumer is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    uint256 private constant ORACLE_PAYMENT = 1 * LINK_DIVISIBILITY; // 1 * 10**18
    uint256 public reputation_data;

    event RequestReputatation(address indexed _address, string indexed _chain);

    /**
     *  KOVAN
     *@dev LINK address in Kovan network: 0xa36085F69e2889c224210F603D836748e7dC0088
     * @dev Check https://docs.chain.link/docs/link-token-contracts/ for LINK address for the right network
     */
    constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(0xa36085F69e2889c224210F603D836748e7dC0088);
    }

    function requestReputationData(
        address _oracle,
        string memory _jobId,
        string memory _query
    ) public onlyOwner {
        Chainlink.Request memory request = buildChainlinkRequest(
            stringToBytes32(_jobId),
            address(this),
            this.fulfill.selector
        );
        string memory uri = string(
            bytes.concat(
                bytes("https://ormi.herokuapp.com/data?"),
                bytes(_query)
            )
        );

        // Example query: "https://ormi.herokuapp.com/data?id=0x2&type=ETH"
        request.add("get", uri);

        request.add("path", "reputation");
        sendChainlinkRequestTo(_oracle, request, ORACLE_PAYMENT);
    }

    function fulfill(bytes32 _requestId, uint256 _reputation_data)
        public
        recordChainlinkFulfillment(_requestId)
    {
        reputation_data = _reputation_data;
    }

    function getChainlinkToken() public view returns (address) {
        return chainlinkTokenAddress();
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

    function cancelRequest(
        bytes32 _requestId,
        uint256 _payment,
        bytes4 _callbackFunctionId,
        uint256 _expiration
    ) public onlyOwner {
        cancelChainlinkRequest(
            _requestId,
            _payment,
            _callbackFunctionId,
            _expiration
        );
    }

    function stringToBytes32(string memory source)
        private
        pure
        returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }
}
